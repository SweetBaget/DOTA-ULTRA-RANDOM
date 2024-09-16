"use strict";
var oldHeight = 0;
var parsed_local = null;
var default_settings = null;
var total_skills_var = null;
var total_ultis = null;
var oldChangeSkillCheck = true;

function CheckForHostPrivileges(panel)
{
	var playerInfo = Game.GetLocalPlayerInfo();
	if ( !playerInfo )
		return undefined;
	return playerInfo.player_has_host_privileges;
}
function GetPlayerId(panel)
{
	var playerInfo = Game.GetLocalPlayerInfo();
	if ( !playerInfo )
		return undefined;
	return playerInfo.player_id;
}

function DrawHostDefaultGameModeUi() {
	var gameModePanel = $.CreatePanel( "Panel", $.GetContextPanel(), "" );
	gameModePanel.BLoadLayout("file://{resources}/layout/custom_game/game_mode.xml", false, false);
	// startup animation
	gameModePanel.style.x = '-250px';
	gameModePanel.style.opacity = 0;
	ApplyUiSettings(gameModePanel, default_settings)
	AnimatePanel(gameModePanel, {"transform": "translateX(250px);", "opacity": "1;" }, 1.0, "ease-out");
}

function ApplyUiSettings (panel, settings_table)
{
	panel.FindChildTraverse("PlayMode").SetSelected(settings_table.gamemode);
	panel.FindChildTraverse("same_hero").checked = settings_table.same_hero;
	panel.FindChildTraverse("disableAttackSpeedCap").checked = settings_table.disableAttackSpeedCap;
	panel.FindChildTraverse("buffStats").checked = settings_table.buff_stats;
	panel.FindChildTraverse("ignore_movespeed_limit").checked = settings_table.ignore_movespeed_limit;
	panel.FindChildTraverse("INNATE_ALLOWED").checked = settings_table.INNATE_ALLOWED;
	panel.FindChildTraverse("easyMode").checked = settings_table.easy_mode;
	panel.FindChildTraverse("buffCreeps").checked = settings_table.buff_creeps;
	panel.FindChildTraverse("buffTowers").checked = settings_table.buff_towers;
	panel.FindChildTraverse("DisableFOG").checked = settings_table.DisableFOG;
	panel.FindChildTraverse("fastRespawn").checked = settings_table.fast_respawn;
	panel.FindChildTraverse("freeScepter").checked = settings_table.free_scepter;
	panel.FindChildTraverse("max_lvl").checked = settings_table.max_lvl;
	panel.FindChildTraverse("creepsSkills").checked = settings_table.creepsSkills;
	panel.FindChildTraverse("randomSkills").checked = settings_table.omg;
	panel.FindChildTraverse("changeSkillsOnDeath").checked = settings_table.omgdm;
	panel.FindChildTraverse("multicast").checked = settings_table.multicast;
	panel.FindChildTraverse("slowbool").checked = settings_table.slow;
	panel.FindChildTraverse("xIllusion").checked = settings_table.xIllusion;
	panel.FindChildTraverse("xArmor").checked = settings_table.xArmor;
	panel.FindChildTraverse("chancebool").checked = settings_table.chance;
	panel.FindChildTraverse("TotalSkills").value = settings_table.total_skills;
	total_skills_var = settings_table.total_skills;
	panel.FindChildTraverse("TotalUltis").value = settings_table.total_ultis;
	total_ultis = settings_table.total_ultis;
    panel.FindChildTraverse("Radius").value = settings_table.radius;
    panel.FindChildTraverse("Multiplier").value = settings_table.multiplier;
	panel.FindChildTraverse("Range").value = settings_table.range;
	panel.FindChildTraverse("AbilityCastRange").value = settings_table.abilitycastrange;
	panel.FindChildTraverse("Cooldown").value = settings_table.cooldown;
	panel.FindChildTraverse("Duration").value = settings_table.duration;
}

function DrawGameModeUiSelected() {
	DrawGameModeUiNonHost();
}

function DrawGameModeUiNonHost(panel)
{
	var gameModePanel = undefined;

	gameModePanel = $.CreatePanel( "Panel", $.GetContextPanel(), "" );
	gameModePanel.BLoadLayout("file://{resources}/layout/custom_game/game_mode.xml", false, false);

	gameModePanel.style.x = '-250px';
	gameModePanel.style.opacity = 0;
	gameModePanel.SetHasClass('not_host', true);
	gameModePanel.FindChildTraverse('Group1').SetHasClass('not_host', true);
	gameModePanel.FindChildTraverse('GroupRdnSk').SetHasClass('not_host', true);
	gameModePanel.FindChildTraverse('SettingsDone').SetHasClass('invisible', false);

	gameModePanel.SetHasClass('invisible', false);
	ApplyUiSettings(gameModePanel, parsed_local)
	gameModePanel.enabled = false;
	AnimatePanel(gameModePanel, { "transform": "translateX(250px);", "opacity": "1;" }, 1.0, "ease-out"); 
}

function PlayerConnected()
{
	var isHost = CheckForHostPrivileges();
	if (!Game.GetLocalPlayerInfo()){
		$.Schedule(1, PlayerConnected);
		return;
		}	
	if (!isHost) {
	GameEvents.SendCustomGameEventToServer( "NonHostConnected", {} );
	}
	if (isHost) {
		GameEvents.SendCustomGameEventToServer( "HostConnected", {} );
	}
}

function roundPlus(x, n) { //x - число, n - количество знаков 
  if(isNaN(x) || isNaN(n)) return false;
  var n = n * 10
  return Math.round(x*n)/n;
}

