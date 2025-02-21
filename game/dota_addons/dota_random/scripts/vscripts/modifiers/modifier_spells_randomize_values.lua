modifier_spells_randomize_values = modifier_spells_randomize_values or class({})
abilitiesAndVals = {}

-------------------------MODIFIER's SETTINGS-------------------------
function modifier_spells_randomize_values:GetTexture() return "chaos_knight_chaos_strike" end
function modifier_spells_randomize_values:IsPermanent() return true end
function modifier_spells_randomize_values:RemoveOnDeath() return false end
function modifier_spells_randomize_values:IsHidden() return true end
function modifier_spells_randomize_values:IsDebuff() return false end

-------------------------INIT VALUES-------------------------
local slowValues = {
    ["broodmother_silken_bola"] = "movement_speed",
	["necrolyte_ghost_shroud"] = "movement_speed"
}

local exceptValues = {}
local whiteList = {}
local bannedSkills = {}

local exceptValuesKV = LoadKeyValues("scripts/kv/exceptValues.kv")
local bannedSkillsKV = LoadKeyValues("scripts/kv/bannedSkills.kv")

local whiteListKV = LoadKeyValues("scripts/kv/WhiteList.kv")
for ability, values in pairs(whiteListKV) do
	whiteList[ability] = values
end
for k,v in pairs(exceptValuesKV) do
    exceptValues[v] = v
end
for abilityName, _ in pairs(bannedSkillsKV) do
	bannedSkills[abilityName] = abilityName
end
-------------------------MODIFIER's SETTINGS-------------------------

function modifier_spells_randomize_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}
	return funcs
end

-- должен вызываться один раз
function modifier_spells_randomize_values:OnCreated(params)
	if IsClient() then
		print("Client is here: modifier_spells_randomize_values:OnCreated()")
	end
    if IsServer() then
		print("Server is here: modifier_spells_randomize_values:OnCreated()")
	end
	
	print("Сервер?:", IsServer(), "Клиент?:", IsClient())
	print("Modifier Created!")

    if IsServer() then
        CustomNetTables:SetTableValue("spell_amps_server", tostring(self:GetParent():GetPlayerOwnerID()), abilitiesAndVals)
    end
    self:updateSkillsInfo()
end

-- function modifier_spells_randomize_values:scaleParam(abilityName, paramName, paramValue)
--     local skipBool = self:valueIsIgnore(abilityName, paramName)
--     if skipBool == true or skipBool == 1 then
--         abilitiesAndVals[abilityName][k] = 1
--     end
-- end

function modifier_spells_randomize_values:updateSkillsInfo()
-- 	if IsClient() then
-- 		print("Client is here: modifier_spells_randomize_values:updateSkillsInfo()")
-- 	end
--     if IsServer() then
-- 		print("Server is here: modifier_spells_randomize_values:updateSkillsInfo()")
-- 	end
	
-- 	print("skills updating....")

-- 	local hero = self:GetParent()
-- 	if hero == nil then return end

--     local abilityCount = hero:GetAbilityCount()
--     for i=0, abilityCount do
--         local ability
--         if not pcall(function () 
--             ability = hero:GetAbilityByIndex(i)
--         end) then
--             goto skipAbility
--         end
--         if ability == nil then goto skipAbility end

--         local abilityName = ability:GetAbilityName()
--         -- не умножаем значения забаненного скилла
--         if bannedSkills[abilityName] == abilityName then goto skipAbility end

--         local abilityTable = GetAbilityKeyValuesByName(abilityName)
--         local isTalent = string.match(abilityName, "special_bonus")
--         abilitiesAndVals[abilityName] = {}

--         for paramName, paramValue in pairs(abilityTable) do
--             if type(paramValue) == "table" then
--                 for x, y in pairs(paramValue) do
--                     if type(y) == "table" then
--                         --"value"	"12 13 14"
--                         for thrdType, thrdValue in pairs(y) do
--                             local skipBool
--                             if thrdType == "value" and not isTalent then
--                                 skipBool = self:valueIsIgnore(abilityName, x)
--                             elseif thrdType == "value" and isTalent then 
--                                 skipBool = self:valueIsIgnore(nil, abilityName)
--                             else
--                                 skipBool = self:valueIsIgnore(abilityName, thrdType)
--                             end
--                             if skipBool == true or skipBool == 1 then
--                                 goto continue3
--                             end
--                             -----------------------
--                             if thrdType == "value" and not isTalent then
--                                 abilitiesAndVals[abilityName][x] = 1
--                             else
--                                 abilitiesAndVals[abilityName][thrdType] = 1
--                             end
--                             ::continue3::
--                         end
                        
