function Precache(context)
    local npcHeroesKV = LoadKeyValues("scripts/npc/npc_heroes.txt")
    for heroName, heroInfo in pairs(npcHeroesKV) do
        if type(heroInfo) == "table" then
            if heroInfo.particle_folder ~= nil then
                PrecacheResource("particle_folder", heroInfo.particle_folder, context)
            end
        end
    end
end
