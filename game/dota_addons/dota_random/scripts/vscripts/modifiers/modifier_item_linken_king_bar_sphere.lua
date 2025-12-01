modifier_item_linken_king_bar_sphere = class({})

function modifier_item_linken_king_bar_sphere:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ABSORB_SPELL --Linken's Sphere trigger.
    }
    return funcs
end
function modifier_item_linken_king_bar_sphere:IsHidden() return false end
function modifier_item_linken_king_bar_sphere:GetTexture() return "sphere_png" end
function modifier_item_linken_king_bar_sphere:IsDebuff() return false end

function modifier_item_linken_king_bar_sphere:OnCreated()
    if IsClient() then return end
    local AddedAbility = self:GetParent():AddAbility("linken_king_bar_sphere_cooldown")
    AddedAbility:SetLevel(1)
    AddedAbility:SetHidden(true)

end
function modifier_item_linken_king_bar_sphere:OnDestroy()
    if IsClient() then return end
    self:GetParent():RemoveAbility("linken_king_bar_sphere_cooldown")
end

function modifier_item_linken_king_bar_sphere:GetAbsorbSpell(event)
    local CooldownAbility = self:GetParent():FindAbilityByName("linken_king_bar_sphere_cooldown")
    if CooldownAbility:IsCooldownReady() then
        local AbilityOwner = self:GetParent()
        -- нужно именно кастовать, а не запускать кулдаун, чтобы работал wtf мод
        AbilityOwner:CastAbilityImmediately(CooldownAbility, AbilityOwner:GetPlayerOwnerID())
        ParticleManager:CreateParticle("particles/items_fx/immunity_sphere.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
        if IsServer() then
            self:GetCaster():EmitSound("DOTA_Item.LinkensSphere.Activate")
        end
        return 1
    end
    return 0
end