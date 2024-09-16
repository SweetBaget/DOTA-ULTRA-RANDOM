modifier_spells_randomize_values = modifier_spells_randomize_values or class({})

local slowValues = {
    ["broodmother_silken_bola"] = "movement_speed",
	["necrolyte_ghost_shroud"] = "movement_speed"
}

local exceptValues = {}
local whiteList = {}
local exceptValuesKV = LoadKeyValues("scripts/kv/exceptValues.kv")

local whiteListKV = LoadKeyValues("scripts/kv/WhiteList.kv")
for ability, values in pairs(whiteListKV) do
	whiteList[ability] = values
end

for k,v in pairs(exceptValuesKV) do
    exceptValues[v] = v
end

function modifier_spells_randomize_values:GetTexture() return "chaos_knight_chaos_strike" end -- get the icon from a different ability
function modifier_spells_randomize_values:IsPermanent() return true end
function modifier_spells_randomize_values:RemoveOnDeath() return false end
function modifier_spells_randomize_values:IsHidden() return false end 	-- we can hide the modifier
function modifier_spells_randomize_values:IsDebuff() return false end 	-- make it red or green

function modifier_spells_randomize_values:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
		MODIFIER_PROPERTY_ABILITY_LAYOUT
	}
	return funcs
end

function modifier_spells_randomize_values:OnCreated(params)
	local hero = self:GetParent()
	if IsClient() then
		print("client")
		hero:FindModifierByName("modifier_spells_randomize_values"):ForceRefresh() --DONT DELETE
	end
	if IsServer() then
		print("server")
		hero:FindModifierByName("modifier_spells_randomize_values"):ForceRefresh() --DONT DELETE
	end
end

function modifier_spells_randomize_values:OnRefresh(params)
	print("skills updating....")
	self.abilitiesAndVals = {}

	local hero = self:GetParent()
	print("hero is", hero)

	if hero then
		tAbilities = {}
		local abilityCount = hero:GetAbilityCount()
		for i=0, abilityCount do
			local ability
			if not pcall(function () 
				ability = hero:GetAbilityByIndex(i)
			end) then
				goto skip
			end
			if ability == nil then goto skip end
			local abilityName = ability:GetAbilityName()
			if abilityName == "abyssal_underlord_portal_warp" then return true end
			local abilityTable = GetAbilityKeyValuesByName(abilityName)
			local isTalent = string.match(abilityName, "special_bonus")

			if not self.abilitiesAndVals[abilityName] then
				self.abilitiesAndVals[abilityName] = {}
			end
			for k,v in pairs(abilityTable) do
				if type(v) == "table" then
					--"kill_pct" {}
					for x, y in pairs(v) do
						if type(y) == "table" then
							--"value"	"12 13 14"
							for thrdType, thrdValue in pairs(y) do
								local skipBool
								if thrdType == "value" and not isTalent then
									skipBool = self:CheckExceptions(abilityName, x)
								elseif thrdType == "value" and isTalent then 
									skipBool = self:CheckExceptions(nil, abilityName)
								else
									skipBool = self:CheckExceptions(abilityName, thrdType)
								end
								if skipBool == true or skipBool == 1 then
									goto continue3
								end
								-----------------------
								if thrdType == "value" and not isTalent then
									self.abilitiesAndVals[abilityName][x] = 1
								else
									self.abilitiesAndVals[abilityName][thrdType] = 1
								end
								::continue3::
							end
							
						else
							local skipBool = self:CheckExceptions(abilityName, x)
							if skipBool == true or skipBool == 1 then
								goto continue2
							end
							self.abilitiesAndVals[abilityName][x] = 1
						end
						::continue2::
					end
				else
					local skipBool = self:CheckExceptions(abilityName, k)
					if skipBool == true or skipBool == 1 then
						goto continue
					end
					if k == "AbilityDamage" then k = "#AbilityDamage" end
					self.abilitiesAndVals[abilityName][k] = 1
				end
				::continue::
			end
			CustomNetTables:SetTableValue("spell_amps_server", tostring(hero:GetPlayerOwnerID()), self.abilitiesAndVals)
			self:AlterNetTable(abilityName)
			::skip::
		end
	end
	self.abilitiesAndVals = CustomNetTables:SetTableValue("spell_amps_server", tostring( hero:GetPlayerOwnerID()))
end

