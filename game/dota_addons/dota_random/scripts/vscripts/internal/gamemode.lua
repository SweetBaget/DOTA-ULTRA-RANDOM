-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
print('[GameMode] Init')
tempBanList = LoadKeyValues('scripts/kv/ignoreMulticast.kv')
multicastChannel = {}
CREATOR = nil
CREATOR_ID = nil
function GameMode:_InitGameMode()
  -- Setup rules
  GameRules:SetHeroRespawnEnabled(ENABLE_HERO_RESPAWN)
  GameRules:SetUseUniversalShopMode(UNIVERSAL_SHOP_MODE)
  GameRules:SetSameHeroSelectionEnabled(SAME_HERO)
  GameRules:SetHeroSelectionTime(HERO_SELECTION_TIME)
  GameRules:SetPreGameTime(PRE_GAME_TIME)
  GameRules:SetPostGameTime(POST_GAME_TIME)
  GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
  GameRules:SetFirstBloodActive(ENABLE_FIRST_BLOOD)
  GameRules:GetGameModeEntity():SetUseDefaultDOTARuneSpawnLogic(true)

  -- This is multiteam configuration stuff
  if USE_AUTOMATIC_PLAYERS_PER_TEAM then
    local num = math.floor(10 / MAX_NUMBER_OF_TEAMS)
    local count = 0
    for team,number in pairs(TEAM_COLORS) do
      if count >= MAX_NUMBER_OF_TEAMS then
        GameRules:SetCustomGameTeamMaxPlayers(team, 0)
      else
        GameRules:SetCustomGameTeamMaxPlayers(team, num)
      end
      count = count + 1
    end
  else
    local count = 0
    for team,number in pairs(CUSTOM_TEAM_PLAYER_COUNT) do
      if count >= MAX_NUMBER_OF_TEAMS then
        GameRules:SetCustomGameTeamMaxPlayers(team, 0)
      else
        GameRules:SetCustomGameTeamMaxPlayers(team, number)
      end
      count = count + 1
    end
  end

  if USE_CUSTOM_TEAM_COLORS then
    for team,color in pairs(TEAM_COLORS) do
      SetTeamCustomHealthbarColor(team, color[1], color[2], color[3])
    end
  end

  print('[BAREBONES] GameRules set')
  ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(GameMode, 'OnPlayerLevelUp'), self)
  ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(GameMode, 'OnPlayerLearnedAbility'), self)
  ListenToGameEvent('entity_killed', Dynamic_Wrap(GameMode, 'OnEntityKilled'), self)
  ListenToGameEvent('player_connect_full', Dynamic_Wrap(GameMode, 'OnConnectFull'), self)
  ListenToGameEvent('player_disconnect', Dynamic_Wrap(GameMode, 'OnDisconnect'), self)
  ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(GameMode, 'OnPickedHero'), self)
  ListenToGameEvent('dota_hero_random', Dynamic_Wrap(GameMode, 'OnPickedHero'), self)
  ListenToGameEvent('hero_selected', Dynamic_Wrap(GameMode, 'OnPickedHero'), self)
  -- ListenToGameEvent('player_connect', Dynamic_Wrap(GameMode, 'PlayerConnect'), self)
  ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(GameMode, 'OnAbilityUsed'), self)
  ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(GameMode, 'OnGameRulesStateChange'), self)
  ListenToGameEvent('npc_spawned', Dynamic_Wrap(GameMode, 'OnNPCStartSpawn'), self)
  ListenToGameEvent('dota_on_hero_finish_spawn', Dynamic_Wrap(GameMode, 'OnHEROFinishSpawned'), self)
  ListenToGameEvent('npc_spawn_finished', Dynamic_Wrap(GameMode, 'OnNPCFinishSpawned'), self)
  ListenToGameEvent("player_reconnected", Dynamic_Wrap(GameMode, 'OnPlayerReconnect'), self)
  ListenToGameEvent("dota_player_begin_cast", Dynamic_Wrap(GameMode, 'OnAbilityCastBegins'), self)
  ListenToGameEvent("dota_non_player_begin_cast", Dynamic_Wrap(GameMode, 'OnAbilityCastBeginsNPC'), self)

  CustomGameEventManager:RegisterListener("set_game_mode", OnSetGameMode)
  CustomGameEventManager:RegisterListener("NonHostConnected", OnNonHostConnected)
  CustomGameEventManager:RegisterListener("HostConnected", OnHostConnected)
  
  GameRules:GetGameModeEntity():SetBountyRunePickupFilter(Dynamic_Wrap(GameMode, 'BountyRunePickupFilter'), self)

  local spew = 0
  if BAREBONES_DEBUG_SPEW then
    spew = 1
  end
  Convars:RegisterConvar('barebones_spew', tostring(spew), 'Set to 1 to start spewing barebones debug info.  Set to 0 to disable.', 0)
  Convars:SetInt("sv_cheats", 1)

  -- Change random seed
  local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
  math.randomseed(tonumber(timeTxt))

  -- Initialized tables for tracking state
  self.bSeenWaitForPlayers = false
  self.vUserIds = {}

  print('[BAREBONES] Done loading Barebones gamemode!\n\n')
