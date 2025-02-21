print('[GameMode] Init')
tempBanList = LoadKeyValues('scripts/kv/ignoreMulticast.kv')
multicastChannel = {}
CREATOR = nil
CREATOR_ID = nil
gameModeEntity = nil
function GameMode:_InitGameMode()
  -- Setup rules
  GameRules:EnableCustomGameSetupAutoLaunch(ENABLE_AUTO_LAUNCH)
  GameRules:SetHeroRespawnEnabled(ENABLE_HERO_RESPAWN)
  GameRules:SetUseUniversalShopMode(UNIVERSAL_SHOP_MODE)
  GameRules:SetSameHeroSelectionEnabled(SAME_HERO)
  GameRules:SetHeroSelectionTime(HERO_SELECTION_TIME)
  GameRules:SetPreGameTime(PRE_GAME_TIME)
  GameRules:SetPostGameTime(POST_GAME_TIME)
  GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
  GameRules:SetFirstBloodActive(ENABLE_FIRST_BLOOD)
  GameRules:SetHeroSelectPenaltyTime(0)
  GameRules:GetGameModeEntity():SetUseDefaultDOTARuneSpawnLogic(true)
  GameRules:GetGameModeEntity():SetBountyRunePickupFilter(Dynamic_Wrap(GameMode, 'BountyRunePickupFilter'), self)

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
  ListenToGameEvent('entity_killed', Dynamic_Wrap(GameMode, 'OnEntityKilled'), self)
  ListenToGameEvent('player_connect_full', Dynamic_Wrap(GameMode, 'OnConnectFull'), self)
  ListenToGameEvent('player_disconnect', Dynamic_Wrap(GameMode, 'OnDisconnect'), self)
  ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(GameMode, 'OnPickedHero'), self)
  ListenToGameEvent('dota_hero_random', Dynamic_Wrap(GameMode, 'OnPickedHero'), self)
  ListenToGameEvent('hero_selected', Dynamic_Wrap(GameMode, 'OnPickedHero'), self)
  ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(GameMode, 'OnAbilityUsed'), self)
  ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(GameMode, 'OnGameRulesStateChange'), self)
  ListenToGameEvent('npc_spawned', Dynamic_Wrap(GameMode, 'OnNPCStartSpawn'), self)
  ListenToGameEvent('dota_on_hero_finish_spawn', Dynamic_Wrap(GameMode, 'OnHEROFinishSpawned'), self)
  ListenToGameEvent('npc_spawn_finished', Dynamic_Wrap(GameMode, 'OnNPCFinishSpawned'), self)
  ListenToGameEvent("player_reconnected", Dynamic_Wrap(GameMode, 'OnPlayerReconnect'), self)
  ListenToGameEvent("dota_player_begin_cast", Dynamic_Wrap(GameMode, 'OnAbilityCastBegins'), self)
  ListenToGameEvent("dota_non_player_begin_cast", Dynamic_Wrap(GameMode, 'OnAbilityCastBeginsNPC'), self)

  ListenToGameEvent("dota_hero_inventory_item_change", Dynamic_Wrap(GameMode, 'removeAttributeResistance'), self)
--   ListenToGameEvent("dota_hero_inventory_item_change", function () CustomGameEventManager:Send_ServerToAllClients("fullSkillBox", skillsList) end, nil)
  ListenToGameEvent("entity_hurt", Dynamic_Wrap(GameMode, 'removeAttributeResistance'), self)
  ListenToGameEvent("dota_item_used", Dynamic_Wrap(GameMode, 'removeAttributeResistance'), self)

  CustomGameEventManager:RegisterListener("set_game_mode", onSetGameMode)
  CustomGameEventManager:RegisterListener("removeAttributeResistance", function (eventIndex, keys) GameMode:removeAttributeResistance(keys) end)
  CustomGameEventManager:RegisterListener("executeFromServer", executeFromServer)

  local spew = 0
  if BAREBONES_DEBUG_SPEW then
    spew = 1
  end
  Convars:RegisterConvar('barebones_spew', tostring(spew), 'Set to 1 to start spewing barebones debug info.  Set to 0 to disable.', 0)

  self.vUserIds = {}

  print('[BAREBONES] Done loading Barebones gamemode!\n\n')
