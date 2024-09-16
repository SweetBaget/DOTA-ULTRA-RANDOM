-- In this file you can set up all the properties and settings for your game mode.
ADDON_NAME = 'ULTIMATE RANDOM DOTA'

FREE_COURIER_ENABLED = true

SAME_HERO = true
DISABLE_ATTACK_SPEED_CAP = true
MAX_LEVEL = 138
CREEPS_SKILLS_BOOL = false

ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = true             -- Should the main shop contain Secret Shop items as well as regular items

HERO_SELECTION_TIME = 20              -- How long should we let people select their hero?
PRE_GAME_TIME = 60.0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- How long should we let people look at the scoreboard before closing the server automatically?

GOLD_PER_TICK = 1                     -- How much gold should players get per tick?
GOLD_TICK_TIME = 0.6                      -- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = false     -- Should we disable the recommened builds for heroes

CUSTOM_BUYBACK_COST_ENABLED = false      -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = false  -- Should we use a custom buyback time?
BUYBACK_ENABLED = true                 -- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = false     -- Should we disable fog of war entirely for both teams?
USE_UNSEEN_FOG_OF_WAR = false           -- Should we make unseen and fogged areas of the map completely black until uncovered by each team? 
                                            -- Note: DISABLE_FOG_OF_WAR_ENTIRELY must be false for USE_UNSEEN_FOG_OF_WAR to work
USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = true    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

USE_CUSTOM_TOP_BAR_VALUES = true        -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = true                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = true             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = true-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?

END_GAME_ON_KILLS = false                -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 50         -- How many kills for a team should signify an end of game?

ENABLE_FIRST_BLOOD = true               -- Should we enable first blood for the first kill in this game?
HIDE_KILL_BANNERS = false               -- Should we hide the kill banners that show when a player is killed?
LOSE_GOLD_ON_DEATH = true               -- Should we have players lose the normal amount of dota gold on death?
SHOW_ONLY_PLAYER_INVENTORY = false      -- Should we only allow players to see their own inventory even when selecting other units?
DISABLE_STASH_PURCHASING = false        -- Should we prevent players from being able to buy items into their stash when not at a shop?
DISABLE_ANNOUNCER = false               -- Should we disable the announcer from working in the game?
FORCE_PICKED_HERO = nil                 -- What hero should we force all players to spawn as? (e.g. "npc_dota_hero_axe").  Use nil to allow players to pick their own hero.

FIXED_RESPAWN_TIME = -1                 -- What time should we use for a fixed respawn timer?  Use -1 to keep the default dota behavior.
FOUNTAIN_CONSTANT_MANA_REGEN = -1       -- What should we use for the constant fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_MANA_REGEN = -1     -- What should we use for the percentage fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_HEALTH_REGEN = -1   -- What should we use for the percentage fountain health regen?  Use -1 to keep the default dota behavior.

-- NOTE: You always need at least 2 non-bounty (non-regen while broken) type runes to be able to spawn or your game will crash!
-- ENABLED_RUNES = {}                      -- Which runes should be enabled to spawn in our game mode?
-- ENABLED_RUNES[DOTA_RUNE_DOUBLEDAMAGE] = true
-- ENABLED_RUNES[DOTA_RUNE_HASTE] = true
-- ENABLED_RUNES[DOTA_RUNE_ILLUSION] = true
-- ENABLED_RUNES[DOTA_RUNE_INVISIBILITY] = true
-- ENABLED_RUNES[DOTA_RUNE_REGENERATION] = true -- Regen runes are currently not spawning as of the writing of this comment
-- ENABLED_RUNES[DOTA_RUNE_BOUNTY] = true


MAX_NUMBER_OF_TEAMS = 2                -- How many potential teams can be in this game mode?
USE_CUSTOM_TEAM_COLORS = false          -- Should we use custom team colors?
USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS = false          -- Should we use custom team colors to color the players/minimap?