--                     else
--                         local skipBool = self:valueIsIgnore(abilityName, x)
--                         if skipBool == true or skipBool == 1 then
--                             goto continue2
--                         end
--                         abilitiesAndVals[abilityName][x] = 1
--                     end
--                     ::continue2::
--                 end
--             else
--                 local skipBool = self:valueIsIgnore(abilityName, paramName)
--                 if skipBool == true or skipBool == 1 then
--                     goto continue
--                 end
--                 if paramName == "AbilityDamage" then paramName = "#AbilityDamage" end
--                 abilitiesAndVals[abilityName][paramName] = 1
--             end
--             ::continue::
--         end

--         self:AlterNetTable(abilityName)
--         ::skipAbility::
--     end

--     -- клонирование таблицы с сервера для будущего использования клиентом
--     if IsServer() then
--         CustomNetTables:SetTableValue("spell_amps_server", tostring(hero:GetPlayerOwnerID()), abilitiesAndVals)
--     end

-- 	-- attempt to call global 'isClient' (a nil value)
-- 	-- abilitiesAndVals = CustomNetTables:GetTableValue("spell_amps_server", tostring(hero:GetPlayerOwnerID()))
end


function modifier_spells_randomize_values:GetModifierOverrideAbilitySpecial(params)
	return 1
end

function modifier_spells_randomize_values:GetModifierOverrideAbilitySpecialValue(params)
    abilitiesAndVals = CustomNetTables:GetTableValue("spell_amps_server", tostring(self:GetParent():GetPlayerOwnerID()))
    if IsClient() then
        settings = CustomNetTables:GetTableValue("settings", "settings")
        xAbilityCastRange = settings["xAbilityCastRange"]
        xCooldown = settings["xCooldown"]
        xDuration = settings["xDuration"]
        xRange = settings["xRange"]
        xMultiplier = settings["xMultiplier"]
        xRadius = settings["xRadius"]
    end
    local szAbilityName = params.ability:GetAbilityName()
	local szSpecialValueName = params.ability_special_value
    local nSpecialLevel = params.ability_special_level
    local baseValue = params.ability:GetLevelSpecialValueNoOverride(szSpecialValueName, nSpecialLevel)
    if szAbilityName == nil or bannedSkills[szAbilityName] == szAbilityName then return baseValue end

    local valueMultiplier = nil
    if abilitiesAndVals[szAbilityName] ~= nil then
        if abilitiesAndVals[szAbilityName][szSpecialValueName] ~= nil then
            valueMultiplier = abilitiesAndVals[szAbilityName][szSpecialValueName]
            -- print("Есть записанное умножение способности", szAbilityName, szSpecialValueName, IsClient())
        end
    end
    if valueMultiplier == nil then
        local skipBool = self:valueIsIgnore(szAbilityName, szSpecialValueName)
		if skipBool == true or skipBool == 1 then
			return baseValue
		end
		if skipBool == "radius" then valueMultiplier = xRadius
		elseif skipBool == "cooldown" then valueMultiplier = xCooldown
		elseif skipBool == "duration" then valueMultiplier = xDuration
		elseif skipBool == "range" then valueMultiplier = xRange
		elseif skipBool == "AbilityCastRange" then valueMultiplier = xAbilityCastRange
		else
			valueMultiplier = xMultiplier
            -- ВОЗМОЖНЫ ЛАГИ
            -- if IsServer() then
            --     if not pcall(function (...)
            --         abilitiesAndVals[szAbilityName][szSpecialValueName] = valueMultiplier
            --     end) then
            --         abilitiesAndVals[szAbilityName] = {}
            --         abilitiesAndVals[szAbilityName][szSpecialValueName] = valueMultiplier
            --     end
            --     CustomNetTables:SetTableValue("spell_amps_server", tostring(self:GetParent():GetPlayerOwnerID()), abilitiesAndVals)
            -- end
		end
    end
    -- print("valueMultiplier", szAbilityName, szSpecialValueName, baseValue, valueMultiplier, IsClient())
    local finalValue = self:RoundFloat(baseValue * valueMultiplier, 2)
    if finalValue == nil or not finalValue then
        return baseValue
    end
    -- print("finalValue", szAbilityName, szSpecialValueName, baseValue, valueMultiplier, finalValue, IsClient())
    return finalValue
