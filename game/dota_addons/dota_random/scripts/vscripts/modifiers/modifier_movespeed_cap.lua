modifier_movespeed_cap = class({})

function modifier_movespeed_cap:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT
    }
    return funcs
end

function modifier_movespeed_cap:IsPermanent() return true end
function modifier_movespeed_cap:RemoveOnDeath() return false end
function modifier_movespeed_cap:IsHidden() return true end
function modifier_movespeed_cap:IsDebuff() return false end
-- function modifier_movespeed_cap:GetTexture() return "chaos_knight_chaos_strike" end -- get the icon from a different ability

function modifier_movespeed_cap:GetModifierIgnoreMovespeedLimit(params)
    return 1
end