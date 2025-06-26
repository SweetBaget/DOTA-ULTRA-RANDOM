modifier_spells_randomize_values = modifier_spells_randomize_values or class({})
abilitiesAndVals = {}

-------------------------MODIFIER's SETTINGS-------------------------
function modifier_spells_randomize_values:GetTexture() return "chaos_knight_chaos_strike" end
function modifier_spells_randomize_values:IsPermanent() return true end
function modifier_spells_randomize_values:RemoveOnDeath() return false end
function modifier_spells_randomize_values:IsHidden() return true end
function modifier_spells_randomize_values:IsDebuff() return false end

-------------------------INIT VALUES-------------------------
local exceptValues = {}
local whiteList = {}
local bannedSkills = {}
local exceptValuesKV = LoadKeyValues("scripts/kv/exceptValues.kv")
local whiteListKV = LoadKeyValues("scripts/kv/WhiteList.kv")
local bannedSkillsKV = LoadKeyValues("scripts/kv/bannedSkills.kv")

local SlowValues = {}
local SlowValuesKV = LoadKeyValues("scripts/kv/ValuesCategories/SlowValues.kv")
local ModelScaleValues = {}
local ModelScaleValuesKV = LoadKeyValues("scripts/kv/ValuesCategories/ModelScaleValues.kv")
local PercentScaleValues = {}
local PercentScaleValuesKV = LoadKeyValues("scripts/kv/ValuesCategories/PercentScaleValues.kv")
local ChancesValues = {}
local ChancesValuesKV = LoadKeyValues("scripts/kv/ValuesCategories/ChancesValues.kv")
local CastRangeValues = {}
local CastRangeValuesKV = LoadKeyValues("scripts/kv/ValuesCategories/CastRangeValues.kv")
local RangeValues = {}
local RangeValuesKV = LoadKeyValues("scripts/kv/ValuesCategories/RangeValues.kv")
local RadiusValues = {}
local RadiusValuesKV = LoadKeyValues("scripts/kv/ValuesCategories/RadiusValues.kv")
local DurationValues = {}
local DurationValuesKV = LoadKeyValues("scripts/kv/ValuesCategories/DurationValues.kv")
local SpeedValues = {}
local SpeedValuesKV = LoadKeyValues("scripts/kv/ValuesCategories/SpeedValues.kv")
local SkillsSpeedValues = {}
local SkillsSpeedValuesKV = LoadKeyValues("scripts/kv/ValuesCategories/SkillsSpeedValues.kv")
local UnitsCountValues = {}
local UnitsCountValuesKV = LoadKeyValues("scripts/kv/ValuesCategories/UnitsCountValues.kv")

for key, value in pairs(PercentScaleValuesKV) do
    PercentScaleValues[key] = value
end

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
--     local skipBool = self:GetValueMultiplier(abilityName, paramName)
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
--                                 skipBool = self:GetValueMultiplier(abilityName, x)
--                             elseif thrdType == "value" and isTalent then 
--                                 skipBool = self:GetValueMultiplier(nil, abilityName)
--                             else
--                                 skipBool = self:GetValueMultiplier(abilityName, thrdType)
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
--                         local skipBool = self:GetValueMultiplier(abilityName, x)
--                         if skipBool == true or skipBool == 1 then
--                             goto continue2
--                         end
--                         abilitiesAndVals[abilityName][x] = 1
--                     end
--                     ::continue2::
--                 end
--             else
--                 local skipBool = self:GetValueMultiplier(abilityName, paramName)
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
		xChance = settings["xChance"]
		xSlow = settings["xSlow"]
        xPercentScale = settings["xPercentScale"]
        xResistances = settings["xResistances"]
        xModelScale = settings["xModelScale"]
        xSpeed = settings["xSpeed"]
        xSkillsSpeed = settings["xSkillsSpeed"]
        xUnitsCount = settings["xUnitsCount"]
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
        local returnMultiplier = self:GetValueMultiplier(szAbilityName, szSpecialValueName)
		-- if returnCheck == "radius" then tAbilityTable[paramName] = xRadius
        -- elseif returnCheck == "cooldown" then tAbilityTable[paramName] = xCooldown
        -- elseif returnCheck == "duration" then tAbilityTable[paramName] = xDuration
        -- elseif returnCheck == "range" then tAbilityTable[paramName] = xRange
        -- elseif returnCheck == "AbilityCastRange" then tAbilityTable[paramName] = xAbilityCastRange
        if returnMultiplier then
            valueMultiplier = returnMultiplier
        else
            return baseValue
        end
    end
    -- print("valueMultiplier", szAbilityName, szSpecialValueName, baseValue, valueMultiplier, IsClient())
    local finalValue = self:RoundFloat(baseValue * valueMultiplier, 2)
    if finalValue == nil then
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
-- 	-- 	local skipBool = self:GetValueMultiplier(szAbilityName, szSpecialValueName)
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
-- 		local skipBool = self:GetValueMultiplier(szAbilityName, szSpecialValueName)
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
        local returnMultiplier = self:GetValueMultiplier(szAbilityName, paramName)
        -- if returnCheck == "radius" then tAbilityTable[paramName] = xRadius
        -- elseif returnCheck == "cooldown" then tAbilityTable[paramName] = xCooldown
        -- elseif returnCheck == "duration" then tAbilityTable[paramName] = xDuration
        -- elseif returnCheck == "range" then tAbilityTable[paramName] = xRange
        -- elseif returnCheck == "AbilityCastRange" then tAbilityTable[paramName] = xAbilityCastRange
        if returnMultiplier then
            tAbilityTable[paramName] = returnMultiplier
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

