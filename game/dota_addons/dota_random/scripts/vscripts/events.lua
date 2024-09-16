-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
  print("[BAREBONES] GameRules State Changed")
  PrintTable(keys)

  GameMode:_OnGameRulesStateChange(keys)
end

function GameMode:OnAbilityUsed(keys)
  if MULTICAST then
    Multicast:DoMulticast(keys)
  end
end

function GameMode:OnPlayerLearnedAbility( keys)
end

function GameMode:OnPlayerLevelUp(keys)
  local player = EntIndexToHScript(keys.player)
  local PlayerHero = player:GetAssignedHero()
  -- сделать скейл только хп
  if BUFF_STATS == true then
    -- Скейл силы
    PlayerHero:SetBaseStrength(PlayerHero:GetBaseStrength() + (PlayerHero:GetStrengthGain() * xMultiplier) - PlayerHero:GetStrengthGain())
    -- Скейл ловкости
    PlayerHero:SetBaseAgility(PlayerHero:GetBaseAgility() + (PlayerHero:GetAgilityGain() * xMultiplier) - PlayerHero:GetAgilityGain())
    -- Скейл интеллекта
    PlayerHero:SetBaseIntellect(PlayerHero:GetBaseIntellect() + (PlayerHero:GetIntellectGain() * xMultiplier) - PlayerHero:GetIntellectGain())

    PlayerHero:CalculateStatBonus(true)
  end
end

function GameMode:OnConnectFull(keys)
  GameMode:_OnConnectFull(keys)
end
