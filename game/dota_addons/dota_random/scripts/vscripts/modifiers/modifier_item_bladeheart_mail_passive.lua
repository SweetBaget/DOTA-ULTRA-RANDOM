modifier_item_bladeheart_mail_passive = class({})

if IsClient() then
    settings = CustomNetTables:GetTableValue("settings", "settings")
end

function modifier_item_bladeheart_mail_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end
function modifier_item_bladeheart_mail_passive:IsHidden() return true end

function modifier_item_bladeheart_mail_passive:OnTakeDamage(kv)
    local target = kv.unit -- мы
    if target:IsOther() then return end
    if target:HasModifier("modifier_item_bladeheart_mail_active") then return end

    local attacker = kv.attacker -- атакующий
    local damage = kv.damage -- урон которій нам нанесли
    local damage_type = kv.damage_type -- получаем тип урона который нам нанесли
    local damage_flags = kv.damage_flags -- флаги урона

    local ReflectDMGParam = self:GetAbility():GetSpecialValueFor("passive_reflection_constant")
    local ReflectDMGPctParam = self:GetAbility():GetSpecialValueFor("passive_reflection_pct") / 100

    if attacker ~= self:GetParent() and not attacker:IsBuilding() and damage_flags ~= DOTA_DAMAGE_FLAG_HPLOSS and damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION and damage_type == 1 then
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