-- Current object to export
require("modifiers/modifier_spells_randomize_values")

local skills = {}
local skills_SHARD = {}
local skills_AGHANIM = {}
local skills_SHARD_AGHANIM = {}
local ultimates = {}
local ultimates_SHARD = {}
local ultimates_AGHANIM = {}
local ultimates_SHARD_AGHANIM = {}

skillsList = {}
SkillHandler = {}
playerBuilds = {}
prevBuilds = {}
local innateAbilities = {}
-- local checkedAbilitiesDEV = {}

local badSkills = LoadKeyValues("scripts/kv/BannedSkills.kv")
SubSkills = LoadKeyValues("scripts/kv/SubSkills.kv")
LinkedSkills = LoadKeyValues("scripts/kv/LinkedSkills.kv")

-- По данным путям не должно лежать никаких файлов, инфа берется из игры
local npcHeroesKV = LoadKeyValues("scripts/npc/npc_heroes.txt")
local unitSkillsKV = LoadKeyValues("scripts/npc/npc_abilities.txt")

function SkillHandler:getAbiltiesInfo()
    print("Собираю информацию о всех скиллах")
    local allAbilities = {}

    --Собираю информацию по скиллам героев
    for heroName, v in pairs(npcHeroesKV) do
        if heroName ~= 'Version' and heroName ~= 'npc_dota_hero_base' then
            local abilsHero = LoadKeyValues("scripts/npc/heroes/" .. heroName .. ".txt")
            for abilityName, abilityInfo in pairs(abilsHero) do
                if abilityName ~= "Version" and not string.match(abilityName, "special_bonus") then
                    local IsInfoCollected = pcall(function()
                        abilityInfo["HeroName"] = heroName
                        allAbilities[abilityName] = abilityInfo
                    end)
                    if not IsInfoCollected then
                        print("Не удалось собрать информацию о скилле", abilityName)
                    end
                end
            end
        end
    end
    for abilityName, abilityInfo in pairs(allAbilities) do
        if badSkills[abilityName] == nil then
            if type(abilityInfo) == "table" then
                skillsList[abilityName] = {}
                skillsList[abilityName]["abilityName"] = abilityName
                skillsList[abilityName]["HeroName"] = abilityInfo["HeroName"]
                for k_ab, v_ab in pairs(abilityInfo) do
                    if k_ab == "IsGrantedByShard" then
                        skillsList[abilityName]["IsGrantedByShard"] = "1"
                    end
                    if k_ab == "IsGrantedByScepter" then
                        skillsList[abilityName]["IsGrantedByScepter"] = "1"
                    end
                    if k_ab == "AbilityType" and v_ab == "ABILITY_TYPE_ULTIMATE" then
                        skillsList[abilityName]["IsUltimate"] = "1"
                    end
                    if k_ab == "AbilityType" and v_ab == "ABILITY_TYPE_ATTRIBUTES" then
                        skillsList[abilityName]["IsAttributeBonus"] = "1"
                    end
                    if k_ab == "AbilityBehavior" and string.match(v_ab, "DOTA_ABILITY_BEHAVIOR_HIDDEN") then
                        skillsList[abilityName]["IsHidden"] = "1"
                    end
                    if k_ab == "AbilityBehavior" and string.match(v_ab, "DOTA_ABILITY_BEHAVIOR_ITEM") then
                        skillsList[abilityName]["IsItem"] = "1"
                    end
                    if k_ab == "AbilityBehavior" and string.match(v_ab, "DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE") then
                        skillsList[abilityName]["IsNotLearnable"] = "1"
                    end
                    if k_ab == "AbilityBehavior" and string.match(v_ab, "DOTA_ABILITY_BEHAVIOR_INNATE_UI") then
                        skillsList[abilityName]["IsInnateUI"] = "1"
                    end
                    if k_ab == "Innate" and v_ab == 1 then
                        skillsList[abilityName]["IsWorkingInnate"] = "1"
                    end
                end
                if skillsList[abilityName]["IsInnateUI"] == "1" and skillsList[abilityName]["IsWorkingInnate"] == nil then
                    skillsList[abilityName]["IsBrokenInnate"] = "1"
                end
            end
        end
    end

    --Собираю информацию по всем прочим скиллам
    if CREEPS_SKILLS_BOOL then
        for abilityName, abilityInfo in pairs(unitSkillsKV) do
            if not string.match(abilityName, "special_bonus") and 
                not string.match(abilityName, "courier") and 
                not string.match(abilityName, "_release") and 
                not string.match(abilityName, "cny2015") and 
                not string.match(abilityName, "greevil_") and 
                not string.match(abilityName, "empty") and 
                not string.match(abilityName, "creep_") and 
                not string.match(abilityName, "roshan_halloween") and 
                not string.match(abilityName, "ability") and 
                not string.match(abilityName, "seasonal") and 
                not string.match(abilityName, "frostivus2018") and 
                not string.match(abilityName, "cny_") and 
                not string.match(abilityName, "portal_warp") and 
                badSkills[abilityName] == nil then

                if type(abilityInfo) == "table" then
                    skillsList[abilityName] = {}
                    skillsList[abilityName]["abilityName"] = abilityName
                    for k_ab, v_ab in pairs(abilityInfo) do
                        if k_ab == "IsGrantedByShard" then
                            skillsList[abilityName]["IsGrantedByShard"] = "1"
                        end
                        if k_ab == "IsGrantedByScepter" then
                            skillsList[abilityName]["IsGrantedByScepter"] = "1"
                        end
                        if k_ab == "AbilityType" and v_ab == "ABILITY_TYPE_ULTIMATE" then
                            skillsList[abilityName]["IsUltimate"] = "1"
                        end
                        if k_ab == "AbilityType" and v_ab == "DOTA_ABILITY_TYPE_ATTRIBUTES" then
                            skillsList[abilityName]["IsAttributeBonus"] = "1"
                        end
                        if k_ab == "AbilityBehavior" and string.match(v_ab, "DOTA_ABILITY_BEHAVIOR_HIDDEN") then
                            skillsList[abilityName]["IsHidden"] = "1"
                        end
                        if k_ab == "AbilityBehavior" and string.match(v_ab, "DOTA_ABILITY_BEHAVIOR_ITEM") then
                            skillsList[abilityName]["IsItem"] = "1"
                        end
                        if k_ab == "AbilityBehavior" and string.match(v_ab, "DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE") then
                            skillsList[abilityName]["IsNotLearnable"] = "1"
                        end
                        if k_ab == "AbilityBehavior" and string.match(v_ab, "DOTA_ABILITY_BEHAVIOR_INNATE_UI") then
                            skillsList[abilityName]["IsInnateUI"] = "1"
                        end
                        if k_ab == "Innate" and v_ab == 1 then
                            skillsList[abilityName]["IsWorkingInnate"] = "1"
                        end
                    end
                    if skillsList[abilityName]["IsInnateUI"] == "1" and skillsList[abilityName]["IsWorkingInnate"] == nil then
                        skillsList[abilityName]["IsBrokenInnate"] = "1"
                    end
                end
            end
        end
    end

    print(GetListLenght(skillsList), "длина списка умений 111")
    for i, skillInfo in pairs(skillsList) do
        local abilityName = skillInfo["abilityName"]
        if skillInfo["IsHidden"] ~= "1" and skillInfo["IsAttributeBonus"] ~= "1" and
        skillInfo["IsItem"] ~= "1" and skillInfo["IsNotLearnable"] ~= "1" and skillInfo["IsBrokenInnate"] ~= "1" then
            --Врожденные способности
            if skillInfo["IsWorkingInnate"] == "1" then
                table.insert(innateAbilities, abilityName)

            --обычные скиллы
            elseif skillInfo["IsGrantedByShard"] == "1" and skillInfo["IsUltimate"] == nil then
                table.insert(skills_SHARD, abilityName)
            elseif skillInfo["IsGrantedByScepter"] == "1" and skillInfo["IsUltimate"] == nil then
                table.insert(skills_AGHANIM, abilityName)
            elseif skillInfo["IsUltimate"] == nil and skillInfo["IsGrantedByScepter"] == nil and skillInfo["IsGrantedByShard"] == nil then
                table.insert(skills, abilityName)

            --ульты
            elseif skillInfo["IsGrantedByScepter"] == nil and skillInfo["IsGrantedByShard"] == "1" and skillInfo["IsUltimate"] == "1" then
                table.insert(ultimates_SHARD, abilityName)
            elseif skillInfo["IsGrantedByScepter"] == "1" and skillInfo["IsGrantedByShard"] == nil and skillInfo["IsUltimate"] == "1" then
                table.insert(ultimates_AGHANIM, abilityName)
            elseif skillInfo["IsUltimate"] == "1" and skillInfo["IsGrantedByScepter"] == nil and skillInfo["IsGrantedByShard"] == nil then
                table.insert(ultimates, abilityName)
            end
        end
    end

    -- так как в аргументы передается сама таблица а не ссылка на нее, то нужно сделать копию, чтобы не похерить оригинал
    local _ultimates = table.copy(ultimates)
    local _skills = table.copy(skills)
    skills_SHARD_AGHANIM = TableConcat3(_skills, skills_SHARD, skills_AGHANIM)
    ultimates_SHARD_AGHANIM = TableConcat3(_ultimates, ultimates_SHARD, ultimates_AGHANIM)
    _skills = nil
    _ultimates = nil


    -- так как передается сама таблица, я могу сразу передать модифицируемую таблицу, а не приравнивать
    TableConcat(skills_SHARD, skills)
    TableConcat(skills_AGHANIM, skills)
    TableConcat(ultimates_SHARD, ultimates)
    TableConcat(ultimates_AGHANIM, ultimates)