end

function executeFromServer(event, keys)
    local command = keys.command
    local playerID = keys.playerID
    local player = PlayerResource:GetPlayer(playerID)
    if command == "setSettings" then
        CustomGameEventManager:Send_ServerToPlayer(player, "applyInitSettings", DEFAULT_MODE_SETTINGS)

    elseif command == "giveSkill" then
        local hero = player:GetAssignedHero()
        local newAbility = keys.skillName
        local addedAbility = hero:AddAbility(newAbility)
        addedAbility:SetLevel(addedAbility:GetMaxLevel())

        -- subSkills
        local subSkillInfo = subSkills[newAbility]
        if type(subSkillInfo) == "table" then
            for _, subSkill in pairs(subSkillInfo) do
                local subAbility = hero:AddAbility(subSkill)
                subAbility:SetLevel(subAbility:GetMaxLevel())
            end
        elseif subSkillInfo ~= nil then
            local subAbility = hero:AddAbility(subSkills[newAbility])
            subAbility:SetLevel(subAbility:GetMaxLevel())
        end

        -- linkedSkills
        local linkedSkillInfo = linkedSkills[newAbility]
        if type(linkedSkillInfo) == "table" then
            for _, linkedSkill in pairs(linkedSkillInfo) do
                local linkedAbility = hero:AddAbility(linkedSkill)
                linkedAbility:SetLevel(linkedAbility:GetMaxLevel())
            end
        elseif linkedSkillInfo ~= nil then
            local linkedSkill = linkedSkillInfo
            local linkedAbility = hero:AddAbility(linkedSkill)
            linkedAbility:SetLevel(linkedAbility:GetMaxLevel())
        end
        
        -- Для аганимных и шардовых скиллов
        if hero:HasModifier("modifier_item_ultimate_scepter_consumed") then
            hero:RemoveModifierByName("modifier_item_ultimate_scepter_consumed")
        end
        hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {
            bonus_all_stats = 0,
            bonus_health = 0,
            bonus_mana = 0
        })
        if hero:HasModifier("modifier_item_aghanims_shard") then
            hero:RemoveModifierByName("modifier_item_aghanims_shard")
        end
        hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", nil)
        
        if DEVELOPER_MODE == true then
            local skillTable = addedAbility:GetAbilityKeyValues()
            if skillTable ~= nil then
                CustomGameEventManager:Send_ServerToPlayer(player, "setSkillInfo", skillTable.AbilityValues)
            end
        end

    elseif command == "removeSkill" then
        local hero = player:GetAssignedHero()
        local removeAbility = keys.skillName
        hero:RemoveAbility(removeAbility)
        -- subSkills
        local subSkillInfo = subSkills[removeAbility]
        if type(subSkillInfo) == "table" then
            for _, subSkill in pairs(subSkillInfo) do
                local subAbility = hero:RemoveAbility(subSkill)
            end
        elseif subSkillInfo ~= nil then
            local subAbility = hero:RemoveAbility(subSkillInfo)
        end

        -- linkedSkills
        local linkedSkillInfo = linkedSkills[removeAbility]
        if type(linkedSkillInfo) == "table" then
            for _, linkedSkill in pairs(linkedSkillInfo) do
                local linkedAbility = hero:RemoveAbility(linkedSkill)
            end
        elseif linkedSkillInfo ~= nil then
            local linkedAbility = hero:RemoveAbility(linkedSkillInfo)
        end

    elseif command == "changeSkillParam" then
        local hero = player:GetAssignedHero()
        local paramInfo = keys.paramInfo
        local skillName = paramInfo.skillName
        local skillParam = paramInfo.skillParam
        local newValue = paramInfo.changedValue
        print("before")
        PrintTable(abilitiesAndVals)
        if abilitiesAndVals[skillName] == nil then
            abilitiesAndVals[skillName] = {[skillParam] = newValue}
        else
            abilitiesAndVals[skillName][skillParam] = newValue
        end
        print("after")
        PrintTable(abilitiesAndVals)
        CustomNetTables:SetTableValue("spell_amps_server", tostring(hero:GetPlayerOwnerID()), abilitiesAndVals)
    end
