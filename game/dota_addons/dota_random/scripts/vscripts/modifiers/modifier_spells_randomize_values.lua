modifier_spells_randomize_values = modifier_spells_randomize_values or class({})
abilitiesAndVals = {}

function RoundFloat(fNum, iDecimal)
	local iNths = (10^iDecimal)
	local fNum = fNum * iNths 
	return fNum / iNths
end

-------------------------MODIFIER's SETTINGS-------------------------
function modifier_spells_randomize_values:GetTexture() return "chaos_knight_chaos_strike" end
function modifier_spells_randomize_values:IsPermanent() return true end
function modifier_spells_randomize_values:RemoveOnDeath() return false end
function modifier_spells_randomize_values:IsHidden() return true end
function modifier_spells_randomize_values:IsDebuff() return false end

-------------------------INIT VALUES-------------------------
print("INIT VALUES")
local WhiteList = {}
local BannedSkills = {}
local ExceptValues = {}
local ExceptValuesKV = LoadKeyValues("scripts/kv/ExceptValues.kv")
local WhiteListKV = LoadKeyValues("scripts/kv/WhiteList.kv")
local BannedSkillsKV = LoadKeyValues("scripts/kv/BannedSkills.kv")

local CooldownValues = {}
local CooldownValuesKV = LoadKeyValues("scripts/kv/ValuesCategories/CooldownValues.kv")
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
print("INIT VALUES finished")
print("createing tables")
for key, value in pairs(CooldownValuesKV) do
    if type(key) == "Exclude" then
        for k,v in value do
            CooldownValues["Exclude"][k] = v
        end
    else
        CooldownValues[key] = value
    end
end
for key, value in pairs(UnitsCountValuesKV) do
    if type(key) == "Exclude" then
        for k,v in value do
            UnitsCountValues["Exclude"][k] = v
        end
    else
        UnitsCountValues[key] = value
    end
end
for key, value in pairs(SkillsSpeedValuesKV) do
    if type(key) == "Exclude" then
        for k,v in value do
            SkillsSpeedValues["Exclude"][k] = v
        end
    else
        SkillsSpeedValues[key] = value
    end
end
for key, value in pairs(SpeedValuesKV) do
    if type(key) == "Exclude" then
        for k,v in value do
            SpeedValues["Exclude"][k] = v
        end
    else
        SpeedValues[key] = value
    end
end
for key, value in pairs(DurationValuesKV) do
    if type(key) == "Exclude" then
        for k,v in value do
            DurationValues["Exclude"][k] = v
        end
    else
        DurationValues[key] = value
    end
end
for key, value in pairs(RadiusValuesKV) do
    if type(key) == "Exclude" then
        for k,v in value do
            RadiusValues["Exclude"][k] = v
        end
    else
        RadiusValues[key] = value
    end
end
for key, value in pairs(RangeValuesKV) do
    if type(key) == "Exclude" then
        for k,v in value do
            RangeValues["Exclude"][k] = v
        end
    else
        RangeValues[key] = value
    end
end
for key, value in pairs(CastRangeValuesKV) do
    if type(key) == "Exclude" then
        for k,v in value do
            CastRangeValues["Exclude"][k] = v
        end
    else
        CastRangeValues[key] = value
    end
end
for key, value in pairs(ChancesValuesKV) do
    if type(key) == "Exclude" then
        for k,v in value do
            ChancesValues["Exclude"][k] = v
        end
    else
        ChancesValues[key] = value
    end
end
for key, value in pairs(ModelScaleValuesKV) do
    if type(key) == "Exclude" then
        for k,v in value do
            ModelScaleValues["Exclude"][k] = v
        end
    else
        ModelScaleValues[key] = value
    end
end
for key, value in pairs(SlowValuesKV) do
    if type(key) == "Exclude" then
        for k,v in value do
            SlowValues["Exclude"][k] = v
        end
    else
        SlowValues[key] = value
    end
end
for key, value in pairs(PercentScaleValuesKV) do
    if type(key) == "Exclude" then
        for k,v in value do
            PercentScaleValues["Exclude"][k] = v
        end
    else
        PercentScaleValues[key] = value
    end
end
for ability, values in pairs(WhiteListKV) do
	WhiteList[ability] = values
end
for k,v in pairs(ExceptValuesKV) do
    ExceptValues[v] = v
end
for abilityName, _ in pairs(BannedSkillsKV) do
	BannedSkills[abilityName] = abilityName
end
print("finish createing tables")
-------------------------MODIFIER's SETTINGS-------------------------

function modifier_spells_randomize_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_TOOLTIP,
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
end

-- function modifier_spells_randomize_values:scaleParam(abilityName, paramName, paramValue)
--     local skipBool = self:GetValueMultiplier(abilityName, paramName)
--     if skipBool == true or skipBool == 1 then
--         abilitiesAndVals[abilityName][k] = 1
--     end
-- end


function modifier_spells_randomize_values:GetModifierOverrideAbilitySpecial(table)
    local AbilityName = table.ability:GetAbilityName()
    if AbilityName == nil or BannedSkills[AbilityName] == AbilityName then return 0 end

	return 1
end

