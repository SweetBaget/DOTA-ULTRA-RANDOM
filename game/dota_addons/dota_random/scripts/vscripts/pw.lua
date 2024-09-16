BAREBONES_DEBUG_SPEW = false 

if GameMode == nil then
    _G.GameMode = class({})
end

-- skill Handler
require('libraries/skill_handler')


-- This library allow for easily delayed/timed actions
require('libraries/timers')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')

require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')
require('internal/multicast')

function GameMode:OnFirstPlayerLoaded()
end

function GameMode:OnAllPlayersLoaded()
  SkillHandler:getAbiltiesInfo()

  if ALL_RANDOM then
    GameMode:FillPlayersTable()
    GameMode:PerformAllRandom()
  end

  GameMode:MultiplyTowers()
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  print("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  -- Рандомит скиллы появившихся персонажей
  if RANDOM_OMG then
    GameMode:GiveRandomSkills(hero)
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

  GameMode:ModifierInizialize(hero)
  print(#hero:FindAllModifiers(), "длина хуйя")
  for _, mod in pairs(hero:FindAllModifiers()) do
    print(_, mod:GetName())
  end
end

function GameMode:OnHeroRespawned(hero)
  if DM_OMG == true and hero:IsReincarnating() == false then
    GameMode:GiveRandomSkills(hero)
  end
end

function GameMode:OnGameInProgress()
end

function GameMode:InitGameMode()
  GameMode = self
  GameMode:_InitGameMode()
end