function Precache(context)
    local npcHeroesKV = LoadKeyValues("scripts/npc/npc_heroes.txt")
    for heroName, heroInfo in pairs(npcHeroesKV) do
        HeroFolderName = string.gsub(heroName, "npc_dota_hero_", "")
        if type(heroInfo) == "table" then
            if heroInfo.particle_folder ~= nil then
                PrecacheResource("particle_folder", heroInfo.particle_folder, context)
            end
            -- PrecacheResource("model_folder", "models/heroes/" .. HeroFolderName, context)
        end
    end
end
