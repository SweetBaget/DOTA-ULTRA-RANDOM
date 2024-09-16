"use strict";

function OnDragEnter( a, draggedPanel )
{
    console.log("aboba")
    GameUI.SetDefaultUIEnabled(6, false);
    GameUI.SetDefaultUIEnabled(1, false);
	var draggedItem = draggedPanel.m_DragItem; 

	// only care about dragged items other than us
	if ( draggedItem === null || draggedItem == m_Item )
		return true;

	// highlight this panel as a drop target
	$.GetContextPanel().AddClass( "potential_drop_target" );
	return true;
}

function OnDragDrop( panelId, draggedPanel )
{
	var draggedItem = draggedPanel.m_DragItem;
	
	// only care about dragged items other than us
	if ( draggedItem === null )
		return true;

	var dropTarget = $.GetContextPanel();
	$.GetContextPanel().RemoveClass( "potential_drop_target" );

	// executing a slot swap - don't drop on the world
	draggedPanel.m_DragCompleted = true;
	
	// item dropped on itself? don't acutally do the swap (but consider the drag completed)
	if ( draggedItem == m_Item )
		return true;

	var pid = Game.GetLocalPlayerID();
	var unit = Players.GetLocalPlayerPortraitUnit()
	unit = Entities.IsControllableByPlayer( unit, pid ) ? unit : Players.GetPlayerHeroEntityIndex(pid);

	var action = PlayerTables.GetTableValue(m_contString, "OnDragTo");
	if (action !== 0){
		GameEvents.SendCustomGameEventToServer( "Containers_OnDragFrom", {unit:unit, contID:draggedPanel.m_contID, itemID:draggedItem, 
			fromSlot:draggedPanel.m_OriginalPanel.GetSlot(), toContID:m_contID, toSlot:m_slot} );
	}


	/*if (m_Container || container)
	{
		if (m_Container && container)
		{
			draggedPanel.m_OriginalPanel.SetItem(m_QueryUnit, m_Item, container);
			SetItem(draggedPanel.m_QueryUnit, draggedItem, m_Container);
		}
	}
	else
	{
		// create the order
		var moveItemOrder =
		{
			OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_ITEM,
			TargetIndex: m_ItemSlot,
			AbilityIndex: draggedItem
		};
		Game.PrepareUnitOrders( moveItemOrder );
	}*/
	return true;
}

function OnDragLeave( panelId, draggedPanel )
{
	var draggedItem = draggedPanel.m_DragItem;
	if ( draggedItem === null || draggedItem == m_Item )
		return false;

	// un-highlight this panel
	$.GetContextPanel().RemoveClass( "potential_drop_target" );
	return true;
}

function OnDragStart( panelId, dragCallbacks )
{
	if ( m_Item == -1 )
	{
		return true;
	}

	var action = PlayerTables.GetTableValue(m_contString, "OnDragDrop");
	var action2 = PlayerTables.GetTableValue(m_contString, "OnDragWorld");
	if (action === 0 && action2 === 0){
		return true;
	}

	var itemName = Abilities.GetAbilityName( m_Item );

	ItemHideTooltip(); // tooltip gets in the way

	// create a temp panel that will be dragged around
	var displayPanel = $.CreatePanel( "DOTAItemImage", $.GetContextPanel(), "dragImage" );
	displayPanel.itemname = itemName;
	displayPanel.contextEntityIndex = m_Item;
	displayPanel.m_DragItem = m_Item;
	displayPanel.m_contID = m_contID;
	displayPanel.m_DragCompleted = false; // whether the drag was successful
	displayPanel.m_OriginalPanel = $.GetContextPanel();
	displayPanel.m_QueryUnit = m_QueryUnit;

	// hook up the display panel, and specify the panel offset from the cursor
	dragCallbacks.displayPanel = displayPanel;
	dragCallbacks.offsetX = 0;
	dragCallbacks.offsetY = 0;
	
	// grey out the source panel while dragging
	$.GetContextPanel().AddClass( "dragging_from" );
	return true;
}

function OnDragEnd( panelId, draggedPanel )
{

	var action = PlayerTables.GetTableValue(m_contString, "OnDragWorld");

	if (!draggedPanel.m_DragCompleted && action === 1){
		var position = GameUI.GetScreenWorldPosition( GameUI.GetCursorPosition() );
		var mouseEntities = GameUI.FindScreenEntities( GameUI.GetCursorPosition() );
		var entity = null;

		var pid = Game.GetLocalPlayerID();
		var unit = Players.GetLocalPlayerPortraitUnit()
		unit = Entities.IsControllableByPlayer( unit, pid ) ? unit : Players.GetPlayerHeroEntityIndex(pid);

		if (mouseEntities.length !== 0){
			for ( var e of mouseEntities )
			{
				if ( e.accurateCollision ){
					entity = e.entityIndex;
					break;
				}
			}
		}
		GameEvents.SendCustomGameEventToServer( "Containers_OnDragWorld", {unit:unit, contID:m_contID, itemID:m_Item, slot:m_slot, position:position, entity:entity} );
	}

	// if the drag didn't already complete, then try dropping in the world
		//Game.DropItemAtCursor( m_QueryUnit, m_Item );

	// kill the display panel
	draggedPanel.DeleteAsync( 0 );

	// restore our look
	$.GetContextPanel().RemoveClass( "dragging_from" );
	return true;
}

(function()
{
	// Drag and drop handlers ( also requires 'draggable="true"' in your XML, or calling panel.SetDraggable(true) )
	$.RegisterEventHandler( 'DragEnter', $.GetContextPanel(), OnDragEnter );
	$.RegisterEventHandler( 'DragDrop', $.GetContextPanel(), OnDragDrop );
	$.RegisterEventHandler( 'DragLeave', $.GetContextPanel(), OnDragLeave );
	$.RegisterEventHandler( 'DragStart', $.GetContextPanel(), OnDragStart );
	$.RegisterEventHandler( 'DragEnd', $.GetContextPanel(), OnDragEnd );
})();