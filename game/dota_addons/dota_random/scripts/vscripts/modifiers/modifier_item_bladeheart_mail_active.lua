modifier_item_bladeheart_mail_active = class({})

if IsClient() then
    settings = CustomNetTables:GetTableValue("settings", "settings")
end

function modifier_item_bladeheart_mail_active:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end
function modifier_item_bladeheart_mail_active:IsHidden() return false end
function modifier_item_bladeheart_mail_active:GetTexture() return "bladeheart_mail" end
function modifier_item_bladeheart_mail_active:IsDebuff() return false end
function modifier_item_bladeheart_mail_active:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end

function modifier_item_bladeheart_mail_active:OnCreated(event)
    if IsServer() then
        self:GetCaster():EmitSound("DOTA_Item.BladeMail.Activate")
    end
end

function modifier_item_bladeheart_mail_active:OnTakeDamage(kv)
    local target = kv.unit -- мы
    if target:IsOther() then return end

    local attacker = kv.attacker -- атакующий
    local damage = kv.damage -- урон которій нам нанесли
    local damage_type = kv.damage_type -- получаем тип урона который нам нанесли
    local damage_flags = kv.damage_flags -- флаги урона

    local ReflectDMGParam = self:GetAbility():GetSpecialValueFor("passive_reflection_constant")
    local ReflectDMGPctParam = self:GetAbility():GetSpecialValueFor("active_reflection_pct") / 100

    if attacker ~= self:GetParent() and not attacker:IsBuilding() and damage_flags ~= DOTA_DAMAGE_FLAG_HPLOSS and damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
        -- if not target:IsOther() then -- чтобы была не другая цель
        local ReflectDamage = (damage * ReflectDMGPctParam) + ReflectDMGParam
        local damage_table = {
            victim = attacker,
            attacker = target,
            damage = ReflectDamage,
            ability = self:GetAbility(), -- optional
            damage_type = damage_type,
            damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
        }
        ApplyDamage(damage_table)
    end
end