end

function GameMode:removeAttributeResistance(keys)
    if DISABLE_ATTRIBUTE_BONUSES then
        local npc = nil
        if keys.hero_entindex ~= nil then
            npc = EntIndexToHScript(keys.hero_entindex)
        elseif keys.entindex_killed ~= nil then
            npc = EntIndexToHScript(keys.entindex_killed)
        else
            -- именно PlayerID
            local player = PlayerResource:GetPlayer(keys.PlayerID)
            npc = player:GetAssignedHero()
        end

        if not npc:IsHero() then return end

        local neededHeroLevel = npc:GetLevel()
        -- print("Изначальный базовый резист:", npc:GetBaseMagicalResistanceValue())
        local heroIntGain = npc:GetIntellectGain()
        local gainedIntellect_neededLevel = heroIntGain * (neededHeroLevel - 1)
        local baseIntellect_firstLevel = (npc:GetBaseIntellect() - gainedIntellect_neededLevel)/xMultiplier
        -- print("Базовый интеллект на первом уровне:", baseIntellect_firstLevel, npc:GetBaseIntellect(), gainedIntellect_neededLevel, heroIntGain)
        if neededHeroLevel > 30 then
            neededHeroLevel = 30
            gainedIntellect_neededLevel = heroIntGain * (neededHeroLevel - 1)
        end
        local baseMagicResForInt = gameModeEntity:GetCustomAttributeDerivedStatValue(9)
        local finishBaseMagicResist = 25 + ((baseIntellect_firstLevel + gainedIntellect_neededLevel) * baseMagicResForInt) - (npc:GetIntellect(false) * baseMagicResForInt)
        npc:SetBaseMagicalResistanceValue(finishBaseMagicResist)
        -- print("Игровой базовый маг. резист от интеллекта:", (npc:GetIntellect(false) * baseMagicResForInt))
        -- print("Вычисленный базовый маг. резист:", 25 + ((baseIntellect_firstLevel + gainedIntellect_neededLevel) * baseMagicResForInt))
        -- print("Установка базового маг. резиста на:", finishBaseMagicResist)
        -- print("--------------------------------")

        neededHeroLevel = npc:GetLevel()
        -- print("Базовый армор героя + бонус от ловкости:", npc:GetPhysicalArmorBaseValue())
        -- print("Общий армор с базовым:", npc:GetPhysicalArmorValue(false))
        -- print("Общий армор без базового типа:", npc:GetPhysicalArmorValue(true))
        -- print("Прирост ловкости:", npc:GetAgilityGain())
        -- print("Общая ловкость:", npc:GetAgility())
        -- print("Базовая ловкость:", npc:GetBaseAgility())
        local baseArmorForAgi = gameModeEntity:GetCustomAttributeDerivedStatValue(4)
        
        local heroAgiGain = npc:GetAgilityGain()
        local gainedAgility_neededLevel = heroAgiGain * (neededHeroLevel - 1)
        local baseAgility_firstLevel = (npc:GetBaseAgility() - gainedAgility_neededLevel)/xMultiplier
        if neededHeroLevel > 30 then
            neededHeroLevel = 30
            gainedAgility_neededLevel = heroAgiGain * (neededHeroLevel - 1)
        end
        -- print("Базовая ловкость на первом уровне:", baseAgility_firstLevel)
        local reallyBaseArmor = npc.reallyBaseArmor
        if reallyBaseArmor == nil then
            reallyBaseArmor = Round(npc:GetPhysicalArmorValue(false) - npc:GetPhysicalArmorValue(true) - (((baseAgility_firstLevel + gainedAgility_neededLevel) + (npc:GetAgility() - npc:GetBaseAgility()/xMultiplier)) * baseArmorForAgi), 0)
            npc.reallyBaseArmor = reallyBaseArmor
            -- print("Реальный базовый армор героя:", reallyBaseArmor)
        end
        -- print("Просчитанная броня героя:", reallyBaseArmor + ((baseAgility_firstLevel + gainedAgility_neededLevel) * baseArmorForAgi))
        local finishBaseArmor = reallyBaseArmor + ((baseAgility_firstLevel + gainedAgility_neededLevel) * baseArmorForAgi) - (npc:GetAgility() * baseArmorForAgi)
        npc:SetPhysicalArmorBaseValue(finishBaseArmor)
        -- print("--------------------------------")
    end