function modifier_spells_randomize_values:GetValueMultiplier(ability, val)
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
        xPercentScale = settings["xPercentScale"]
        xResistances = settings["xResistances"]
        xModelScale = settings["xModelScale"]
        xSpeed = settings["xSpeed"]
        xSkillsSpeed = settings["xSkillsSpeed"]
        xUnitsCount = settings["xUnitsCount"]
	end
	-- Специфические условия игнорирования
	if ability == "item_hand_of_midas" and EASY_MODE == false then
		return false
	end

	-- Проверка игнорирования умножения значения конкретно у скилла
	local checkValues = whiteList[ability]
	if checkValues then
		if type(checkValues) == "table" then
			for i, checkValue in pairs(checkValues) do
				if checkValue == val then
					return false
				end
			end
		else
			if checkValues == val then
				return false
			end
		end
	end
	-- Игнорируем умножение переменных у всех способностей из списка исключений
	if exceptValues[val] then
		return false
	end
    -- вампиризм, криты, хил и т.д. (в будущем разделить)
    if PercentScaleValuesKV[val] == val then
        return xPercentScale
    end
	if string.match(val, "cooldown") or string.match(val, "Cooldown") then
		return xCooldown
	end
	if string.match(val, "duration") or string.match(val, "Duration") or DurationValuesKV[val] == val then
		return xDuration
	end
	if string.match(val, "radius") or string.match(val, "aoe") or string.match(val, "width") or RadiusValuesKV[val] == val then
		return xRadius
	end
	if val == "AbilityCastRange" or CastRangeValuesKV[val] == val then
		return xAbilityCastRange
    end
    if RangeValuesKV["Exclude"][val] == nil and (string.match(val, "range") or string.match(val, "length") or RangeValuesKV[val] == val) then
		return xRange
	end
	if string.match(val, "сhance") or ChancesValuesKV[val] == val then
		return xChance
	end
	if SlowValuesKV["Exclude"][val] == nil and (string.match(val, "slow") or SlowValuesKV[val] == val) then
		return xSlow
	end
	if string.match(val, "armor") or string.match(val, "resistance") then
		return xResistances
	end
    if string.match(val, "modelscale") or ModelScaleValuesKV[val] == val then
        return xModelScale
    end
    if SpeedValuesKV["Exclude"][val] == nil and (string.match(val, "speed") or SpeedValuesKV[val] == val) then
        return xSpeed
    end
    if string.match(val, "projectile_speed") or SkillsSpeedValuesKV[val] == val then
        return xSkillsSpeed
    end
    if UnitsCountValuesKV[val] == val then
        return xUnitsCount
    end
	-------------
	if string.match(val, "delay") or
    string.match(val, "interval") or
    string.match(val, "damage_reduction") or
    string.match(val, "vision") or --тестово убрать весь скейл вижена
    string.match(val, "_time") or string.sub(val, 1, 5) == "time_" or
    string.match(val, "height") or
    string.match(val, "stun") or string.match(val, "status_resist") or 
	(string.match(val, "angle") and not string.match(val, "entangle")) or
	(string.match(val, "special_bonus") and string.match(val, "evasion")) or
	string.match(val, "reduction_pct") or string.match(val, "multiplier")
	then
		return false
	end
	--Если переменная не попало под какое-либо определение, то умножаем
	return xMultiplier
end