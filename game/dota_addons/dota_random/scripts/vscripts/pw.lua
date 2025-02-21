BAREBONES_DEBUG_SPEW = false
playerList = {}

if GameMode == nil then
    _G.GameMode = class({})
end

require('libraries/skill_handler')
require('libraries/timers')
require('internal/gamemode')
require('internal/events')
require('settings')
require('internal/multicast')

function GameMode:LoadPrecache()
    print("Performing Post-Load precache")
    SpawnEntityFromTableAsynchronous("logic_script", {
        vscripts = "precache.lua"
    }, {}, {})
end

function GameMode:OnFirstPlayerLoaded()
end

function GameMode:OnAllPlayersLoaded()
    SkillHandler:getAbiltiesInfo()
    -- CustomGameEventManager:Send_ServerToAllClients("fullSkillBox", skillsList)

    if ALL_RANDOM then
        GameMode:FillPlayersTable()
        GameMode:PerformAllRandom()
    end

    GameMode:MultiplyTowers()
end

function GameMode:HeroFirstTimeInGame(hero, IsTempestDouble)
    print("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

    local player = hero:GetPlayerOwner()
    local playerID = hero:GetPlayerOwnerID()
    if playerList[playerID] == nil then
        if DEVELOPER_MODE == false then
            CustomGameEventManager:Send_ServerToPlayer(player, "hideBox", {["boxName"] = "SkillParams"})
        end
        if CUSTOM_HERO_MODE == true then
            CustomGameEventManager:Send_ServerToPlayer(player, "fullSkillBox", skillsList)
        else
            CustomGameEventManager:Send_ServerToPlayer(player, "hideBox", {["boxName"] = "SkillHandler"})
        end
        playerList[playerID] = "aboba"
    end

    -- Рандомит скиллы появившихся персонажей
    if RANDOM_OMG then
        GameMode:GiveRandomSkills(hero, IsTempestDouble)
    end

    -- Снятие лимита на скорость передвижения
    if IGNORE_MOVESPEED_LIMIT then
        hero:AddNewModifier(hero, nil, "modifier_movespeed_cap", nil)
    end

    -- Усиление героев
    if BUFF_STATS then
        GameMode:MultiplyBaseStats(hero)
    end

    -- Применяет к игре легкий режим сложности
    if EASY_MODE then
        GameMode:ApplyEasyMode(hero)
    end

    if FREE_SCEPTER then
        hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {
        bonus_all_stats = 0,
        bonus_health = 0,
        bonus_mana = 0
        })
        hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", nil)
    end

    GameMode:AddMultipleModifier(hero)
end

function GameMode:OnHeroRespawned(hero, IsTempestDouble)
    if DM_OMG == true and hero:IsReincarnating() == false then
        GameMode:GiveRandomSkills(hero, IsTempestDouble)
    end
end

function GameMode:OnGameInProgress()
end

function GameMode:InitGameMode()
    GameMode = self
    GameMode:_InitGameMode()
end