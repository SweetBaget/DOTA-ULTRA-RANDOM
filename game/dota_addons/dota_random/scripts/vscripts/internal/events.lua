-- The overall game state has changed
function GameMode:_OnGameRulesStateChange(keys)
  local newState = GameRules:State_Get()
  if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
    self.bSeenWaitForPlayers = true
  elseif newState == DOTA_GAMERULES_STATE_INIT then
    --Timers:RemoveTimer("alljointimer")
  elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
    GameMode:OnAllPlayersLoaded()

    if USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS then
      for i=0,9 do
        if PlayerResource:IsValidPlayer(i) then
          local color = TEAM_COLORS[PlayerResource:GetTeam(i)]
          PlayerResource:SetCustomPlayerColor(i, color[1], color[2], color[3])
        end
      end
    end
  end
end

function GameMode:ModifierInizialize(npc)
  if npc ~= nil then
    if npc:HasModifier("modifier_spells_randomize_values") then 
      return
    end
    npc:AddNewModifier(npc, nil, "modifier_spells_randomize_values", {})
  end
end

function GameMode:OnAbilityCastBegins(keys)
  -- local hero = EntIndexToHScript(keys.caster_entindex)
  -- print(#hero:FindAllModifiers(), "длина хуйя")
  -- for _, mod in pairs(hero:FindAllModifiers()) do
  --   print(_, mod:GetName())
  -- end
end

function GameMode:OnAbilityCastBeginsNPC(keys)
  -- print("nonplayercast")
  -- local hero = EntIndexToHScript(keys.caster_entindex)
  -- print(#hero:FindAllModifiers(), "длина хуйя")
  -- for _, mod in pairs(hero:FindAllModifiers()) do
  --   print(_, mod:GetName())
  -- end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCStartSpawn(keys)
  local npc = EntIndexToHScript(keys.entindex)
  CheckIsMainPlayableHero(npc)

  if npc:IsRealHero() then
    if npc.bFirstSpawned == false then
      GameMode:OnHeroRespawned(npc)
    end
  else
    GameMode:OnNonHeroNpcSpawned(npc)
  end
end

function GameMode:OnNPCFinishSpawned(keys)
  print("npc finish")
end

function GameMode:OnHEROFinishSpawned(hero, heroName)
  print("hero finish", hero.heroindex)
  local heroLikeNpc = EntIndexToHScript(hero.heroindex)

  -- бафф статов и т.д.
  heroLikeNpc.bFirstSpawned = false
  GameMode:OnHeroInGame(heroLikeNpc)
end

function GameMode:OnPickedHero(event)
end

-- An entity died
function GameMode:OnEntityKilled( keys )
  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  if not CheckIsMainPlayableHero(killedUnit) then
    return
  end

  if killedUnit:IsReincarnating() then return end

  -- Fix Meepo's clones
  if killedUnit:IsClone() then    
    killedUnit = killedUnit:GetCloneSource()
  end
    
  local killerEntity = nil
  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript(keys.entindex_attacker)
  end

  print("KILLED, KILLER: " .. killedUnit:GetName() .. " -- " .. killerEntity:GetName())
  if END_GAME_ON_KILLS and GetTeamHeroKills(killerEntity:GetTeam()) >= KILLS_TO_END_GAME_FOR_TEAM then
    GameRules:SetSafeToLeave(true)
    GameRules:SetGameWinner(killerEntity:GetTeam())
  end

  local playerID = killedUnit:GetPlayerID()
  if PlayerResource:IsFakeClient(playerID) then 
      return
  end

  if SHOW_KILLS_ON_TOPBAR then
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, GetTeamHeroKills(DOTA_TEAM_BADGUYS) )
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, GetTeamHeroKills(DOTA_TEAM_GOODGUYS) )
  end

  if FAST_RESPAWN then
    killedUnit:SetTimeUntilRespawn(5)
  end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:_OnConnectFull(keys)
  -- print('_OnConnectFull')
  GameMode:_CaptureGameMode()

  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  
  local userID = keys.userid

  self.vUserIds = self.vUserIds or {}
  self.vUserIds[userID] = ply
end