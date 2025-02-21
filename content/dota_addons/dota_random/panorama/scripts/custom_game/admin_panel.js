var sortedSkillsList = []

// CustomEvents
GameEvents.Subscribe("hideBox", hideBox);
GameEvents.Subscribe("fullSkillBox", fullSkillBox);
GameEvents.Subscribe("setSkillInfo", setSkillInfo);

function createChildParams(skillTable, parentParamName){
    var skillInfoPanel = $.GetContextPanel().FindChildTraverse("SkillParams");
    for (var key in skillTable) {
        var newParam = $.CreatePanel("Panel", skillInfoPanel, parentParamName);
        newParam.BLoadLayout("file://{resources}/layout/custom_game/skill_param.xml", false, false);
        newParam.GetChild(0).text = key.concat(": ");

        if (typeof skillTable[key] === "object") {
            createChildParams(skillTable[key], parentParamName)
        }
        else {
            newParam.GetChild(0).text = key.concat(": ");
            newParam.GetChild(1).text = skillTable[key];
        }
    }
}

function setSkillInfo(skillTable){
    var skillInfoPanel = $.GetContextPanel().FindChildTraverse("SkillParams");
    // первый (0) элемент не удаляем
    for (var i = 1; i < skillInfoPanel.GetChildCount(); i++){
        skillInfoPanel.GetChild(i).DeleteAsync(0)
    }
    for (var key in skillTable) {
        // главный параметр
        var newParam = $.CreatePanel("Panel", skillInfoPanel, key);
        newParam.BLoadLayout("file://{resources}/layout/custom_game/skill_param.xml", false, false);
        newParam.GetChild(0).text = key;

        if (typeof skillTable[key] === "object") {
            newParam.GetChild(2).DeleteAsync(1)
            createChildParams(skillTable[key], key)
        }
        else {
            newParam.GetChild(0).text = key.concat(": ");
            newParam.GetChild(1).text = skillTable[key];
        }

        newParam.style.marginTop = "20px";
    }
}

function fullSkillBox(skillsList)
{
    var SkillHandler = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SkillHandler");
    for (var key in skillsList) {
        if ("IsHidden" in skillsList[key]){
            // $.Msg("Это скрытый скилл");
            continue;
        }
        if ("IsInnateUI" in skillsList[key]){
            // $.Msg("Это врожденная способность в интерфейсе");
            continue;
        }
        if ("IsWorkingInnate" in skillsList[key]){
            // $.Msg("Рабочая врожденная способность");
            continue;
        }
        var newSkill = $.CreatePanel("Panel", SkillHandler, key);
        newSkill.BLoadLayout("file://{resources}/layout/custom_game/skill_button.xml", false, false);
        newSkill.GetChild(0).GetChild(0).SetImage("file://{images}/spellicons/".concat(key).concat(".png"));
    }
}

function switchWindow(boxName)
{
    var boxElement = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse(boxName);
    if (boxElement.style["visibility"] == "collapse") {
        boxElement.style["visibility"] = "visible";
    }
    else {
        boxElement.style["visibility"] = "collapse";
    }
}

function hideBox(tableInfo)
{
    var BoxElement = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse(tableInfo["boxName"]);
    BoxElement.style["visibility"] = "collapse";
    var CloseBoxElement = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Close".concat(tableInfo["boxName"]));
    CloseBoxElement.style["visibility"] = "collapse";
}