--без этого не работает
function modifier_spells_randomize_values:GetModifierOverrideAbilitySpecial( params )
	return 1
end

-----------------------------------------------------------------------
function modifier_spells_randomize_values:GetModifierOverrideAbilitySpecialValue( params )
	if IsClient() then
		self.abilitiesAndVals = CustomNetTables:GetTableValue("spell_amps_server", tostring(self:GetParent():GetPlayerOwnerID()))
		---------------
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

	local base = params.ability:GetLevelSpecialValueNoOverride(szSpecialValueName, nSpecialLevel)
	if szAbilityName == nil then return base end

	if params.ability:IsItem() then
		local skipBool = self:CheckExceptions(szAbilityName, szSpecialValueName)
		if skipBool == true or skipBool == 1 then
			return base
		end
		--------------
		local amp = 1
		if skipBool == "radius" then amp = xRadius
		elseif skipBool == "cooldown" then amp = xCooldown
		elseif skipBool == "duration" then amp = xDuration
		elseif skipBool == "range" then amp = xRange
		elseif skipBool == "AbilityCastRange" then amp = xAbilityCastRange
		else
			amp = xMultiplier
		end
		---------------
		local final = self:RoundFloat(base * amp, 2)
		if final == nil or final == 0 or not final or final < 0.00001 then
			return base
		end
		return final
	end

	local amp = 1
	-- Если значение уже было обработано и записано
	if self.abilitiesAndVals[szAbilityName] then
		if self.abilitiesAndVals[szAbilityName][szSpecialValueName] then
			amp = self.abilitiesAndVals[szAbilityName][szSpecialValueName]
		end
	-- Если нет то обрабатываю в реальном времени
	else
		local skipBool = self:CheckExceptions(szAbilityName, szSpecialValueName)
		if skipBool == true or skipBool == 1 then
			return base
		end
		if skipBool == "radius" then amp = xRadius
		elseif skipBool == "cooldown" then amp = xCooldown
		elseif skipBool == "duration" then amp = xDuration
		elseif skipBool == "range" then amp = xRange
		elseif skipBool == "AbilityCastRange" then amp = xAbilityCastRange
		else
			amp = xMultiplier
		end
	end
	if amp == nil or amp == 0 or not amp or amp < 0.00001 then
		return base
	end
	
	local final = self:RoundFloat( base * amp, 2)
	if final == nil or final == 0 or not final or final < 0.00001 then
		return base
	end
	return final
end

function modifier_spells_randomize_values:AlterNetTable(szAbilityName)
	local tAbilityTable = self.abilitiesAndVals[szAbilityName]
	-------------
	if tAbilityTable then
		for k,v in pairs(tAbilityTable) do
			local returnCheck = self:CheckExceptions(szAbilityName, k)
			if returnCheck == "radius" then tAbilityTable[k] = xRadius
			elseif returnCheck == "cooldown" then tAbilityTable[k] = xCooldown
			elseif returnCheck == "duration" then tAbilityTable[k] = xDuration
			elseif returnCheck == "range" then tAbilityTable[k] = xRange
			elseif returnCheck == "AbilityCastRange" then tAbilityTable[k] = xAbilityCastRange
			elseif not returnCheck then
				tAbilityTable[k] = xMultiplier
			end
		end
		-------------
		self.abilitiesAndVals[szAbilityName] = tAbilityTable
		CustomNetTables:SetTableValue("spell_amps_server", tostring( self:GetParent():GetPlayerOwnerID() ), self.abilitiesAndVals )
	end
end

function modifier_spells_randomize_values:RoundFloat( fNum, iDecimal )
	local iNths = (10^iDecimal)
	local fNum = fNum * iNths 
	return fNum / iNths
end

function modifier_spells_randomize_values:CheckExceptions(ability, val)
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
	-- Игнорируем умножение переменных указанных способностей
	-- Если нужно игнорировать переменную именно в этой способности
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
	elseif string.match(val, "range") or string.match(val, "Range") or string.match(val, "Distance") or string.match(val, "distance") or string.match(val, "length") or string.match(val, "Length") or string.match(val, "width") or string.match(val, "Width") then
		return "range"
	end
	-------------
	if string.match(val, "chance") or string.match(val, "bonus_cdr") then
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
	string.match(val, "reduction_pct")
	then
		return true
	end

	--Если переменная не попало под какое-либо определение, то умножаем
	return false
end