end

mode = nil
function OnSetGameMode(eventSourceIndex, args)
  settings = {}
  parsed = args
  if parsed == nil then return end
  
  if (parsed.gamemode == 'ar')    then ALL_RANDOM   = true else ALL_RANDOM    = false end
  
  if (tonumber(parsed.same_hero) == 1) then SAME_HERO = true else SAME_HERO = false end
  if (tonumber(parsed.disableAttackSpeedCap) == 1) then DISABLE_ATTACK_SPEED_CAP = true else DISABLE_ATTACK_SPEED_CAP = false end
  if (tonumber(parsed.easy_mode) == 1) then EASY_MODE = true else EASY_MODE = false end
  if (tonumber(parsed.ignore_movespeed_limit) == 1) then IGNORE_MOVESPEED_LIMIT = true else IGNORE_MOVESPEED_LIMIT = false end
  if (tonumber(parsed.INNATE_ALLOWED) == 1) then INNATE_ALLOWED = true else INNATE_ALLOWED = false end
  if (tonumber(parsed.buff_creeps) == 1)   then BUFF_CREEPS  = true else BUFF_CREEPS   = false end
  if (tonumber(parsed.buff_towers) == 1)   then BUFF_TOWERS  = true else BUFF_TOWERS   = false end
  if (tonumber(parsed.buff_stats) == 1)   then BUFF_STATS   = true else BUFF_STATS    = false end
  if (tonumber(parsed.fast_respawn) == 1)   then FAST_RESPAWN = true else FAST_RESPAWN  = false end
  if (tonumber(parsed.omg) == 1)  then RANDOM_OMG   = true else RANDOM_OMG    = false end
  if (tonumber(parsed.DisableFOG) == 1)  then DisableFOG   = true else DisableFOG    = false end
  if (tonumber(parsed.multicast) == 1)   then MULTICAST    = true else MULTICAST     = false end
  if (tonumber(parsed.free_scepter) == 1)   then FREE_SCEPTER    = true else FREE_SCEPTER     = false end
  if (tonumber(parsed.max_lvl) == 1)   then MAX_LEVEL_BOOL   = true else MAX_LEVEL_BOOL    = false end
  if (tonumber(parsed.creepsSkills) == 1)   then CREEPS_SKILLS_BOOL   = true else CREEPS_SKILLS_BOOL     = false end
  if (tonumber(parsed.chance) == 1)   then xChance = true else xChance = false end
  if (tonumber(parsed.slow) == 1) then xSlow = true else xSlow = false end
  if (tonumber(parsed.xIllusion) == 1) then xIllusion = true else xIllusion = false end
  if (tonumber(parsed.xArmor) == 1) then xArmor = true else xArmor = false end

  if (tonumber(parsed.omgdm) == 1) then DM_OMG = true else DM_OMG = false end

  maxUlts   = math.floor(parsed.total_ultis/0.1)
  maxSlots  = Round(parsed.total_skills/0.111111) + 1
  maxSkills = maxSlots - maxUlts

  xCooldown = (Round(parsed.cooldown, 1)/0.2 + 1)

  if parsed.multiplier ~= nil then
    xMultiplier = (Round(parsed.multiplier, 1)/0.2 + 1)
  else
    xMultiplier = 4
  end
  if xMultiplier == 3 then xMultiplier = 5 end
  if xMultiplier == 4 then xMultiplier = 10 end
  if xMultiplier == 5 then xMultiplier = 100 end
  if xMultiplier == 6 then xMultiplier = 1000 end

  xRadius = (Round(parsed.radius, 1)/0.2 + 1)
  if tostring(xRadius) == "4" then xRadius = 10 end
  if xRadius == 5 then xRadius = 100 end
  if xRadius == 3 then xRadius = 5 end
  if xRadius == 6 then xRadius = 1000 end

  xRange = (Round(parsed.range, 1)/0.2 + 1)
  if tostring(xRange) == "4" then xRange = 10 end
  if xRange == 5 then xRange = 100 end
  if xRange == 3 then xRange = 5 end
  if xRange == 6 then xRange = 1000 end

  xDuration = (Round(parsed.duration, 1)/0.2 + 1)
  if tostring(xDuration) == "4" then xDuration = 10 end
  if xDuration == 5 then xDuration = 100 end
  if xDuration == 3 then xDuration = 5 end
  if xDuration == 6 then xDuration = 1000 end

  xAbilityCastRange = (Round(parsed.abilitycastrange, 1)/0.2 + 1)
  if tostring(xAbilityCastRange) == "4" then xAbilityCastRange = 10 end
  if xAbilityCastRange == 5 then xAbilityCastRange = 100 end
  if xAbilityCastRange == 3 then xAbilityCastRange = 5 end
  if xAbilityCastRange == 6 then xAbilityCastRange = 1000 end
  -------------------
  settings["xAbilityCastRange"] = xAbilityCastRange
  settings["xCooldown"] = xCooldown
  settings["xDuration"] = xDuration
  settings["xRange"] = xRange
  settings["xMultiplier"] = xMultiplier
  settings["xRadius"] = xRadius
  settings["xChance"] = xChance
  settings["xSlow"] = xSlow
  settings["xIllusion"] = xIllusion
  settings["xArmor"] = xArmor
  CustomNetTables:SetTableValue("settings", "settings", settings)

  if DisableFOG == true then
    mode:SetFogOfWarDisabled(true)
  end    

  if MAX_LEVEL_BOOL == true then
    mode:SetUseCustomHeroLevels(true)
  end 
