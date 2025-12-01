modifier_item_linken_king_bar_active = class({})

function RoundFloat(fNum, iDecimal)
	local iNths = (10^iDecimal)
	local fNum = fNum * iNths 
	return fNum / iNths
end

local BlackKingBarData = GetAbilityKeyValuesByName("item_black_king_bar")
    
function modifier_item_linken_king_bar_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_MODEL_SCALE,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE
    }
    return funcs
end
function modifier_item_linken_king_bar_active:IsHidden() return false end
function modifier_item_linken_king_bar_active:GetTexture() return "linken_king_bar" end
function modifier_item_linken_king_bar_active:IsDebuff() return false end
function modifier_item_linken_king_bar_active:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_item_linken_king_bar_active:OnCreated(event)
    if IsServer() then
        self:GetCaster():EmitSound("DOTA_Item.BlackKingBar.Activate")
    end
end

function modifier_item_linken_king_bar_active:OnDestroy(event)
    if self.BKBParticle then
        ParticleManager:DestroyParticle(self.BKBParticle, false)
    end
end

function modifier_item_linken_king_bar_active:GetModifierModelScale()
    if IsClient() then
        settings = CustomNetTables:GetTableValue("settings", "settings")
        xModelScale = settings["xModelScale"]
    end
    local FinalValue = RoundFloat(tonumber(BlackKingBarData.AbilityValues.model_scale) * xModelScale, 2)
    return FinalValue
end

function modifier_item_linken_king_bar_active:GetModifierMagicalResistanceBonus()
    if IsClient() then
        settings = CustomNetTables:GetTableValue("settings", "settings")
        xResistances = settings["xResistances"]
    end
    local FinalValue = RoundFloat(tonumber(BlackKingBarData.AbilityValues.magic_resist) * xResistances, 2)
    return FinalValue
end

function modifier_item_linken_king_bar_active:GetAbsoluteNoDamagePure()
    return 1
end