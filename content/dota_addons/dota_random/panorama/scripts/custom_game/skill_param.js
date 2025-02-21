function acceptSkillParam(paramHandler){
    var changedValue = paramHandler.GetChild(2).text
    var changedParam = paramHandler.GetChild(0).text.replace(': ','');
    if (changedParam == "value") {
        changedParam = paramHandler.id
    }
    var skillInfoPanel = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("SkillParams")
    var playerID = Players.GetLocalPlayer();
    GameEvents.SendCustomGameEventToServer("executeFromServer", {"command": "changeSkillParam", "paramInfo": {"skillName": skillInfoPanel.GetChild(0).text, "skillParam": changedParam, "changedValue": changedValue}, "playerID": playerID});
}