end

function OnNonHostConnected( eventSourceIndex, args )
  local cplyID = args.PlayerID
  local rplayer = PlayerResource:GetPlayer(cplyID)
  if cplyID == nil then
    return
  end
  if parsed == nil then
    return
  end
  CustomGameEventManager:Send_ServerToPlayer( rplayer, "PlayerConnected", parsed )
end

function OnHostConnected( eventSourceIndex, args )
  local cplyID = args.PlayerID
  local rplayer = PlayerResource:GetPlayer(cplyID)
  CustomGameEventManager:Send_ServerToPlayer( rplayer, "HostPlayerConnected", DEFAULT_MODE_SETTINGS )
end

function GameMode:MultiplyTowers()
  print("Improving fontain!")
  -- loop over all fountains
  local fountain = Entities:FindByClassname( nil, "ent_dota_fountain" )
  while fountain do
      -- add mkb item
      local item = CreateItem('item_monkey_king_bar', fountain, fountain)
      if item then
          fountain:AddItem(item)
      end

      -- add fury swipes skill async
      fountain:AddAbility('ursa_fury_swipes')       
      ab = fountain:FindAbilityByName('ursa_fury_swipes')
      if ab then
          ab:SetLevel(4)
      end

      -- find next fountain
      fountain = Entities:FindByClassname( fountain, "ent_dota_fountain" )
  end

  print("Improving towers!")
  -- improve towers
  local tower = Entities:FindByClassname( nil, "npc_dota_tower" )
  while tower do
      tower:SetBaseDamageMin((tower:GetBaseDamageMin() * xMultiplier))
      tower:SetBaseDamageMax((tower:GetBaseDamageMax() * xMultiplier))
      tower:SetBaseMaxHealth((tower:GetBaseMaxHealth() * xMultiplier))
      tower:SetMaxHealth((tower:GetMaxHealth() * xMultiplier))
      tower:SetHealth((tower:GetHealth() * xMultiplier))
      tower:SetPhysicalArmorBaseValue(tower:GetPhysicalArmorBaseValue() * (xMultiplier / 2))


      tower:AddAbility('ursa_fury_swipes')       
      local ab = tower:FindAbilityByName('ursa_fury_swipes')
      if ab then
            ab:SetLevel(4)
      end
      if tower:GetUnitName() == 'npc_dota_badguys_tower4' or tower:GetUnitName() == 'npc_dota_goodguys_tower4' then
        tower:AddAbility('abaddon_borrowed_time')   
        local ab = tower:FindAbilityByName('abaddon_borrowed_time')
        if ab then
            ab:UpgradeAbility(true)
        end

        local item = CreateItem('item_ultimate_scepter', tower, tower)
        if item then
            tower:AddItem(item)
        end
      end  
      tower = Entities:FindByClassname(tower, "npc_dota_tower")
  end

  print("Improving barracks!")
    -- improve barracks
  local rax = Entities:FindByClassname( nil, "npc_dota_barracks" )
  while rax do
    rax:SetBaseMaxHealth(rax:GetBaseMaxHealth() * xMultiplier)
    rax:SetMaxHealth(rax:GetMaxHealth() * xMultiplier)
    rax:SetHealth(rax:GetHealth() * xMultiplier)
    rax:SetPhysicalArmorBaseValue(rax:GetPhysicalArmorBaseValue() * xMultiplier)
    rax = Entities:FindByClassname( rax, "npc_dota_barracks" )
  end

  print("Improving ancient!")
  -- improve ancient
  local ancient = Entities:FindByClassname( nil, "npc_dota_fort" )
  while ancient do
    ancient:SetBaseHealthRegen(ancient:GetHealth() / 100)
    ancient:SetBaseMaxHealth((ancient:GetBaseMaxHealth() * xMultiplier))
    ancient:SetMaxHealth(ancient:GetMaxHealth() * xMultiplier)
    ancient:SetHealth(ancient:GetHealth() * xMultiplier)
    ancient:SetPhysicalArmorBaseValue(ancient:GetPhysicalArmorBaseValue() * (xMultiplier / 2))
    ancient = Entities:FindByClassname( ancient, "npc_dota_fort" )
  end
