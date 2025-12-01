linken_king_bar_sphere_cooldown = class ({})

function RoundFloat(fNum, iDecimal)
	local iNths = (10^iDecimal)
	local fNum = fNum * iNths 
	return fNum / iNths
end

function linken_king_bar_sphere_cooldown:GetCooldown(Level)
    settings = CustomNetTables:GetTableValue("settings", "settings")
    local xCooldown = settings["xCooldown"]

    local LinkenData = GetAbilityKeyValuesByName("item_sphere")
    return RoundFloat(tonumber(LinkenData.AbilityValues.block_cooldown) * xCooldown, 2)
end