function giveSkill(skillName){
    $.Msg(skillName);
    var playerID = Players.GetLocalPlayer();
    var skillInfoPanel = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SkillParams")
    skillInfoPanel.GetChild(0).text = skillName
    GameEvents.SendCustomGameEventToServer("executeFromServer", {"command": "giveSkill", "skillName": skillName, "playerID": playerID});
}

function removeSkill(skillName){
    $.Msg(skillName, "удалён");
    var playerID = Players.GetLocalPlayer();
    GameEvents.SendCustomGameEventToServer("executeFromServer", {"command": "removeSkill", "skillName": skillName, "playerID": playerID});
}