end

function GameMode:ApplyEasyMode(hero)
  hero:SetMaximumGoldBounty(hero:GetGoldBounty() * xMultiplier)
  hero:SetMinimumGoldBounty(hero:GetGoldBounty() * xMultiplier)
  hero:SetDeathXP(hero:GetDeathXP() * xMultiplier)
end

function GameMode:MultiplyBaseStats(hero) 
  hero:SetBaseStrength(hero:GetBaseStrength() * xMultiplier)
  hero:SetBaseAgility(hero:GetBaseAgility() * xMultiplier)
  hero:SetBaseIntellect(hero:GetBaseIntellect() * xMultiplier)
end

function GameMode:OnNonHeroNpcSpawned(spawnedUnit)
  if BUFF_CREEPS == true then
    if spawnedUnit:GetUnitName() == "npc_dota_observer_wards" or spawnedUnit:GetUnitName() == "npc_dota_sentry_wards" then return end
    spawnedUnit:SetBaseDamageMin((spawnedUnit:GetBaseDamageMin() * xMultiplier))
    spawnedUnit:SetBaseDamageMax((spawnedUnit:GetBaseDamageMax() * xMultiplier))
    spawnedUnit:SetBaseMaxHealth(spawnedUnit:GetBaseMaxHealth() * xMultiplier)
    spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth() * xMultiplier)
    spawnedUnit:SetHealth(spawnedUnit:GetHealth() * xMultiplier)

    if string.match(spawnedUnit:GetUnitName(), "roshan") then
      spawnedUnit:SetBaseDamageMin((spawnedUnit:GetBaseDamageMin() * xMultiplier))
      spawnedUnit:SetBaseDamageMax((spawnedUnit:GetBaseDamageMax() * xMultiplier))
      spawnedUnit:SetBaseMaxHealth(spawnedUnit:GetBaseMaxHealth() * xMultiplier)
      spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth() * xMultiplier)
      spawnedUnit:SetHealth(spawnedUnit:GetHealth() * xMultiplier)

      -- add protection skill async
      spawnedUnit:SetBaseMagicalResistanceValue(50)
      spawnedUnit:AddAbility('spectre_dispersion')       
      ab = spawnedUnit:FindAbilityByName('spectre_dispersion')
      if ab then
        ab:SetLevel(ab:GetMaxLevel())
      end
    end

    if string.match(spawnedUnit:GetUnitName(), "creep") or string.match(spawnedUnit:GetUnitName(), "neutral") or string.match(spawnedUnit:GetUnitName(), "siege") then
      if BUFF_CREEPS == true then 
          spawnedUnit:SetBaseMagicalResistanceValue(50)
      end
      if EASY_MODE == true then
        spawnedUnit:SetMaximumGoldBounty(spawnedUnit:GetGoldBounty() * xMultiplier)
        spawnedUnit:SetMinimumGoldBounty(spawnedUnit:GetGoldBounty() * xMultiplier)
        spawnedUnit:SetDeathXP(spawnedUnit:GetDeathXP() * xMultiplier)
      end  
    end
  end