-- Fill this table up with the required XP per level if you want to change it
XP_LEVEL_TABLE = {}
XP_LEVEL_TABLE[0] = nil
XP_LEVEL_TABLE[1] =  0
XP_LEVEL_TABLE[2] =  240
XP_LEVEL_TABLE[3] =  640
XP_LEVEL_TABLE[4] =  1160
XP_LEVEL_TABLE[5] =  1760
XP_LEVEL_TABLE[6] =  2440
XP_LEVEL_TABLE[7] =  3200
XP_LEVEL_TABLE[8] =  4000
XP_LEVEL_TABLE[9] =  4900
XP_LEVEL_TABLE[10] =  5900
XP_LEVEL_TABLE[11] =  7000
XP_LEVEL_TABLE[12] =  8200
XP_LEVEL_TABLE[13] =  9500
XP_LEVEL_TABLE[14] =  10900
XP_LEVEL_TABLE[15] =  12400
XP_LEVEL_TABLE[16] =  14000
XP_LEVEL_TABLE[17] =  15700
XP_LEVEL_TABLE[18] =  17500
XP_LEVEL_TABLE[19] =  19400
XP_LEVEL_TABLE[20] =  21400
XP_LEVEL_TABLE[21] =  23600
XP_LEVEL_TABLE[22] =  26000
XP_LEVEL_TABLE[23] =  28600
XP_LEVEL_TABLE[24] =  31400
XP_LEVEL_TABLE[25] =  34400
XP_LEVEL_TABLE[26] =  38400
XP_LEVEL_TABLE[27] =  43400
XP_LEVEL_TABLE[28] =  49400
XP_LEVEL_TABLE[29] =  56400
XP_LEVEL_TABLE[30] =  63900
if MAX_LEVEL > 30 then
	for i=31,MAX_LEVEL do
		XP_LEVEL_TABLE[i] = XP_LEVEL_TABLE[i-1]*1.1
	end
end		
-- XP_PER_LEVEL_TABLE = {}
-- XP_PER_LEVEL_TABLE[0] = 0
-- for i=1,MAX_LEVEL do
--   XP_PER_LEVEL_TABLE[i] = XP_LEVEL_TABLE[i] + XP_PER_LEVEL_TABLE[i-1]
-- end
-- XP_PER_LEVEL_TABLE[0] = nil

TEAM_COLORS = {}                        -- If USE_CUSTOM_TEAM_COLORS is set, use these colors.
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 }  --    Teal
TEAM_COLORS[DOTA_TEAM_BADGUYS]  = { 243, 201, 9 }   --    Yellow
TEAM_COLORS[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }  --    Pink
TEAM_COLORS[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }   --    Orange
TEAM_COLORS[DOTA_TEAM_CUSTOM_3] = { 52, 85, 255 }   --    Blue
TEAM_COLORS[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }  --    Green
TEAM_COLORS[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }   --    Brown
TEAM_COLORS[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }  --    Cyan
TEAM_COLORS[DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }  --    Olive
TEAM_COLORS[DOTA_TEAM_CUSTOM_8] = { 140, 42, 244 }  --    Purple

PLAYER_COLORS = {}															-- Stores individual player colors
PLAYER_COLORS[0] = { 64, 128, 208 }
PLAYER_COLORS[1]  = { 88, 224, 160 }
PLAYER_COLORS[2] = { 160, 0, 160 }
PLAYER_COLORS[3] = { 208, 208, 8 }
PLAYER_COLORS[4] = { 224, 96, 0 }
PLAYER_COLORS[5] = { 0, 252, 64 }
PLAYER_COLORS[6] = { 56, 0, 116 }
PLAYER_COLORS[7] = { 252, 0, 128 }
PLAYER_COLORS[8] = { 244, 124, 0 }
PLAYER_COLORS[9] = { 120, 120, 0 }
PLAYER_COLORS[10] = { 220, 116, 168 }
PLAYER_COLORS[11]  = { 116, 128, 48 }
PLAYER_COLORS[12] = { 88, 188, 228 }
PLAYER_COLORS[13] = { 0, 112, 28 }
PLAYER_COLORS[14] = { 136, 84, 0 }
PLAYER_COLORS[15] = { 244, 124, 244 }
PLAYER_COLORS[16] = { 240, 0, 0 }
PLAYER_COLORS[17] = { 248, 128, 0 }
PLAYER_COLORS[18] = { 224, 184, 24 }
PLAYER_COLORS[19] = { 160, 255, 96 }

