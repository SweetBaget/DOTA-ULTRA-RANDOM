"use strict";
var parsed_local = null;
var default_settings = null;
var total_skills_var = null;
var total_ultis_var = null;

function checkForHostPrivileges()
{
	var playerInfo = Game.GetLocalPlayerInfo();
	if (!playerInfo)
		return undefined;
	return playerInfo.player_has_host_privileges;
}

function Round(x, n) { //x - число, n - количество знаков 
  if(isNaN(x) || isNaN(n)) return false;
  var n = n * 10;
  return Math.round(x*n)/n;
}

function onInputFieldSubmit(slider, textEntry)
{   
    var sliderValue = null
    if (slider == "totalSkills" || slider == "totalUltis") {
        sliderValue = Round(Number($.GetContextPanel().GetParent().FindChildTraverse(textEntry).text)/100*10, 2)
    }
    else {
        sliderValue = (Number($.GetContextPanel().GetParent().FindChildTraverse(textEntry).text) - 1) / 999;
    }
    $.GetContextPanel().GetParent().FindChildTraverse(slider).value = sliderValue
}

function onSliderChanged(panelName)
{
    if (panelName == "totalSkills" || panelName == "totalUltis"){
        var oldTotalSkills_var = total_skills_var;
        var oldTotalUlts_var = total_ultis_var;
        total_skills_var = $.GetContextPanel().GetParent().FindChildTraverse("totalSkills").value;
        total_ultis_var = $.GetContextPanel().GetParent().FindChildTraverse("totalUltis").value;

        $.GetContextPanel().GetParent().FindChildTraverse("totalSkillsEntry").text = Math.round(total_skills_var * 10);
        $.GetContextPanel().GetParent().FindChildTraverse("totalUltisEntry").text = Math.round(total_ultis_var * 10);

        if (oldTotalSkills_var > total_skills_var && total_skills_var < oldTotalUlts_var) {
            $.GetContextPanel().GetParent().FindChildTraverse("totalUltis").value = $.GetContextPanel().GetParent().FindChildTraverse("totalSkills").value
        }
        if (total_ultis_var > oldTotalUlts_var && total_ultis_var > oldTotalSkills_var) {
            $.GetContextPanel().GetParent().FindChildTraverse("totalSkills").value = $.GetContextPanel().GetParent().FindChildTraverse("totalUltis").value
        }
    }
    else {
        $.Msg($.GetContextPanel().GetParent().FindChildTraverse(panelName).value);
        var sliderEntry = (panelName.charAt(0).toLowerCase() + panelName.slice(1)).concat("Entry")
        $.GetContextPanel().GetParent().FindChildTraverse(sliderEntry).text = Math.round(1 + ($.GetContextPanel().GetParent().FindChildTraverse(panelName).value * 999));
    }
}