end

function GameMode:GiveRandomSkills(hero)
  SkillHandler:randomSkillsWork(hero, maxSkills, maxUlts)
end

function CheckIsMainPlayableHero(hero)
  if hero:IsClone() or hero:IsSummoned() or hero:IsPhantom() or hero:IsIllusion() or hero:IsTempestDouble() or
  hero:IsCreep() or hero:IsOther() then return false end
  if not hero:IsRealHero() then return false end

  print(hero:IsHero(), "IsHero")
  print(hero:IsRealHero(), "IsRealHero")
  print(hero:IsIllusion(), "IsIllusion")
  print(hero:IsSummoned(), "IsSummoned")
  print(hero:IsConsideredHero(), "IsConsideredHero")
  print(hero:IsControllableByAnyPlayer(), "IsControllableByAnyPlayer")
  print(hero:IsCreature(), "IsCreature")
  print(hero:IsCreep(), "IsCreep")
  print(hero:IsCreepHero(), "IsCreepHero")
  print(hero:IsNeutralUnitType(), "IsNeutralUnitType")
  print(hero:IsOther(), "IsOther")
  print(hero:IsOwnedByAnyPlayer(), "IsOwnedByAnyPlayer")
  print(hero:IsPhantom(), "IsPhantom")
  print(hero:IsUnselectable(), "IsUnselectable")
  print(hero:IsZombie(), "IsZombie")
  print(hero:IsTempestDouble(), "IsTempestDouble")
  print(hero:IsStrongIllusion(), "IsStrongIllusion")
  print(hero:IsPhantomBlocker(), "IsPhantomBlocker")
  print(hero:IsClone(), "IsClone")
  return true
end

