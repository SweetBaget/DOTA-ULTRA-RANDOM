modifier_frozen_skadi_LVL2 = class({})

function RoundFloat(fNum, iDecimal)
	local iNths = (10^iDecimal)
	local fNum = fNum * iNths 
	return fNum / iNths
end

local FrozenSkadiData = GetAbilityKeyValuesByName("item_frozen_skadi")
print("tut")
PrintTable(FrozenSkadiData)
    
function modifier_frozen_skadi_LVL2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_MODEL_SCALE,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE
    }
    return funcs
end
function modifier_frozen_skadi_LVL2:IsHidden() return false end
function modifier_frozen_skadi_LVL2:GetTexture() return "linken_king_bar" end
function modifier_frozen_skadi_LVL2:IsDebuff() return false end

function modifier_frozen_skadi_LVL2:GetManaCost(ItemLevel)
    return 0
end

function modifier_frozen_skadi_LVL2:GetCooldown(ItemLevel)
    return 0
end

function modifier_frozen_skadi_LVL2:GetItemCost()
    return 0
end