end

-- function modifier_spells_randomize_values:GetModifierOverrideAbilitySpecialValue(params)
    -- if IsClient() then
	-- 	-- abilitiesAndVals = CustomNetTables:GetTableValue("spell_amps_server", tostring(self:GetParent():GetPlayerOwnerID()))
	-- 	---------------
	-- 	settings = CustomNetTables:GetTableValue("settings", "settings")
	-- 	xAbilityCastRange = settings["xAbilityCastRange"]
	-- 	xCooldown = settings["xCooldown"]
	-- 	xDuration = settings["xDuration"]
	-- 	xRange = settings["xRange"]
	-- 	xMultiplier = settings["xMultiplier"]
	-- 	xRadius = settings["xRadius"]
	-- end
--     local szAbilityName = params.ability:GetAbilityName()
-- 	local szSpecialValueName = params.ability_special_value
-- 	local nSpecialLevel = params.ability_special_level
	
-- 	local base = params.ability:GetLevelSpecialValueNoOverride(szSpecialValueName, nSpecialLevel)
-- 	if szAbilityName == nil or bannedSkills[szAbilityName] == szAbilityName then return base end

-- 	-- if params.ability:IsItem() then
-- 	-- 	local skipBool = self:valueIsIgnore(szAbilityName, szSpecialValueName)
-- 	-- 	if skipBool == true or skipBool == 1 then
-- 	-- 		return base
-- 	-- 	end
-- 	-- 	--------------
-- 	-- 	local amp = 1
-- 	-- 	if skipBool == "radius" then amp = xRadius
-- 	-- 	elseif skipBool == "cooldown" then amp = xCooldown
-- 	-- 	elseif skipBool == "duration" then amp = xDuration
-- 	-- 	elseif skipBool == "range" then amp = xRange
-- 	-- 	elseif skipBool == "AbilityCastRange" then amp = xAbilityCastRange
-- 	-- 	else
-- 	-- 		amp = xMultiplier
-- 	-- 	end
-- 	-- 	---------------
-- 	-- 	local final = self:RoundFloat(base * amp, 2)
-- 	-- 	if final == nil or final == 0 or not final or final < 0.00001 then
-- 	-- 		return base
-- 	-- 	end
-- 	-- 	return final
-- 	-- end

-- 	local amp = 1
-- 	-- Если значение уже было обработано и записано
-- 	if abilitiesAndVals[szAbilityName] then
-- 		if abilitiesAndVals[szAbilityName][szSpecialValueName] then
--             print(szAbilityName, abilitiesAndVals[szAbilityName][szSpecialValueName])
-- 			amp = abilitiesAndVals[szAbilityName][szSpecialValueName]
-- 		end
-- 	-- Если нет то обрабатываю в реальном времени
-- 	else
-- 		local skipBool = self:valueIsIgnore(szAbilityName, szSpecialValueName)
-- 		if skipBool == true or skipBool == 1 then
-- 			return base
-- 		end
-- 		if skipBool == "radius" then amp = xRadius
-- 		elseif skipBool == "cooldown" then amp = xCooldown
-- 		elseif skipBool == "duration" then amp = xDuration
-- 		elseif skipBool == "range" then amp = xRange
-- 		elseif skipBool == "AbilityCastRange" then amp = xAbilityCastRange
-- 		else
-- 			amp = xMultiplier
-- 		end
-- 	end
	
-- 	if amp == nil or amp == 0 or not amp or amp < 0.00001 then
-- 		return base
-- 	end
	
