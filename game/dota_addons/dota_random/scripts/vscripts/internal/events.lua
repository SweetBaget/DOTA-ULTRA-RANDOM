require("internal/utils/butt_api")

-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
    local newState = GameRules:State_Get()
    if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
        self.bSeenWaitForPlayers = true
    elseif newState == DOTA_GAMERULES_STATE_INIT then
        --Timers:RemoveTimer("alljointimer")
    elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
        if PRECACHE_PARTICLES then
            GameMode:LoadPrecache()
        end
        GameMode:OnAllPlayersLoaded()

        if USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS then
            for i=0,9 do
                if PlayerResource:IsValidPlayer(i) then
                local color = TEAM_COLORS[PlayerResource:GetTeam(i)]
                PlayerResource:SetCustomPlayerColor(i, color[1], color[2], color[3])
                end
            end
        end
    elseif newState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
        for i=0,9 do
            local player = PlayerResource:GetPlayer(i)
            if player ~= nil then
                if PlayerResource:HasSelectedHero(i) == false then
                    player:MakeRandomHeroSelection()
                end
            end
        end
    elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then

    end
end

function GameMode:AddMultipleModifier(npc)
  if npc ~= nil then
    if npc:HasModifier("modifier_spells_randomize_values") then
      return
    end
    -- перед добавлением модификатора, будет создана линковка на него (так надежнее всего)
    npc:AddNewModifierButt(npc, nil, "modifier_spells_randomize_values", nil)
  end
end

function GameMode:OnAbilityCastBegins(keys)
end

function GameMode:OnAbilityCastBeginsNPC(keys)
end

function GameMode:OnNPCStartSpawn(keys)
    local npc = EntIndexToHScript(keys.entindex)
    
    CheckNPCParams(npc) --просто проверка юнита
    -- когда спавнится копия TempestDouble, сначала создается герой без tempestdouble, потом НПС с tempestdouble
    local IsTempestDouble = npc:IsTempestDouble()
    
    if npc:IsRealHero() then
        if npc.bFirstSpawned == false then
            GameMode:OnHeroRespawned(npc, IsTempestDouble)
        else
            npc.bFirstSpawned = false
            GameMode:HeroFirstTimeInGame(npc, IsTempestDouble)
        end
    else
        GameMode:OnNonHeroNpcSpawned(npc)
    end
end

function GameMode:OnNPCFinishSpawned(keys)
    print("не работает")
end

function GameMode:OnHEROFinishSpawned(hero, heroName)
  local heroLikeNpc = EntIndexToHScript(hero.heroindex)
  print("hero finish. FirstSpawned? -", heroLikeNpc.bFirstSpawned)
  

  -- if heroLikeNpc.bFirstSpawned == true or heroLikeNpc.bFirstSpawned == nil then
  --   heroLikeNpc.bFirstSpawned = false
  --   GameMode:HeroFirstTimeInGame(heroLikeNpc)
  -- end
end

function GameMode:OnPickedHero(event)
end

-- An entity died
function GameMode:OnEntityKilled(keys)
  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript(keys.entindex_killed)
  if not killedUnit:IsRealHero() and not killedUnit:IsClone() then
    return
  end

  if killedUnit:IsReincarnating() then return end

  -- Fix Meepo's clones
  if killedUnit:IsClone() then    
    killedUnit = killedUnit:GetCloneSource()
  end
    
  local killerEntity = nil
  killerEntity = EntIndexToHScript(keys.entindex_attacker)

  print("KILLED, KILLER: " .. killedUnit:GetName() .. " -- " .. killerEntity:GetName())
  if END_GAME_ON_KILLS and GetTeamHeroKills(killerEntity:GetTeam()) >= KILLS_TO_END_GAME_FOR_TEAM then
    GameRules:SetSafeToLeave(true)
    GameRules:SetGameWinner(killerEntity:GetTeam())
  end

  if FAST_RESPAWN then
    killedUnit:SetTimeUntilRespawn(5)
  end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
    GameMode:_CaptureGameMode()

    local entIndex = keys.index+1
    -- The Player entity of the joining user
    local ply = EntIndexToHScript(entIndex)
    local playerID = keys.PlayerID
    local userID = keys.userid
    self.vUserIds = self.vUserIds or {}
    self.vUserIds[userID] = ply

    -- local player = PlayerResource:GetPlayer(playerID)
    -- local playerIsHost = GameRules:PlayerHasCustomGameHostPrivileges(player)
    -- if playerIsHost then
        -- print("keke")
        -- CustomGameEventManager:Send_ServerToPlayer(player, "applyInitSettings", DEFAULT_MODE_SETTINGS)
        -- CustomGameEventManager:Send_ServerToAllClients("applyInitSettings", DEFAULT_MODE_SETTINGS)
    -- end
end

-- -- The overall game state has changed
-- function GameMode:OnGameRulesStateChange(keys)
--   print("[BAREBONES] GameRules State Changed")
--   PrintTable(keys)
--   GameMode:_OnGameRulesStateChange(keys)
-- end

function GameMode:OnAbilityUsed(keys)
  if MULTICAST then
    Multicast:DoMulticast(keys)
  end
  GameMode:removeAttributeResistance(keys)
end