-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc
require('internal/util')
require('pw')
local npcHeroesKV = LoadKeyValues("scripts/npc/npc_heroes.txt")
local npcUnitsKV = LoadKeyValues("scripts/npc/npc_units.txt")

function Precache(context)
    -- Error без прогрузки
    PrecacheResource("model", "models/heroes/muerta/muerta_ult.vmdl", context)
    PrecacheResource("model", "models/heroes/hoodwink/hoodwink_tree_model.vmdl", context)
    PrecacheResource("model", "models/heroes/pangolier/pangolier_gyroshell2.vmdl", context)
    PrecacheResource("model", "models/heroes/pangolier/pangolier_gyroshel.vmdl", context)
    PrecacheResource("model", "models/heroes/pangolier/pangolier_gyroshell2_rubick.vmdl", context)
    PrecacheResource("model", "models/heroes/pangolier/pangolier_round.vmdl", context)

    PrecacheResource("particle_folder", "particles/base_attacks", context)
    PrecacheResource("particle_folder", "particles/neutral_fx", context)
    PrecacheResource("model_folder", "models/props_gameplay", context)

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
                -- if string.match(unitInfo.Model, "models/heroes/") ~= nil then
                PrecacheResource("model", unitInfo.Model, context)
                -- end
            end
        end
    end
end

-- Create the game mode when we activate
function Activate()
    LinkLuaModifier("modifier_movespeed_cap", "modifiers/modifier_movespeed_cap.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_item_linken_king_bar_sphere", "modifiers/modifier_item_linken_king_bar_sphere.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_item_linken_king_bar_active", "modifiers/modifier_item_linken_king_bar_active.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_item_bladeheart_mail_active", "modifiers/modifier_item_bladeheart_mail_active.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_item_bladeheart_mail_passive", "modifiers/modifier_item_bladeheart_mail_passive.lua", LUA_MODIFIER_MOTION_NONE)
    
   GameRules.GameMode = GameMode()
   GameRules.GameMode:InitGameMode()
end