USE_AUTOMATIC_PLAYERS_PER_TEAM = false   -- Should we set the number of players to 10 / MAX_NUMBER_OF_TEAMS?

CUSTOM_TEAM_PLAYER_COUNT = {}           -- If we're not automatically setting the number of players per team, use this table
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 5
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 5
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_1] = 0
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_2] = 0
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_3] = 0
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_4] = 0
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_5] = 0
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_6] = 0
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_7] = 0
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_8] = 0

-- Custom maps settings
PW_PLAYERS_ON_GAME = 10
mapName = GetMapName()

DEFAULT_MODE_SETTINGS = {}
DEFAULT_MODE_SETTINGS.gamemode = "ap" 	-- GAME MODE
DEFAULT_MODE_SETTINGS.same_hero = 1 --позволяет выбирать одинаковых героев
DEFAULT_MODE_SETTINGS.disableAttackSpeedCap = 1 --отключает порог макс. скорости атаки
DEFAULT_MODE_SETTINGS.buff_creeps = 1 			-- BUFF CREEPS
DEFAULT_MODE_SETTINGS.ignore_movespeed_limit = 0 	-- Игнорировать лимит скорости
DEFAULT_MODE_SETTINGS.INNATE_ALLOWED = 1 	-- Игнорировать лимит скорости
DEFAULT_MODE_SETTINGS.buff_stats = 1 			-- BUFF STATS
DEFAULT_MODE_SETTINGS.buff_towers = 1 			-- BUFF TOWERS
DEFAULT_MODE_SETTINGS.easy_mode = 0 			-- EASY MODE
DEFAULT_MODE_SETTINGS.fast_respawn = 1 			-- FAST RESPAWN
DEFAULT_MODE_SETTINGS.multicast = 0 	-- MULTICAST
DEFAULT_MODE_SETTINGS.omg = 1 			-- RAMDOM SKILLS
DEFAULT_MODE_SETTINGS.omgdm = 1 		-- CHANGE SKILLS ON DEATH
DEFAULT_MODE_SETTINGS.total_skills = 0.6 	-- TOTAL SKILLS
DEFAULT_MODE_SETTINGS.total_ultis = 0.2 -- TOTAL ULTS
DEFAULT_MODE_SETTINGS.free_scepter = 0 	-- FREE SCEPTER
DEFAULT_MODE_SETTINGS.creepsSkills = 0 --Включает умения юнитов
DEFAULT_MODE_SETTINGS.max_lvl = 1 --SET MAX LVL TO 95
DEFAULT_MODE_SETTINGS.DisableFOG = 0 --DISABLE FOG
DEFAULT_MODE_SETTINGS.radius = 0.2 --Радиус умений
DEFAULT_MODE_SETTINGS.multiplier = 0.6 --Множитель всей кастомки
DEFAULT_MODE_SETTINGS.duration = 0 --Радиус умений
DEFAULT_MODE_SETTINGS.cooldown = 0 --Множитель кулдаунов
DEFAULT_MODE_SETTINGS.abilitycastrange = 0.2 --Радиус умений
DEFAULT_MODE_SETTINGS.range = 0.2 --Множитель дальности умений (стрела мираны)
DEFAULT_MODE_SETTINGS.chance = 1 --игнор множ. шансов
DEFAULT_MODE_SETTINGS.slow = 1 --игнор множ. замедлений
DEFAULT_MODE_SETTINGS.xIllusion = 1 --игнор множ. иллюзий
DEFAULT_MODE_SETTINGS.xArmor = 1 --игнор множ. армора

-- Настройка опыта и золота за подбор руны богатства (если nil то не меняется)
BOUNTY_GOLD = nil
BOUNTY_XP   = nil