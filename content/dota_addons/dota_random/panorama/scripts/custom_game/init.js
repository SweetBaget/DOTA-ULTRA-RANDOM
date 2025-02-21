// RELOAD GAME AFTER ANY CHANGE IN EVENTS SUBSCRIBERS
// GameEvents
$.RegisterForUnhandledEvent("DOTAHUDShowDamageArmorTooltip", removeAttributeResistance);
GameEvents.Subscribe("game_rules_state_change", catchGameState);

// CustomEvents
GameEvents.Subscribe("applyInitSettings", applyInitSettings);

function removeAttributeResistance()
{
    // $.Msg(rootHUD.FindChildTraverse("stragiint").FindChildTraverse("IntelligenceSumLabel"));
    var PlayerID = Players.GetLocalPlayer()
    if (PlayerID != null) {
        GameEvents.SendCustomGameEventToServer("removeAttributeResistance", {"PlayerID": PlayerID});
    }
}

function catchGameState(keys)
{
    if (Game.GameStateIs(DOTA_GameState.DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP) == true) {
        var playerID = Players.GetLocalPlayer();
        GameEvents.SendCustomGameEventToServer("executeFromServer", {"command": "setSettings", "playerID": playerID});
    }
}

function applyInitSettings(settings_table)
{
    var parentPanel = $.GetContextPanel().GetParent();
	parentPanel.FindChildTraverse("playMode").SetSelected(settings_table.Gamemode);
	parentPanel.FindChildTraverse("sameHero").checked = settings_table.sameHero;
    parentPanel.FindChildTraverse("precacheParticles").checked = settings_table.precacheParticles;
	parentPanel.FindChildTraverse("disableAttackSpeedCap").checked = settings_table.disableAttackSpeedCap;
	parentPanel.FindChildTraverse("disableAttributeBonuses").checked = settings_table.disableAttributeBonuses;
	parentPanel.FindChildTraverse("buffStats").checked = settings_table.buffStats;
	parentPanel.FindChildTraverse("ignoreMovespeedLimit").checked = settings_table.ignoreMovespeedLimit;
	parentPanel.FindChildTraverse("innateAllowed").checked = settings_table.innateAllowed;
	parentPanel.FindChildTraverse("easyMode").checked = settings_table.easyMode;
	parentPanel.FindChildTraverse("buffCreeps").checked = settings_table.buffCreeps;
	parentPanel.FindChildTraverse("buffTowers").checked = settings_table.buffTowers;
	parentPanel.FindChildTraverse("disableFOG").checked = settings_table.disableFOG;
	parentPanel.FindChildTraverse("fastRespawn").checked = settings_table.fastRespawn;
	parentPanel.FindChildTraverse("freeScepter").checked = settings_table.freeScepter;
	parentPanel.FindChildTraverse("maxLvl").checked = settings_table.maxLvl;

	parentPanel.FindChildTraverse("Multicast").checked = settings_table.Multicast;
	parentPanel.FindChildTraverse("creepsSkills").checked = settings_table.creepsSkills;
	parentPanel.FindChildTraverse("randomSkills").checked = settings_table.Omg;
	parentPanel.FindChildTraverse("changeSkillsOnDeath").checked = settings_table.omgDM;

    // преобразование от 1-1000 до 0-1
    // выставление значения слайдеров автоматически изменяет отображаемое текстовое значение
    // ЕСЛИ ЗНАЧЕНИЕ СЛАЙДЕРА ПО ИТОГУ РАВНО 0, ТО ТЕКСТОВОЕ ЗНАЧЕНИЕ НЕ ПРИСВОИТСЯ
	parentPanel.FindChildTraverse("totalSkills").value = settings_table.totalSkills / 10;
	parentPanel.FindChildTraverse("totalUltis").value = settings_table.totalUltis / 10;
    // если значение не меняется (изначально 0), то текстовое значение не изменится
    parentPanel.FindChildTraverse("Multiplier").value = (settings_table.Multiplier - 1) / 999;
    parentPanel.FindChildTraverse("Radius").value = (settings_table.Radius - 1) / 999;
	parentPanel.FindChildTraverse("Range").value = (settings_table.Range - 1) / 999;
	parentPanel.FindChildTraverse("abilityCastRange").value = (settings_table.abilityCastRange - 1) / 999;
	parentPanel.FindChildTraverse("Cooldown").value = 1;
    parentPanel.FindChildTraverse("Cooldown").value = (settings_table.Cooldown - 1) / 999;
    parentPanel.FindChildTraverse("Duration").value = 1;
    parentPanel.FindChildTraverse("Duration").value = (settings_table.Duration - 1) / 999;

	parentPanel.FindChildTraverse("xSlow").checked = settings_table.xSlow;
	parentPanel.FindChildTraverse("xIllusion").checked = settings_table.xIllusion;
	parentPanel.FindChildTraverse("xArmor").checked = settings_table.xArmor;
	parentPanel.FindChildTraverse("xChance").checked = settings_table.xChance;

    // из-за того, что элемент скрыт, программа не может найти состояние его параметра
    // parentPanel.FindChildTraverse("developerMode").checked = settings_table.developerMode;
    parentPanel.FindChildTraverse("customHeroMode").checked = settings_table.customHeroMode;
}