function OnSkillsSliderExit()
{
	if (!$.GetContextPanel().FindChildTraverse('GroupRdnSk').enabled)
		return;

	var oldTotalSkills_var = total_skills_var
	var oldTotalUlts_var = total_ultis
	var TotalUltisNotchValue = 0.1
	var TotalSkillsNotchValue = 0.111111
	total_skills_var = $.GetContextPanel().FindChildTraverse("TotalSkills").value
	total_ultis = $.GetContextPanel().FindChildTraverse("TotalUltis").value


	if (oldTotalSkills_var > total_skills_var && total_skills_var < oldTotalUlts_var)
		$.GetContextPanel().FindChildTraverse("TotalUltis").value = $.GetContextPanel().FindChildTraverse("TotalSkills").value/TotalSkillsNotchValue*TotalUltisNotchValue+TotalUltisNotchValue
	if (total_ultis > oldTotalUlts_var && total_ultis > oldTotalSkills_var)
		$.GetContextPanel().FindChildTraverse("TotalSkills").value = $.GetContextPanel().FindChildTraverse("TotalUltis").value/TotalUltisNotchValue*TotalSkillsNotchValue-TotalSkillsNotchValue
}
function SetGameMode()
{	
	var isHost = CheckForHostPrivileges();
	if (!isHost)
		return;
	OnSkillsSliderExit()
	console.log($.GetContextPanel().FindChildTraverse("TotalSkills").value);
	GameEvents.SendCustomGameEventToServer("set_game_mode", 
	{
		"gamemode": $.GetContextPanel().FindChildTraverse("PlayMode").GetSelected().id,
		"same_hero": $.GetContextPanel().FindChildTraverse("same_hero").checked,
		"disableAttackSpeedCap": $.GetContextPanel().FindChildTraverse("disableAttackSpeedCap").checked,
		"easy_mode": $.GetContextPanel().FindChildTraverse("easyMode").checked,
		"ignore_movespeed_limit": $.GetContextPanel().FindChildTraverse("ignore_movespeed_limit").checked,
		"INNATE_ALLOWED": $.GetContextPanel().FindChildTraverse("INNATE_ALLOWED").checked,
		"buff_stats": $.GetContextPanel().FindChildTraverse("buffStats").checked,
		"buff_creeps": $.GetContextPanel().FindChildTraverse("buffCreeps").checked,
		"buff_towers": $.GetContextPanel().FindChildTraverse("buffTowers").checked,
		"DisableFOG": $.GetContextPanel().FindChildTraverse("DisableFOG").checked,
		"fast_respawn": $.GetContextPanel().FindChildTraverse("fastRespawn").checked,
		"free_scepter": $.GetContextPanel().FindChildTraverse("freeScepter").checked,
		"max_lvl": $.GetContextPanel().FindChildTraverse("max_lvl").checked,
		"creepsSkills": $.GetContextPanel().FindChildTraverse("creepsSkills").checked,
		"omg": $.GetContextPanel().FindChildTraverse("randomSkills").checked,
		"total_skills": $.GetContextPanel().FindChildTraverse("TotalSkills").value,
		"total_ultis": $.GetContextPanel().FindChildTraverse("TotalUltis").value,
		"radius": roundPlus($.GetContextPanel().FindChildTraverse("Radius").value, 1),
		"multiplier": roundPlus($.GetContextPanel().FindChildTraverse("Multiplier").value, 1),
		"cooldown": roundPlus($.GetContextPanel().FindChildTraverse("Cooldown").value, 1),
		"range": roundPlus($.GetContextPanel().FindChildTraverse("Range").value, 1),
		"duration": roundPlus($.GetContextPanel().FindChildTraverse("Duration").value, 1),
		"abilitycastrange": roundPlus($.GetContextPanel().FindChildTraverse("AbilityCastRange").value, 1),
		"omgdm": $.GetContextPanel().FindChildTraverse("changeSkillsOnDeath").checked,
		"multicast": $.GetContextPanel().FindChildTraverse("multicast").checked,
		"slow": $.GetContextPanel().FindChildTraverse("slowbool").checked,
		"xIllusion": $.GetContextPanel().FindChildTraverse("xIllusion").checked,
		"xArmor": $.GetContextPanel().FindChildTraverse("xArmor").checked,
		"chance": $.GetContextPanel().FindChildTraverse("chancebool").checked
	});
}



function OnRandomSkillsClick()
{
	var grndsk = $.GetContextPanel().FindChildTraverse('GroupRdnSk');
	var gamemodetext = $.GetContextPanel().FindChildTraverse('GameModeText');
	var changeSkillsOnDeath = $.GetContextPanel().FindChildTraverse('changeSkillsOnDeath');
	if (grndsk.enabled) {
		grndsk.style.height = "0px";
		gamemodetext.style.margin = "0px 0px 0px 0px";
		grndsk.enabled = false;
		oldChangeSkillCheck = changeSkillsOnDeath.checked;
		changeSkillsOnDeath.checked = false;
	} else {
		grndsk.style.height = "300px";
		grndsk.enabled = true;
		changeSkillsOnDeath.checked = oldChangeSkillCheck;
	}
}

GameEvents.Subscribe("PlayerConnected", OnSettingsDone)
GameEvents.Subscribe("HostPlayerConnected", OnHostPlayerConnected)
GameEvents.Subscribe("settings_done", OnSettingsDone)

function OnHostPlayerConnected(DEFAULT_MODE_SETTINGS)
{
	default_settings = DEFAULT_MODE_SETTINGS
	$.Schedule(1, DrawHostDefaultGameModeUi)
}

function OnSettingsDone(parsed)
{
	parsed_local = parsed;
	$.Schedule(1, DrawGameModeUiSelected);
}