end

local simpleHeroList = {}
for k,v in pairs(npcHeroesKV) do
    if k ~= 'Version' and k ~= 'npc_dota_hero_base' then
        if v.HeroID then
            table.insert(simpleHeroList, k)
        end
    end
end

function SkillHandler:getRandomHero()
    local rand = math.random(#simpleHeroList)
    local heroName = simpleHeroList[rand]
    return heroName
end

local rerollAghanim
local rerollShard
function SkillHandler:getRandomSkill(hero)
    rerollAghanim = false
    rerollShard = false
    --Если у героя есть шард а аганима нет
    if hero:HasModifier("modifier_item_aghanims_shard") and
    not (hero:HasModifier("modifier_item_ultimate_scepter") or hero:HasModifier("modifier_item_ultimate_scepter_consumed")) then
        rerollShard = true
        local rand = math.random(#skills_SHARD)
        return skills_SHARD[rand]
    --Если у героя есть шард и есть аганим
    elseif (hero:HasModifier("modifier_item_ultimate_scepter") or hero:HasModifier("modifier_item_ultimate_scepter_consumed")) and 
    hero:HasModifier("modifier_item_aghanims_shard") then
        rerollAghanim = true
        rerollShard = true
        local rand = math.random(#skills_SHARD_AGHANIM)
        return skills_SHARD_AGHANIM[rand]
    --Если у героя нет шарда и есть аганим
    elseif (hero:HasModifier("modifier_item_ultimate_scepter") or hero:HasModifier("modifier_item_ultimate_scepter_consumed")) and 
    not hero:HasModifier("modifier_item_aghanims_shard") then
        rerollAghanim = true
        local rand = math.random(#skills_AGHANIM)
        return skills_AGHANIM[rand]
    else
        local rand = math.random(#skills)
        return skills[rand]
    end
end


function SkillHandler:getRandomUltimate(hero)
    --Если у героя есть шард а аганима нет
    if hero:HasModifier("modifier_item_aghanims_shard") and
    not (hero:HasModifier("modifier_item_ultimate_scepter") or hero:HasModifier("modifier_item_ultimate_scepter_consumed")) then
        rerollShard = true
        local rand = math.random(#ultimates_SHARD)
        return ultimates_SHARD[rand]
    --Если у героя есть шард и есть аганим
    elseif (hero:HasModifier("modifier_item_ultimate_scepter") or hero:HasModifier("modifier_item_ultimate_scepter_consumed")) and 
    hero:HasModifier("modifier_item_aghanims_shard") then
        rerollAghanim = true
        rerollShard = true
        local rand = math.random(#ultimates_SHARD_AGHANIM)
        return ultimates_SHARD_AGHANIM[rand]
    --Если у героя нет шарда и есть аганим
    elseif (hero:HasModifier("modifier_item_ultimate_scepter") or hero:HasModifier("modifier_item_ultimate_scepter_consumed")) and 
    not hero:HasModifier("modifier_item_aghanims_shard") then
        rerollAghanim = true
        local rand = math.random(#ultimates_AGHANIM)
        return ultimates_AGHANIM[rand]
    else
        local rand = math.random(#ultimates)
        return ultimates[rand]
    end
end

local function checkAbilityPlusPassive(hero, skill)
    local abilityIsPassive = false
    local isGoodSkill = true
    if not pcall(function() 
        local checkAbility = hero:AddAbility(skill)
        abilityIsPassive = checkAbility:IsPassive()
        hero:RemoveAbility(skill)
    end) then
        isGoodSkill = false
        return abilityIsPassive, isGoodSkill
    end
    return abilityIsPassive, isGoodSkill
end

function SkillHandler:insertBuildSkill(playerBuilds, skill, abilityIsPassive, isGoodSkill, playerID)
    if abilityIsPassive == true and isGoodSkill == true then
        table.insert(playerBuilds[playerID]["passives"], skill)
    elseif abilityIsPassive == false and isGoodSkill == true then
        table.insert(playerBuilds[playerID]["skills"], skill)
    end
end

function SkillHandler:addSubSkill(playerBuilds, skill, playerID)
    local subSkillInfo = SubSkills[skill]
    if type(subSkillInfo) == "table" then
        for _, subSkill in pairs(subSkillInfo) do
            self:insertBuildSkill(playerBuilds, subSkill, false, true, playerID)
        end
    elseif subSkillInfo ~= nil then
        local subSkill = subSkillInfo
        self:insertBuildSkill(playerBuilds, subSkill, false, true, playerID)
    end
end

local function addLinkedSkill(playerBuilds, skill, playerID)
    local linkedSkillInfo = LinkedSkills[skill]
    if type(linkedSkillInfo) == "table" then
        for _, linkedSkill in pairs(linkedSkillInfo) do
            playerBuilds[playerID]["LinkedSkills"][linkedSkill] = linkedSkill
        end
    elseif linkedSkillInfo ~= nil then
        local linkedSkill = linkedSkillInfo
        playerBuilds[playerID]["LinkedSkills"][linkedSkill] = linkedSkill
    end
end

function SkillHandler:getRandomSkills(playerBuilds, prevBuilds, abilsCount, ultimatesCount, hero, playerID)
    playerBuilds[playerID]["skills"] = {}
    playerBuilds[playerID]["passives"] = {}
    playerBuilds[playerID]["LinkedSkills"] = {}
    for i = 1, abilsCount do
        local skill
        local isGoodSkill
        local abilityIsPassive
        while true do
            isGoodSkill = true
            skill = self:getRandomSkill(hero)
            if not pcall(function() 
                abilityIsPassive, isGoodSkill = checkAbilityPlusPassive(hero, skill)
            end) then
                isGoodSkill = false
                if skill then
                    print(skill .. "абилка с ошибкой")
                else
                    print("Не определен скилл")
                end
            end
            -- Если скилла нет в прошлом билде, если скилла нет в этом билде, и в новом билде то заканчиваем перебор
            if prevBuilds[playerID] ~= nil then
                if TableContains(prevBuilds[playerID]["skills"], skill) or
                TableContains(prevBuilds[playerID]["LinkedSkills"], skill) or
                TableContains(prevBuilds[playerID]["passives"], skill) then
                    goto nextAbility
                end
            end
            
            if not TableContains(playerBuilds[playerID]["skills"], skill) and
            not TableContains(playerBuilds[playerID]["LinkedSkills"], skill) and
            not TableContains(playerBuilds[playerID]["passives"], skill)
            and isGoodSkill == true then
                break
            end

            ::nextAbility::
        end
        self:insertBuildSkill(playerBuilds, skill, abilityIsPassive, isGoodSkill, playerID)
        self:addSubSkill(playerBuilds, skill, playerID)
        addLinkedSkill(playerBuilds, skill, playerID)
    end
    if ultimatesCount > 0 then
        for i = 1, ultimatesCount do
            local ult
            local isGoodUlt
            local abilityIsPassive
            while true do
                isGoodUlt = true
                ult = self:getRandomUltimate(hero)
                print(ult)
                if not pcall(function() 
                    abilityIsPassive, isGoodUlt = checkAbilityPlusPassive(hero, ult)
                    print(abilityIsPassive, isGoodUlt)
                end) then
                    isGoodUlt = false
                    if ult then
                        print(ult .. "ульт с ошибкой")
                    else
                        print("Не определен ульт")
                    end
                end
                print(prevBuilds[playerID])
                -- Если скилла нет в прошлом билде, если скилла нет в этом билде, и в новом билде то заканчиваем перебор
                if prevBuilds[playerID] ~= nil then
                    if TableContains(prevBuilds[playerID]["skills"], ult) or
                    TableContains(prevBuilds[playerID]["LinkedSkills"], ult) or
                    TableContains(prevBuilds[playerID]["passives"], ult) then
                        goto nextUlt
                    end
                end

                if not TableContains(playerBuilds[playerID]["skills"], ult) and
                not TableContains(playerBuilds[playerID]["LinkedSkills"], ult) and
                not TableContains(playerBuilds[playerID]["passives"], ult)
                and isGoodUlt == true then
                    break
                end

                ::nextUlt::
            end
            self:insertBuildSkill(playerBuilds, ult, abilityIsPassive, isGoodUlt, playerID)
            self:addSubSkill(playerBuilds, ult, playerID)
            addLinkedSkill(playerBuilds, ult, playerID)
        end
    end
    if INNATE_ALLOWED then
        local newInnateAbil = innateAbilities[math.random(#innateAbilities)]
        playerBuilds[playerID]["skills"][newInnateAbil] = newInnateAbil
    end

    -- если есть скилл рубика в билде, то добавляю скиллы для его работоспособности
    -- if TableContains(playerBuilds[playerID]["skills"], "rubick_spell_steal") then
    --     -- значения смещаются
    --     table.insert(playerBuilds[playerID]["skills"], 4, "rubick_empty1")
    --     table.insert(playerBuilds[playerID]["skills"], 5, "rubick_empty2")
    -- end
end

local talentsCount = 0
function SkillHandler:removeAllSkills(hero)
    talentsCount = 0
    -- считает количество прокачанных талантов
    local abilityCount = hero:GetAbilityCount()
	for i=0, abilityCount+1 do
        local ability = hero:GetAbilityByIndex(i)
        if ability ~= nil then
            local abilityName = ability:GetAbilityName()
            if string.match(abilityName, "special_bonus") then
                if ability:GetLevel() > 0 then
                    talentsCount = talentsCount + ability:GetLevel()
                end
            end
        end
    end

    -- удаляет все абилки кроме талантов и специальных скиллов
    local abilityCount = hero:GetAbilityCount()
	for i=0, abilityCount do
        local ability = hero:GetAbilityByIndex(i)
        if ability ~= nil then
            local abilityName = ability:GetAbilityName()
            if not string.match(abilityName, "special_bonus") and not string.match(abilityName, "ability") and 
            not string.match(abilityName, "portal_warp") then --check
                if ability:GetToggleState() == true then
                    ability:ToggleAbility()
                end
                hero:RemoveAbility(abilityName)
                print(abilityName .. " удален")
            end
        end
    end
end

function SkillHandler:randomSkillsWork(hero, skillsCount, ultisCount, playerID)
    print('Skills for :' .. hero:GetUnitName())
    -- playerBuilds = {}
    if playerBuilds[playerID] == nil then
        playerBuilds[playerID] = {
            skills = {},
            passives = {},
            LinkedSkills = {}
        }
    end

    self:getRandomSkills(playerBuilds, prevBuilds, skillsCount, ultisCount, hero, playerID)
    print("getRandomSkills завершен")
    self:setSkills(playerBuilds, hero, playerID)
    print("setskills завершен")
    local level = hero:GetLevel()
    local givedAbilityPoints = level-talentsCount
    local sumAbilityLevels = 0
    --считаю сколько поинтов надо для прокачки всех скиллов
	local abilityCount = hero:GetAbilityCount()
	for i=1, abilityCount do
        local ability = hero:GetAbilityByIndex(i)
        if ability ~= nil then
            local abilityName = ability:GetAbilityName()
            if not string.match(abilityName, "special_bonus") and not string.match(abilityName, "ability") and not string.match(abilityName, "portal_warp") then
                sumAbilityLevels = sumAbilityLevels + ability:GetMaxLevel()
            end
        end
    end
    --Если количество поинтов которое должно быть выдано персонажу больше требуемогоо кол-во поинтов для прокачки скиллов, то прокачиваю все умения
    if givedAbilityPoints > sumAbilityLevels then
        local abilityCount = hero:GetAbilityCount()
	    for i=0, abilityCount+1 do
            local ability = hero:GetAbilityByIndex(i)
            if ability ~= nil then
                local abilityName = ability:GetAbilityName()
                if not string.match(abilityName, "special_bonus") and not string.match(abilityName, "ability") and not string.match(abilityName, "portal_warp") then
                    ability:SetLevel(ability:GetMaxLevel())
                end
            end
        end
        hero:SetAbilityPoints(givedAbilityPoints-sumAbilityLevels)
    else
        hero:SetAbilityPoints(level-talentsCount)
    end

    prevBuilds[playerID] = table.copy(playerBuilds[playerID])
end

function SkillHandler:SetTempestDoubleSkills(tempestHero)
    self:removeAllSkills(tempestHero)
    local generalHero = tempestHero:GetPlayerOwner():GetAssignedHero()
    local abilityCount = generalHero:GetAbilityCount()
    for i=0, abilityCount+1 do
        local ability = generalHero:GetAbilityByIndex(i)
        if ability ~= nil then
            local abilityName = ability:GetAbilityName()
            if not string.match(abilityName, "special_bonus") and not string.match(abilityName, "ability") and 
            not string.match(abilityName, "portal_warp") and abilityName ~= "arc_warden_tempest_double" then
                local newAbility = tempestHero:AddAbility(abilityName)
                newAbility:SetLevel(ability:GetLevel())
            end
        end
    end
end

function SkillHandler:setSkills(playerBuilds, hero, playerID)
    -- Сначала удалять скиллы или модификаторы??
    self:removeAllSkills(hero)
    -- Remove possible bugged modifiers at start
    hero:RemoveAllModifiers(0, true, true, true)

    -- Добавляет герою все полученные умения
    for indexSkill, skill in pairs(playerBuilds[playerID]["skills"]) do
        print(skill, "SetSkills")
        local ability = hero:AddAbility(skill)
        -- table.insert(checkedAbilitiesDEV, skill)
    end
    for indexSkill, skill in pairs(playerBuilds[playerID]["passives"]) do
        print(skill, "SetPassives")
        local ability = hero:AddAbility(skill)
        -- table.insert(checkedAbilitiesDEV, skill)
    end
    for indexSkill, skill in pairs(playerBuilds[playerID]["LinkedSkills"]) do
        print(skill, "SetLinked")
        local ability = hero:AddAbility(skill)
        ability:SetLevel(1)
        ability:SetHidden(true)
        -- table.insert(checkedAbilitiesDEV, skill)
    end

    -- Для работы аганима и шарда с новыми скиллами
    if rerollAghanim then
        if hero:HasModifier("modifier_item_ultimate_scepter") then
            hero:RemoveModifierByName("modifier_item_ultimate_scepter")
            hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter", {
                bonus_all_stats = 0,
                bonus_health = 0,
                bonus_mana = 0
            })
        end
        if hero:HasModifier("modifier_item_ultimate_scepter_consumed") then
            hero:RemoveModifierByName("modifier_item_ultimate_scepter_consumed")
            hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {
                bonus_all_stats = 0,
                bonus_health = 0,
                bonus_mana = 0
            })
        end
    end
    if rerollShard then
        hero:RemoveModifierByName("modifier_item_aghanims_shard")
        hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", nil)
    end
    
    --усиление новых умений
    -- GameMode:AddMultipleModifier(hero)
    -- hero:FindModifierByName("modifier_spells_randomize_values"):ForceRefresh()
end

function SkillHandler:TESTsetSkills(hero, skills)
    local abilityCount = hero:GetAbilityCount()
	for i=0, abilityCount do
        local ability = hero:GetAbilityByIndex(i)
        if ability ~= nil then
            local abilityName = ability:GetAbilityName()
            print(abilityName)
        end
    end
	for i=0, abilityCount do
        local ability = hero:GetAbilityByIndex(i)
        if ability ~= nil then
            local abilityName = ability:GetAbilityName()
            if ability:GetToggleState() == true then
                ability:ToggleAbility()
            end
            print(abilityName .. " удален")
            hero:RemoveAbility(abilityName)
        end
    end
    -- Добавляет герою все полученные умения
    -- for i=0, 18 do
        hero:AddAbility("keeper_of_the_light_illuminate")
        hero:AddAbility("keeper_of_the_light_blinding_light")
        hero:AddAbility("keeper_of_the_light_chakra_magic")
        hero:AddAbility("generic_hidden")
        hero:AddAbility("keeper_of_the_light_will_o_wisp")
        hero:AddAbility("keeper_of_the_light_spirit_form")
        hero:AddAbility("keeper_of_the_light_illuminate_end")
        hero:AddAbility("keeper_of_the_light_mana_magnifier")
        hero:AddAbility("generic_hidden")
        hero:AddAbility("generic_hidden")
        hero:AddAbility("special_bonus_unique_keeper_of_the_light_8")
        hero:AddAbility("special_bonus_unique_keeper_of_the_light_illuminate_cooldown")
        hero:AddAbility("special_bonus_unique_keeper_of_the_light_7")
        hero:AddAbility("special_bonus_unique_keeper_of_the_light_5")
        hero:AddAbility("special_bonus_unique_keeper_of_the_light_11")
        hero:AddAbility("special_bonus_unique_keeper_of_the_light_2")
        hero:AddAbility("special_bonus_unique_keeper_of_the_light_14")
        hero:AddAbility("special_bonus_unique_keeper_of_the_light")
        hero:AddAbility("special_bonus_attributes")
        -- local afterIndex = ability:GetAbilityIndex()
        -- hero:SetAbilityByIndex(ability, indexSkill - 1)
    -- end
end

-- SkillHandler = SkillHandler
