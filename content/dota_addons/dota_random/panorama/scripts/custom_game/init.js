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
	parentPanel.FindChildTraverse("TotalSkills").value = settings_table.TotalSkills / 10;
	parentPanel.FindChildTraverse("TotalUltis").value = settings_table.TotalUltis / 10;
    // если значение не меняется (изначально 0), то текстовое значение не изменится
    parentPanel.FindChildTraverse("xMultiplier").value = (settings_table.xMultiplier - 1) / 999;
    parentPanel.FindChildTraverse("xRadius").value = (settings_table.xRadius - 1) / 999;
	parentPanel.FindChildTraverse("xRange").value = (settings_table.xRange - 1) / 999;
	parentPanel.FindChildTraverse("xAbilityCastRange").value = (settings_table.xAbilityCastRange - 1) / 999;
	parentPanel.FindChildTraverse("xCooldown").value = 1;
    parentPanel.FindChildTraverse("xCooldown").value = (settings_table.xCooldown - 1) / 999;
    parentPanel.FindChildTraverse("xDuration").value = 1;
    parentPanel.FindChildTraverse("xDuration").value = (settings_table.xDuration - 1) / 999;
    parentPanel.FindChildTraverse("xSlow").value = 1;
    parentPanel.FindChildTraverse("xSlow").value = (settings_table.xSlow - 1) / 999;
    parentPanel.FindChildTraverse("xChance").value = 1;
    parentPanel.FindChildTraverse("xChance").value = (settings_table.xSlow - 1) / 999;
	parentPanel.FindChildTraverse("xResistances").value = 1;
    parentPanel.FindChildTraverse("xResistances").value = (settings_table.xResistances - 1) / 999;
    parentPanel.FindChildTraverse("xModelScale").value = 1;
    parentPanel.FindChildTraverse("xModelScale").value = (settings_table.xModelScale - 1) / 999;
    parentPanel.FindChildTraverse("xSpeed").value = 1;
    parentPanel.FindChildTraverse("xSpeed").value = (settings_table.xSpeed - 1) / 999;
    parentPanel.FindChildTraverse("xSkillsSpeed").value = 1;
    parentPanel.FindChildTraverse("xSkillsSpeed").value = (settings_table.xSkillsSpeed - 1) / 999;
    parentPanel.FindChildTraverse("xUnitsCount").value = 1;
    parentPanel.FindChildTraverse("xUnitsCount").value = (settings_table.xUnitsCount - 1) / 999;
    parentPanel.FindChildTraverse("xPercentScale").value = 1;
    parentPanel.FindChildTraverse("xPercentScale").value = (settings_table.xPercentScale - 1) / 999;

    // из-за того, что элемент скрыт, программа не может найти состояние его параметра
    // parentPanel.FindChildTraverse("developerMode").checked = settings_table.developerMode;
    parentPanel.FindChildTraverse("customHeroMode").checked = settings_table.customHeroMode;
}