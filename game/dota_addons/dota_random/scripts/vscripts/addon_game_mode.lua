-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc
require('internal/util')
require('pw')
local npcHeroesKV = LoadKeyValues("scripts/npc/npc_heroes.txt")
local npcUnitsKV = LoadKeyValues("scripts/npc/npc_units.txt")

function Precache(context)
    for heroName, heroInfo in pairs(npcHeroesKV) do
        if type(heroInfo) == "table" then
            if heroInfo.GameSoundsFile ~= nil then
                PrecacheResource("soundfile", heroInfo.GameSoundsFile, context)
            end
            if heroInfo.precache ~= nil then
                if heroInfo.precache.model ~= nil then
                    PrecacheResource("model", heroInfo.precache.model, context)
                end
            end
        end
    end
    for unitName, unitInfo in pairs(npcUnitsKV) do
        if type(unitInfo) == "table" then
            if unitInfo.Model ~= nil then
                if string.match(unitInfo.Model, "models/heroes/") ~= nil then
                    PrecacheResource("model", unitInfo.Model, context)
                end
            end
        end
    end
end
LinkLuaModifier("modifier_movespeed_cap", "modifiers/modifier_movespeed_cap.lua", LUA_MODIFIER_MOTION_NONE)

-- Create the game mode when we activate
function Activate()
   GameRules.GameMode = GameMode()
   GameRules.GameMode:InitGameMode()
end