end

function onSetGameMode(eventSourceIndex, args)
    settings = {}
    parsed = args
    if parsed == nil then return end
    
    if (parsed.Gamemode == 'allRandom')    then ALL_RANDOM   = true else ALL_RANDOM    = false end
    if (tonumber(parsed.sameHero) == 1) then SAME_HERO = true else SAME_HERO = false end

    if (tonumber(parsed.disableAttackSpeedCap) == 1) then DISABLE_ATTACK_SPEED_CAP = true else DISABLE_ATTACK_SPEED_CAP = false end
    if (tonumber(parsed.disableAttributeBonuses) == 1) then DISABLE_ATTRIBUTE_BONUSES = true else DISABLE_ATTRIBUTE_BONUSES = false end
    if (tonumber(parsed.easyMode) == 1) then EASY_MODE = true else EASY_MODE = false end
    if (tonumber(parsed.ignoreMovespeedLimit) == 1) then IGNORE_MOVESPEED_LIMIT = true else IGNORE_MOVESPEED_LIMIT = false end
    if (tonumber(parsed.innateAllowed) == 1) then INNATE_ALLOWED = true else INNATE_ALLOWED = false end
    if (tonumber(parsed.buffCreeps) == 1)   then BUFF_CREEPS  = true else BUFF_CREEPS   = false end
    if (tonumber(parsed.buffTowers) == 1)   then BUFF_TOWERS  = true else BUFF_TOWERS   = false end
    if (tonumber(parsed.buffStats) == 1)   then BUFF_STATS   = true else BUFF_STATS    = false end
    if (tonumber(parsed.fastRespawn) == 1)   then FAST_RESPAWN = true else FAST_RESPAWN  = false end
    if (tonumber(parsed.Omg) == 1)  then RANDOM_OMG   = true else RANDOM_OMG    = false end
    if (tonumber(parsed.developerMode) == 1)  then DEVELOPER_MODE   = true else DEVELOPER_MODE    = false end
    if (tonumber(parsed.customHeroMode) == 1)  then CUSTOM_HERO_MODE   = true else CUSTOM_HERO_MODE    = false end
    if (tonumber(parsed.disableFOG) == 1)  then disableFOG   = true else disableFOG    = false end
    if (tonumber(parsed.Multicast) == 1)   then MULTICAST    = true else MULTICAST     = false end
    if (tonumber(parsed.freeScepter) == 1)   then FREE_SCEPTER    = true else FREE_SCEPTER     = false end
    if (tonumber(parsed.maxLvl) == 1)   then MAX_LEVEL_BOOL   = true else MAX_LEVEL_BOOL    = false end
    if (tonumber(parsed.creepsSkills) == 1)   then CREEPS_SKILLS_BOOL   = true else CREEPS_SKILLS_BOOL     = false end
    if parsed.precacheParticles == 0 then PRECACHE_PARTICLES = false else PRECACHE_PARTICLES = true end
    if (tonumber(parsed.xChance) == 1)   then xChance = true else xChance = false end
    if (tonumber(parsed.xSlow) == 1) then xSlow = true else xSlow = false end
    if (tonumber(parsed.xIllusion) == 1) then xIllusion = true else xIllusion = false end
    if (tonumber(parsed.xArmor) == 1) then xArmor = true else xArmor = false end
    if (tonumber(parsed.omgDM) == 1) then DM_OMG = true else DM_OMG = false end

    maxUlts   = parsed.totalUltis
    maxSlots  = parsed.totalSkills
    maxSkills = maxSlots - maxUlts

    xMultiplier = parsed.Multiplier
    xCooldown = parsed.Cooldown
    xRadius = parsed.Radius
    xRange = parsed.Range
    xDuration = parsed.Duration
    xAbilityCastRange = parsed.abilityCastRange
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

    -- именно здесь, так как настраивали
    gameModeEntity:SetFogOfWarDisabled(disableFOG)
    gameModeEntity:SetUseCustomHeroLevels(MAX_LEVEL_BOOL)

    if PRECACHE_PARTICLES == true then
        GameRules:SetHeroSelectionTime(HERO_SELECTION_TIME + 15)
    else
        GameRules:SetHeroSelectionTime(HERO_SELECTION_TIME)
    end