function modifier_spells_randomize_values:GetModifierOverrideAbilitySpecialValue(params)
    abilitiesAndVals = CustomNetTables:GetTableValue("spell_amps_server", tostring(self:GetParent():GetPlayerOwnerID()))
    -- if IsClient() then
    --     settings = CustomNetTables:GetTableValue("settings", "settings")
    --     xMultiplier = settings["xMultiplier"]
    --     xAbilityCastRange = settings["xAbilityCastRange"]
	-- 	xCooldown = settings["xCooldown"]
	-- 	xDuration = settings["xDuration"]
	-- 	xRange = settings["xRange"]
	-- 	xRadius = settings["xRadius"]
	-- 	xChance = settings["xChance"]
	-- 	xSlow = settings["xSlow"]
    --     xPercentScale = settings["xPercentScale"]
    --     xResistances = settings["xResistances"]
    --     xModelScale = settings["xModelScale"]
    --     xSpeed = settings["xSpeed"]
    --     xSkillsSpeed = settings["xSkillsSpeed"]
    --     xUnitsCount = settings["xUnitsCount"]
    -- end
    local szAbilityName = params.ability:GetAbilityName()
	local szSpecialValueName = params.ability_special_value
    local nSpecialLevel = params.ability_special_level
    local baseValue = params.ability:GetLevelSpecialValueNoOverride(szSpecialValueName, nSpecialLevel)
    
    local valueMultiplier = nil
    if abilitiesAndVals[szAbilityName] ~= nil then
        if abilitiesAndVals[szAbilityName][szSpecialValueName] ~= nil then
            valueMultiplier = abilitiesAndVals[szAbilityName][szSpecialValueName]
            return valueMultiplier
            -- print("Есть записанное умножение способности", szAbilityName, szSpecialValueName, IsClient())
        end
    end
    if valueMultiplier == nil then
        local returnMultiplier = self:GetValueMultiplier(szAbilityName, szSpecialValueName)
        if returnMultiplier then
            valueMultiplier = returnMultiplier
        else
            return baseValue
        end
    end
    -- print("valueMultiplier", szAbilityName, szSpecialValueName, baseValue, valueMultiplier, IsClient())
    local finalValue = RoundFloat(baseValue * valueMultiplier, 2)
    if finalValue == nil then
        return baseValue
    end
    -- print("finalValue", szAbilityName, szSpecialValueName, baseValue, valueMultiplier, finalValue, IsClient())
    return finalValue
end

function modifier_spells_randomize_values:AlterNetTable(szAbilityName)
	local tAbilityTable = abilitiesAndVals[szAbilityName]
	-------------
    for paramName, v in pairs(tAbilityTable) do
        local returnMultiplier = self:GetValueMultiplier(szAbilityName, paramName)
        if returnMultiplier then
            abilitiesAndVals[szAbilityName][paramName] = returnMultiplier
        end
    end
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
	local checkValues = WhiteList[ability]
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
	if ExceptValues[val] then
		return false
	end
    -- вампиризм, криты, хил и т.д. (в будущем разделить)
    if PercentScaleValues[val] == val or string.match(val, "reflection_pct") then
        return xPercentScale
    end
	if string.match(val, "cooldown") or string.match(val, "Cooldown") or CooldownValues[val] == val then
		return xCooldown
	end
	if string.match(val, "duration") or string.match(val, "Duration") or DurationValues[val] == val then
		return xDuration
	end
	if string.match(val, "radius") or string.match(val, "aoe") or string.match(val, "width") or RadiusValues[val] == val then
		return xRadius
	end
	if val == "AbilityCastRange" or CastRangeValues[val] == val then
		return xAbilityCastRange
    end
    if RangeValues["Exclude"][val] == nil and (string.match(val, "range") or string.match(val, "length") or RangeValues[val] == val) then
		return xRange
	end
	if string.match(val, "chance") or ChancesValues[val] == val then
		return xChance
	end
	if SlowValues["Exclude"][val] == nil and (string.match(val, "slow") or SlowValues[val] == val) then
		return xSlow
	end
    -- броня и магия
	if string.match(val, "armor") or string.match(val, "resistance") or string.match(val, "resist") or string.match(val, "status_resist") or
	(string.match(val, "special_bonus") and string.match(val, "evasion")) or (string.match(val, "special_bonus") and string.match(val, "armor")) then
		return xResistances
	end
    if string.match(val, "modelscale") or string.match(val, "model_scale") or ModelScaleValues[val] == val then
        return xModelScale
    end
    if SpeedValues["Exclude"][val] == nil and (string.match(val, "speed") or SpeedValues[val] == val) then
        return xSpeed
    end
    if string.match(val, "projectile_speed") or SkillsSpeedValues[val] == val then
        return xSkillsSpeed
    end
    if val == "count" or UnitsCountValues[val] == val then
        return xUnitsCount
    end
	-------------
	if string.match(val, "delay") or
    string.match(val, "interval") or
    string.match(val, "damage_reduction") or
    string.match(val, "_time") or string.sub(val, 1, 5) == "time_" or
    string.match(val, "height") or
    string.match(val, "stun") or 
	(string.match(val, "angle") and not string.match(val, "entangle")) or
	string.match(val, "reduction_pct") or string.match(val, "multiplier")
	then
		return false
	end
	--Если переменная не попало под какое-либо определение, то умножаем
	return xMultiplier
end