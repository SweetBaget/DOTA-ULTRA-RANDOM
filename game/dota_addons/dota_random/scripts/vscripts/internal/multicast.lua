print('[Multicast] Init')
Multicast = {}
local noMulticast = tempBanList.noMulticast
local multicastChannel = {}
local chanelledSpells = {}
local targetSpells = {}
local npcHeroesKV = LoadKeyValues("scripts/npc/npc_heroes.txt")
local npcAbilitiesKV = LoadKeyValues("scripts/npc/npc_abilities.txt")

local function SetupSpellProperties()
    for heroName, v in pairs(npcHeroesKV) do
        if heroName ~= 'Version' and heroName ~= 'npc_dota_hero_base' then
            local abilsHero = LoadKeyValues("scripts/npc/heroes/" .. heroName .. ".txt")
            for abilityName, abilityInfo in pairs(abilsHero) do
                if abilityName ~= "Version" and not string.match(abilityName, "special_bonus") then
                    if abilityInfo.AbilityBehavior then
                        if string.match(abilityInfo.AbilityBehavior, 'DOTA_ABILITY_BEHAVIOR_CHANNELLED') then
                            chanelledSpells[abilityName] = true
                        end
                        if string.match(abilityInfo.AbilityBehavior, 'DOTA_ABILITY_BEHAVIOR_UNIT_TARGET') then
                            targetSpells[abilityName] = true
                        end
                    end
                end
            end
        end
    end
    for k,v in pairs(npcAbilitiesKV) do
        if k ~= 'Version' and k ~= 'ability_base' then
            if v.AbilityBehavior then
                if string.match(v.AbilityBehavior, 'DOTA_ABILITY_BEHAVIOR_CHANNELLED') then
                    chanelledSpells[k] = true
                end
                if string.match(v.AbilityBehavior, 'DOTA_ABILITY_BEHAVIOR_UNIT_TARGET') then
                    targetSpells[k] = true
                end
            end
        end
    end
end

SetupSpellProperties()
local canMulticast = function(skillName)
    if noMulticast[skillName] then
        return false
    end
    return true
end

-- Stop multicast on weird stuff
local function isValidTargetEntity(ent)
    -- Ensure it's a valid entity
    if not IsValidEntity(ent) then return false end
    -- No buildings
    if ent:IsBuilding() then return false end
    if ent:IsTower() then return false end
    return true
end

local function isChannelled(skillName)
    if chanelledSpells[skillName] then
        return true
    end

    return false
end

-- Tells you if a given spell is target based one or not
local function isTargetSpell(skillName)
    if targetSpells[skillName] then
        return true
    end
    return false
end

ListenToGameEvent('dota_ability_channel_finished', function(eventInfo, canceled)
    for i=0,9 do
        PrintTable(multicastChannel)
        local channel = multicastChannel[i]
        if channel ~= nil then
            -- Grab the ability
            local castedAbility = channel.castedAbility
            local finishedAbilityName = eventInfo.abilityname

            -- Is this the ability we were looking for?
            if IsValidEntity(castedAbility) and castedAbility:GetAbilityName() == finishedAbilityName then
                print("нашел абилити ченел")
                GameRules:GetGameModeEntity():SetThink(function()
                    print("думаем 1")
                    -- Is it the right ability, and has the ability stopped channelling?
                    if IsValidEntity(castedAbility) and not castedAbility:IsChanneling() then
                        print("абилка ченелинг")
                        -- This channel is handled
                        channel.handled = true

                        -- Cleanup multicast units
                        if #channel.units > 0 then
                            print("больше нуля")
                            local unit = table.remove(channel.units, 1)

                            if IsValidEntity(unit) then
                                print("юнит норм")
                                local ab2 = unit:FindAbilityByName(finishedAbilityName)
                                if ab2 then
                                    print("ну все енд ченнел")
                                    ab2:EndChannel(canceled == 1)
                                end

                                GameRules:GetGameModeEntity():SetThink(function()
                                    UTIL_RemoveImmediate(unit)
                                end, 'channel'..DoUniqueString('channel'), 10, nil)
                            end

                            return 0.1
                        else
                            multicastChannel[i] = nil
                        end
                    end
                end, 'channel'..DoUniqueString('channel'), 0.1, nil)
            end
        end
    end
end, nil)