-- 	local final = self:RoundFloat(base * amp, 2)
-- 	if final == nil or final == 0 or not final or final < 0.00001 then
-- 		return base
-- 	end
-- 	return final
-- end

function modifier_spells_randomize_values:AlterNetTable(szAbilityName)
	local tAbilityTable = abilitiesAndVals[szAbilityName]
	-------------
    for paramName, v in pairs(tAbilityTable) do
        local returnCheck = self:valueIsIgnore(szAbilityName, paramName)
        if returnCheck == "radius" then tAbilityTable[paramName] = xRadius
        elseif returnCheck == "cooldown" then tAbilityTable[paramName] = xCooldown
        elseif returnCheck == "duration" then tAbilityTable[paramName] = xDuration
        elseif returnCheck == "range" then tAbilityTable[paramName] = xRange
        elseif returnCheck == "AbilityCastRange" then tAbilityTable[paramName] = xAbilityCastRange
        elseif not returnCheck then
            tAbilityTable[paramName] = xMultiplier
        end
    end
    -------------
    abilitiesAndVals[szAbilityName] = tAbilityTable
end

function modifier_spells_randomize_values:RoundFloat(fNum, iDecimal)
	local iNths = (10^iDecimal)
	local fNum = fNum * iNths 
	return fNum / iNths
end

-- true - не умножаем. false - умножаем
function modifier_spells_randomize_values:valueIsIgnore(ability, val)
    -- нужен
	if IsClient() then
		settings = CustomNetTables:GetTableValue("settings", "settings")
		xAbilityCastRange = settings["xAbilityCastRange"]
		xCooldown = settings["xCooldown"]
		xDuration = settings["xDuration"]
		xRange = settings["xRange"]
		xMultiplier = settings["xMultiplier"]
		xRadius = settings["xRadius"]
		xChance = settings["xChance"]
		xSlow = settings["xSlow"]
		xIllusion = settings["xIllusion"]
		xArmor = settings["xArmor"]
	end
	-- Специфические условия игнорирования
	if ability == "item_hand_of_midas" and EASY_MODE == false then
		return true
	end

	-- Проверка игнорирования умножения значения конкретно у скилла
	local checkValues = whiteList[ability]
	if checkValues then
		if type(checkValues) == "table" then
			for i, checkValue in pairs(checkValues) do
				if checkValue == val then
					return true
				end
			end
		else
			if checkValues == val then
				return true
			end
		end
	end
	-- Игнорируем умножение переменных у всех способностей из списка исключений
	if exceptValues[val] then
		return true
	end
	if string.match(val, "cooldown") or string.match(val, "Cooldown")  then
		return "cooldown"
	end
	if string.match(val, "duration") or string.match(val, "Duration") or string.match(val, "drain_length") or string.match(val, "lifetime") then
		return "duration"
	end
	if string.match(val, "radius") or string.match(val, "Radius") or string.match(val, "aoe") then
		return "radius"
	end
	if val == "AbilityCastRange" then
		return "AbilityCastRange"
	elseif string.match(val, "range") or string.match(val, "Range") or string.match(val, "Distance") or string.match(val, "distance") or 
	string.match(val, "length") or string.match(val, "Length") or string.match(val, "width") or string.match(val, "Width") then
		return "range"
	end
	-------------
	if string.match(val, "Chance") or string.match(val, "bonus_cdr") then
		return xChance
	end
	if (string.match(val, "slow") and not string.match(val, "attackspeed_slow")) or slowValues[ability] == val then
		return xSlow
	end
	if string.match(val, "images_count") or string.match(val, "max_illusions") then
		return xIllusion
	end
	if string.match(val, "armor") and not string.match(val, "magical") then
		return xArmor
	end
	-------------
	if string.match(val, "delay") or string.match(val, "interval") or string.match(val, "stun") or string.match(val, "status_resist") or 
	(string.match(val, "angle") and not string.match(val, "entangle")) or string.match(val, "travel_time") or
	string.match(val, "damage_reduction") or string.match(val, "time") or (string.match(val, "special_bonus") and string.match(val, "evasion")) or
	string.match(val, "reduction_pct") or string.match(val, "multiplier")
	then
		return true
	end
	--Если переменная не попало под какое-либо определение, то умножаем
	return false
end