end

function OnNonHostConnected(eventSourceIndex, args)
  local cplyID = args.PlayerID
  local rplayer = PlayerResource:GetPlayer(cplyID)
  if cplyID == nil then
    return
  end
  if parsed == nil then
    return
  end
  CustomGameEventManager:Send_ServerToPlayer(rplayer, "PlayerConnected", parsed)
end

function OnHostConnected(eventSourceIndex, args)
  local cplyID = args.PlayerID
  local rplayer = PlayerResource:GetPlayer(cplyID)
  CustomGameEventManager:Send_ServerToPlayer(rplayer, "HostPlayerConnected", DEFAULT_MODE_SETTINGS)
end

function GameMode:MultiplyTowers()
  print("Improving fontain!")
  -- loop over all fountains
  local fountain = Entities:FindByClassname(nil, "ent_dota_fountain")
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
      fountain = Entities:FindByClassname(fountain, "ent_dota_fountain")
  end

  print("Improving towers!")
  -- improve towers
  local tower = Entities:FindByClassname(nil, "npc_dota_tower")
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
  local rax = Entities:FindByClassname(nil, "npc_dota_barracks")
  while rax do
    rax:SetBaseMaxHealth(rax:GetBaseMaxHealth() * xMultiplier)
    rax:SetMaxHealth(rax:GetMaxHealth() * xMultiplier)
    rax:SetHealth(rax:GetHealth() * xMultiplier)
    rax:SetPhysicalArmorBaseValue(rax:GetPhysicalArmorBaseValue() * xMultiplier)
    rax = Entities:FindByClassname(rax, "npc_dota_barracks")
  end

  print("Improving ancient!")
  -- improve ancient
  local ancient = Entities:FindByClassname(nil, "npc_dota_fort")
  while ancient do
    ancient:SetBaseHealthRegen(ancient:GetHealth() / 100)
    ancient:SetBaseMaxHealth((ancient:GetBaseMaxHealth() * xMultiplier))
    ancient:SetMaxHealth(ancient:GetMaxHealth() * xMultiplier)
    ancient:SetHealth(ancient:GetHealth() * xMultiplier)
    ancient:SetPhysicalArmorBaseValue(ancient:GetPhysicalArmorBaseValue() * (xMultiplier / 2))
    ancient = Entities:FindByClassname(ancient, "npc_dota_fort")
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

function GameMode:GiveRandomSkills(hero, IsTempestDouble)
    local playerID = hero:GetPlayerOwnerID()
    print("IsTempestDouble", IsTempestDouble)
    if IsTempestDouble == true then
        SkillHandler:SetTempestDoubleSkills(hero)
    else
        SkillHandler:randomSkillsWork(hero, maxSkills, maxUlts, playerID)
    end
end