function setGameMode()
{	
	GameEvents.SendCustomGameEventToServer("set_game_mode", 
	{
		"Gamemode": $.GetContextPanel().GetParent().FindChildTraverse("playMode").GetSelected().id,
		"sameHero": $.GetContextPanel().GetParent().FindChildTraverse("sameHero").checked,
        "precacheParticles": $.GetContextPanel().GetParent().FindChildTraverse("precacheParticles").checked,
		"disableAttackSpeedCap": $.GetContextPanel().GetParent().FindChildTraverse("disableAttackSpeedCap").checked,
		"disableAttributeBonuses": $.GetContextPanel().GetParent().FindChildTraverse("disableAttributeBonuses").checked,
		"easyMode": $.GetContextPanel().GetParent().FindChildTraverse("easyMode").checked,
		"ignoreMovespeedLimit": $.GetContextPanel().GetParent().FindChildTraverse("ignoreMovespeedLimit").checked,
		"innateAllowed": $.GetContextPanel().GetParent().FindChildTraverse("innateAllowed").checked,
		"buffStats": $.GetContextPanel().GetParent().FindChildTraverse("buffStats").checked,
		"buffCreeps": $.GetContextPanel().GetParent().FindChildTraverse("buffCreeps").checked,
		"buffTowers": $.GetContextPanel().GetParent().FindChildTraverse("buffTowers").checked,
		"disableFOG": $.GetContextPanel().GetParent().FindChildTraverse("disableFOG").checked,
		"fastRespawn": $.GetContextPanel().GetParent().FindChildTraverse("fastRespawn").checked,
		"freeScepter": $.GetContextPanel().GetParent().FindChildTraverse("freeScepter").checked,
		"maxLvl": $.GetContextPanel().GetParent().FindChildTraverse("maxLvl").checked,
		"creepsSkills": $.GetContextPanel().GetParent().FindChildTraverse("creepsSkills").checked,
		"Omg": $.GetContextPanel().GetParent().FindChildTraverse("randomSkills").checked,
		"totalSkills": Number($.GetContextPanel().GetParent().FindChildTraverse("totalSkillsEntry").text),
		"totalUltis": Number($.GetContextPanel().GetParent().FindChildTraverse("totalUltisEntry").text),
		"Radius":  Number($.GetContextPanel().GetParent().FindChildTraverse("radiusEntry").text),
		"Multiplier": Number($.GetContextPanel().GetParent().FindChildTraverse("multiplierEntry").text),
		"Cooldown": Number($.GetContextPanel().GetParent().FindChildTraverse("cooldownEntry").text),
		"Range": Number($.GetContextPanel().GetParent().FindChildTraverse("rangeEntry").text),
		"Duration": Number($.GetContextPanel().GetParent().FindChildTraverse("durationEntry").text),
		"abilityCastRange": Number($.GetContextPanel().GetParent().FindChildTraverse("abilityCastRangeEntry").text),
		"omgDM": $.GetContextPanel().GetParent().FindChildTraverse("changeSkillsOnDeath").checked,
		"Multicast": $.GetContextPanel().GetParent().FindChildTraverse("Multicast").checked,
		"xSlow": $.GetContextPanel().GetParent().FindChildTraverse("xSlow").checked,
		"xIllusion": $.GetContextPanel().GetParent().FindChildTraverse("xIllusion").checked,
		"xArmor": $.GetContextPanel().GetParent().FindChildTraverse("xArmor").checked,
		"xChance": $.GetContextPanel().GetParent().FindChildTraverse("xChance").checked,
        "developerMode": $.GetContextPanel().GetParent().FindChildTraverse("developerMode").checked,
        "customHeroMode": $.GetContextPanel().GetParent().FindChildTraverse("customHeroMode").checked
	});
}

function onCustomHeroModeClick()
{
    var customHeroModeButton = $.GetContextPanel().GetParent().FindChildTraverse('customHeroMode');
    var developerModeButton = $.GetContextPanel().GetParent().FindChildTraverse('developerMode');
    if (customHeroModeButton.checked == false) {
        developerModeButton.checked = customHeroModeButton.checked;
        developerModeButton.style["visibility"] = "collapse";
    }
    else {
        developerModeButton.style["visibility"] = "visible";
    }
}

function onRandomSkillsClick()
{
    var randomSkillGROUP = $.GetContextPanel().GetParent().FindChildTraverse('randomSkillsGroup');
    var creepsSkills = $.GetContextPanel().GetParent().FindChildTraverse('creepsSkills');
	var randomSkillsButton = $.GetContextPanel().GetParent().FindChildTraverse('randomSkills');
    var innateSkills = $.GetContextPanel().GetParent().FindChildTraverse('innateAllowed');
	var changeSkillsOnDeath = $.GetContextPanel().GetParent().FindChildTraverse('changeSkillsOnDeath');
	changeSkillsOnDeath.checked = randomSkillsButton.checked;
    creepsSkills.checked = randomSkillsButton.checked;
    innateSkills.checked = randomSkillsButton.checked;
    if (randomSkillsButton.checked == false) {
        randomSkillGROUP.style["visibility"] = "collapse";
    }
    else {
        randomSkillGROUP.style["visibility"] = "visible";
    }
}

function onHostPlayerConnected(DEFAULT_MODE_SETTINGS)
{
	default_settings = DEFAULT_MODE_SETTINGS
	$.Schedule(1, DrawHostDefaultGameModeUi)
}

function OnSettingsDone(parsed)
{
	parsed_local = parsed;
	$.Schedule(1, DrawGameModeUiSelected);
}



