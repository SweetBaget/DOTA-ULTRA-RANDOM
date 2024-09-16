-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('pw')
local npcHeroesKV = LoadKeyValues("scripts/npc/npc_heroes.txt")
local npcUnitsKV = LoadKeyValues("scripts/npc/npc_units.txt")

local heroNames = {
   ["obsidian_destroyer"] = "outworld_destroyer",
   ["pangolier"] = "pangolin",
   ["abyssal_underlord"] = "underlord"
}

function Precache(context)
   print("startprecache")
   for heroName, heroInfo in pairs(npcHeroesKV) do
      if string.match(heroName, "npc_dota_hero_") then
         local heroNameShort = string.gsub(heroName, "npc_dota_hero_", "")

         PrecacheResource("soundfile", heroInfo.GameSoundsFile, context)
         if heroInfo.GameSoundsFile == nil then
            PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_" .. heroNameShort .. ".vsndevts", context)
            if heroNames[heroNameShort] ~= nil then
               PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_" .. heroNames[heroNameShort] .. ".vsndevts", context)
            end
         end
         PrecacheResource("particle_folder", heroInfo.particle_folder, context)
         if heroInfo.particle_folder == nil then
            PrecacheResource("particle_folder", "particles/units/heroes/hero_" .. heroNameShort, context)
            if heroNames[heroNameShort] ~= nil then
               PrecacheResource("particle_folder", "particles/units/heroes/hero_" .. heroNames[heroNameShort], context)
            end
         end
      end
   end
end

LinkLuaModifier("modifier_movespeed_cap", "modifiers/modifier_movespeed_cap", LUA_MODIFIER_MOTION_NONE) 
LinkLuaModifier("modifier_spells_randomize_values", "modifiers/modifier_spells_randomize_values", LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier("modifier_arc_warden_tempest_double", "modifiers/modifier_arc_warden_tempest_double", LUA_MODIFIER_MOTION_NONE)

-- Create the game mode when we activate
function Activate()
   GameRules.GameMode = GameMode()
   GameRules.GameMode:InitGameMode()
end