function CheckNPCParams(hero)
    -- if hero:IsClone() or hero:IsSummoned() or hero:IsPhantom() or hero:IsIllusion() or hero:IsTempestDouble() or
    -- hero:IsCreep() or hero:IsOther() then return false end
    -- if not hero:IsRealHero() then return false end
    if hero:IsCreep() == true then return end

    npcName = hero:GetUnitName()
    print("npc start spawn:", npcName)
    print(hero:IsClone(), "IsClone")
    print(hero:IsSummoned(), "IsSummoned")
    print(hero:IsPhantom(), "IsPhantom")
    print(hero:IsIllusion(), "IsIllusion")
    print(hero:IsTempestDouble(), "IsTempestDouble")
    print(hero:IsCreep(), "IsCreep")
    print(hero:IsOther(), "IsOther")
    print(hero:IsHero(), "IsHero")
    print(hero:IsRealHero(), "IsRealHero")
    print(hero:IsConsideredHero(), "IsConsideredHero")
    print(hero:IsControllableByAnyPlayer(), "IsControllableByAnyPlayer")
    print(hero:IsCreature(), "IsCreature")
    print(hero:IsCreepHero(), "IsCreepHero")
    print(hero:IsNeutralUnitType(), "IsNeutralUnitType")
    print(hero:IsOwnedByAnyPlayer(), "IsOwnedByAnyPlayer")
    print(hero:IsUnselectable(), "IsUnselectable")
    print(hero:IsZombie(), "IsZombie")
    print(hero:IsStrongIllusion(), "IsStrongIllusion")
    print(hero:IsPhantomBlocker(), "IsPhantomBlocker")
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

-- This function is called as the first player loads and sets up the GameMode parameters
function GameMode:_CaptureGameMode()
  if gameModeEntity == nil then
    -- Set GameMode parameters
    gameModeEntity = GameRules:GetGameModeEntity()

    gameModeEntity:SetRecommendedItemsDisabled(RECOMMENDED_BUILDS_DISABLED)
    gameModeEntity:SetTopBarTeamValuesOverride (USE_CUSTOM_TOP_BAR_VALUES)
    gameModeEntity:SetTopBarTeamValuesVisible(TOP_BAR_VISIBLE)
    gameModeEntity:SetBotThinkingEnabled(USE_STANDARD_DOTA_BOT_THINKING)
    gameModeEntity:SetTowerBackdoorProtectionEnabled(ENABLE_TOWER_BACKDOOR_PROTECTION)
    gameModeEntity:SetCustomXPRequiredToReachNextLevel(XP_LEVEL_TABLE)
    gameModeEntity:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
    gameModeEntity:SetAlwaysShowPlayerInventory(SHOW_ONLY_PLAYER_INVENTORY)
    gameModeEntity:SetAnnouncerDisabled(DISABLE_ANNOUNCER)
    gameModeEntity:SetFixedRespawnTime(FIXED_RESPAWN_TIME) 
    gameModeEntity:SetFountainConstantManaRegen(FOUNTAIN_CONSTANT_MANA_REGEN)
    gameModeEntity:SetFountainPercentageHealthRegen(FOUNTAIN_PERCENTAGE_HEALTH_REGEN)
    gameModeEntity:SetFountainPercentageManaRegen(FOUNTAIN_PERCENTAGE_MANA_REGEN)
    gameModeEntity:SetLoseGoldOnDeath(LOSE_GOLD_ON_DEATH)
    gameModeEntity:SetStashPurchasingDisabled (DISABLE_STASH_PURCHASING)
    gameModeEntity:SetUnseenFogOfWarEnabled(USE_UNSEEN_FOG_OF_WAR)
    gameModeEntity:SetFreeCourierModeEnabled(FREE_COURIER_ENABLED)
    gameModeEntity:SetCanSellAnywhere(CAN_SELL_ANYWHERE)

    if DISABLE_ATTACK_SPEED_CAP then
        gameModeEntity:SetMaximumAttackSpeed(999999)
    end

    self:OnFirstPlayerLoaded()
  end
end