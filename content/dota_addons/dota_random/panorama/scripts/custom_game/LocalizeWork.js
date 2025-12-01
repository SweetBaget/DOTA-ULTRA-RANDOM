"use strict";
// CustomEvents
GameEvents.Subscribe("ChangeItemLocalize", ChangeItemLocalize);

function ChangeItemLocalize(keys){
    var Ability = keys["Ability"];
    var Value = keys.Value;
    $.Msg("ДОБЖВИЛЬ");
    var parent = $.GetContextPanel().GetParent().GetParent().GetParent();
    
    $.Msg(parent.FindChildTraverse("AbilityAttributes").text);
    // эта штука находит нужную нам штуку по её id и меняет параметр(например text)
    parent.FindChildTraverse("AbilityAttributes").text = "300 bucks";
}