function Multicast:DoMulticast(keys)
	print('DoMulticast')
	PrintTable(keys)
	local ply = PlayerResource:GetPlayer(keys.PlayerID)
    if ply == nil then return end

    local hero = ply:GetAssignedHero()
    if hero == nil then return end

    local abilityName = keys.abilityname
    if canMulticast(abilityName) == false then return end

    local multicastData = GetAbilityKeyValuesByName("ogre_magi_multicast")
    local multicast_2_times = tonumber(string.sub(multicastData.AbilityValues.multicast_2_times.value, -2))
    local multicast_3_times = tonumber(string.sub(multicastData.AbilityValues.multicast_3_times.value, -2))
    local multicast_4_times = tonumber(string.sub(multicastData.AbilityValues.multicast_4_times.value, -2))

    local mult = 0
    local r = math.random(1, 100)
    if r <= multicast_4_times then
        mult = 4
    elseif r <= multicast_3_times then
        mult = 3
    elseif r <= multicast_2_times then
        mult = 2
    end
    if mult == 0 then return end

    local castedAbility = hero:FindAbilityByName(abilityName)
    local isItemAbility = false
    if not castedAbility then
        for i=0,5 do
            local slotItem = hero:GetItemInSlot(i)
            if slotItem and slotItem:GetClassname() == abilityName then
                castedAbility = slotItem
                isItemAbility = true
                break
            end
        end
    end
    if castedAbility == nil then return end
    local delay = 0.6
    local playerID = hero:GetPlayerID()

    if isChannelled(abilityName) then
        if multicastChannel[playerID] ~= nil then
            while #multicastChannel[playerID].units > 0 do
                local unit = table.remove(multicastChannel[playerID].units, 1)
                UTIL_RemoveImmediate(unit)
            end
        end

        -- Create new table
        multicastChannel[playerID] = {
            castedAbility = castedAbility,
            units = {}
        }

        for multNum=1, mult-1 do
            -- Create and store the unit
            local multUnit = CreateUnitByName("npc_multicast", hero:GetOrigin(), false, hero, hero, hero:GetTeamNumber())
            table.insert(multicastChannel[playerID].units, multUnit)
            if multUnit then
                multUnit:AddAbility(abilityName)
                local multAb = multUnit:FindAbilityByName(abilityName)
                if multAb then
                    -- Level the spell
                    multAb:SetLevel(castedAbility:GetLevel())

                    -- Ensure it can't be killed
                    -- local dummySpell = multUnit:FindAbilityByName('pw_dummy_unit')
                    -- if dummySpell then
                    --     dummySpell:SetLevel(1)
                    -- end
                    multUnit:AddNewModifier(multUnit, nil, 'modifier_invulnerable', {})
                    GameMode:ModifierInizialize(multUnit)
                    multUnit:FindModifierByName("modifier_spells_randomize_values"):ForceRefresh()

                    -- Give it a scepter, if we have one
                    if hero:HasModifier('modifier_item_ultimate_scepter') then
                        multUnit:AddNewModifier(multUnit, nil, 'modifier_item_ultimate_scepter', {
                            bonus_all_stats = 0,
                            bonus_health = 0,
                            bonus_mana = 0
                        })
                    end
                    if hero:HasModifier("modifier_item_aghanims_shard") then
                        multUnit:AddNewModifier(multUnit, nil, "modifier_item_aghanims_shard", nil)
                    end

                    local target = hero:GetCursorCastTarget()
                    local targets
                    local pos = hero:GetCursorPosition()

                    if target then
                        targets = FindUnitsInRadius(target:GetTeam(),
                            hero:GetOrigin(),
                            nil,
                            castedAbility:GetEffectiveCastRange(hero:GetOrigin(), nil) + .0,
                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                            DOTA_UNIT_TARGET_ALL,
                            DOTA_UNIT_TARGET_FLAG_NONE,
                            FIND_ANY_ORDER,
                            false
                        )
                    end

                    GameRules:GetGameModeEntity():SetThink(function()
                        if IsValidEntity(castedAbility) and castedAbility:IsChanneling() and IsValidEntity(multUnit) then
                            if target then
                                local newTarget
                                while #targets > 0 do
                                    newTarget = table.remove(targets, 1)
                                    if newTarget ~= target and isValidTargetEntity(newTarget) then
                                        break
                                    end
                                end
                                multUnit:CastAbilityOnTarget(newTarget, multAb, -1)
                            elseif pos then
                                multUnit:CastAbilityOnPosition(pos, multAb, -1)
                            else
                                UTIL_RemoveImmediate(multUnit)
                            end
                        else
                            UTIL_RemoveImmediate(multUnit)
                        end
                    end, 'channel'..DoUniqueString('channel'), 0.1, nil)
                else
                    UTIL_RemoveImmediate(multUnit)
                end
            end
        end
    else
        -- Grab the position
        local pos = hero:GetCursorPosition()
        local target = hero:GetCursorCastTarget()
        local isaTargetSpell = false

        local targets
        if target and isTargetSpell(abilityName) then
            isaTargetSpell = true
            targets = FindUnitsInRadius(target:GetTeam(),
                hero:GetOrigin(),
                nil,
                castedAbility:GetEffectiveCastRange(hero:GetOrigin(), nil) + .0,
                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false
            )
        end

        Timers:CreateTimer(delay, function()
            -- Ensure it still exists
            if IsValidEntity(castedAbility) then
                hero:SetCursorPosition(pos)

                local ourTarget = target
                if targets then
                    while #targets > 0 do
                        local index = math.random(#targets)
                        local t = targets[index]

                        if IsValidEntity(t) and t:GetHealth() > 0 and t ~= ourTarget and 
                        isValidTargetEntity(t) and hero:CanEntityBeSeenByMyTeam(t) then
                            ourTarget = t
                            break
                        else
                            table.remove(targets, index)
                        end
                    end
                end

                if isaTargetSpell then
                    if IsValidEntity(ourTarget) and ourTarget:GetHealth() > 0 then
                        hero:SetCursorCastTarget(ourTarget)
                    else
                        return
                    end
                end

                castedAbility:OnSpellStart()
                mult = mult-1
                if mult > 1 then
                    return delay
                end
            end
        end, DoUniqueString('multicast'))
    end

    -- Create sexy particles
    local prt = ParticleManager:CreateParticle('particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf', PATTACH_OVERHEAD_FOLLOW, hero)
    ParticleManager:SetParticleControl(prt, 1, Vector(mult, 0, 0))
    ParticleManager:ReleaseParticleIndex(prt)

    prt = ParticleManager:CreateParticle('particles/units/heroes/hero_ogre_magi/ogre_magi_multicast_b.vpcf', PATTACH_OVERHEAD_FOLLOW, hero:GetCursorCastTarget() or hero)
    prt = ParticleManager:CreateParticle('particles/units/heroes/hero_ogre_magi/ogre_magi_multicast_b.vpcf', PATTACH_OVERHEAD_FOLLOW, hero)
    ParticleManager:ReleaseParticleIndex(prt)

    prt = ParticleManager:CreateParticle('particles/units/heroes/hero_ogre_magi/ogre_magi_multicast_c.vpcf', PATTACH_OVERHEAD_FOLLOW, hero:GetCursorCastTarget() or hero)
    ParticleManager:SetParticleControl(prt, 1, Vector(mult, 0, 0))
    ParticleManager:ReleaseParticleIndex(prt)

    -- Play the sound
    hero:EmitSound('Hero_OgreMagi.Fireblast.x'..(mult-1))
end