function GameMode:FillPlayersTable()
  self.players = {}
  PW_PLAYERS_ON_GAME_ACTUALLY = 0
  GOODGUYS_CONNECTED_PLAYERS = 0
  BADGUYS_CONNECTED_PLAYERS = 0
  for id = 0, PW_PLAYERS_ON_GAME - 1 do
    self.players[id] = PlayerResource:GetPlayer(id) 
    if self.players[id] then
      -- Initialize connection state
      PW_PLAYERS_ON_GAME_ACTUALLY = PW_PLAYERS_ON_GAME_ACTUALLY + 1
      self.players[id].connection_state = PlayerResource:GetConnectionState(id)
      print("initialized connection for player "..id..": "..self.players[id].connection_state)
      -- Increment amount of players on this team by one
      if PlayerResource:GetTeam(id) == DOTA_TEAM_GOODGUYS then
        GOODGUYS_CONNECTED_PLAYERS = GOODGUYS_CONNECTED_PLAYERS + 1
        print("goodguys team now has "..GOODGUYS_CONNECTED_PLAYERS.." players")
      elseif PlayerResource:GetTeam(id) == DOTA_TEAM_BADGUYS then
        BADGUYS_CONNECTED_PLAYERS = BADGUYS_CONNECTED_PLAYERS + 1
        print("badguys team now has "..BADGUYS_CONNECTED_PLAYERS.." players")
      end
    else
      -- If the player never connected, assign it a special string
      if PlayerResource:GetConnectionState(id) == 1 then
        self.players[id] = "empty_player_slot"
        print("player "..id.." never connected")
      end
    end
  end
  print('ACTUALLY PLAYERS IN GAME: ' .. PW_PLAYERS_ON_GAME_ACTUALLY)
end

function GameMode:PerformAllRandom()
  for id = 0, PW_PLAYERS_ON_GAME_ACTUALLY - 1 do
      Timers:CreateTimer(0, function()
        --print("attempting to random a hero for player "..id)
        if self.players[id] and self.players[id] ~= "empty_player_slot" then
          PlayerResource:GetPlayer(id):MakeRandomHeroSelection()
          --PlayerResource:SetHasRepicked(id)
          PlayerResource:SetHasRandomed(id)
          --print("succesfully randomed a hero for player "..id)
        elseif not self.players[id] then
          --print("player "..id.." still hasn't randomed a hero")
          return 0.5
        end
      end)
    end
  end

function GameMode:DeathMatchLogic(hero)
  print("иди нахуй")
end

function GameMode:BountyRunePickupFilter(filterTable)
  local gold = filterTable['gold_bounty']
  if EASY_MODE then 
    gold = gold * xMultiplier
  end
  filterTable['gold_bounty'] = gold

  local xp = filterTable['xp_bounty']
  if EASY_MODE then 
    xp = xp * xMultiplier
  end
  filterTable['xp_bounty'] = xp

  return true
end

--Инициализируется "mode" и после этого начинаются вылеты. При этом, сам мод никаких проблема не несет
-- This function is called as the first player loads and sets up the GameMode parameters
function GameMode:_CaptureGameMode()
  if mode == nil then
    -- Set GameMode parameters
    mode = GameRules:GetGameModeEntity() 

    mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
    mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
    mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
    mode:SetBuybackEnabled( BUYBACK_ENABLED )
    mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
    mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
    mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
    mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )
    mode:SetCustomXPRequiredToReachNextLevel(XP_LEVEL_TABLE)

    mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)

    mode:SetAlwaysShowPlayerInventory( SHOW_ONLY_PLAYER_INVENTORY )
    mode:SetAnnouncerDisabled( DISABLE_ANNOUNCER )
    if FORCE_PICKED_HERO ~= nil then
      mode:SetCustomGameForceHero( FORCE_PICKED_HERO )
    end
    mode:SetFixedRespawnTime( FIXED_RESPAWN_TIME ) 
    mode:SetFountainConstantManaRegen( FOUNTAIN_CONSTANT_MANA_REGEN )
    mode:SetFountainPercentageHealthRegen( FOUNTAIN_PERCENTAGE_HEALTH_REGEN )
    mode:SetFountainPercentageManaRegen( FOUNTAIN_PERCENTAGE_MANA_REGEN )
    mode:SetLoseGoldOnDeath( LOSE_GOLD_ON_DEATH )

    if DISABLE_ATTACK_SPEED_CAP then
      mode:SetMaximumAttackSpeed(9999)
    end

    mode:SetStashPurchasingDisabled ( DISABLE_STASH_PURCHASING )

    mode:SetUnseenFogOfWarEnabled(USE_UNSEEN_FOG_OF_WAR)

    mode:SetFreeCourierModeEnabled(FREE_COURIER_ENABLED)

    self:OnFirstPlayerLoaded()
  end 
end