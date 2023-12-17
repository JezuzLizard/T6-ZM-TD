

init()
{
	level.ztd_managed_equipment = [];

	level.ztd_managed_equipment_player_ids = [];

	level thread on_player_connecting();
}

on_player_connecting()
{
	for (;;)
	{
		level waittill( "connecting", player );

		player thread on_player_disconnect();

		level.ztd_managed_equipment[ player getGUID() + "" ] = [];

		level.ztd_managed_equipment_player_ids[ player getGUID() + "" ] = 0;

		player.ztd_owned_equipment = [];
		player.ztd_current_inventory_equipment_id = "-1";
		player.ztd_equip_manager_inst = undefined;
	}
}

on_player_disconnect()
{
	guid = self getGUID();
	self waittill( "disconnect" );

	level.ztd_managed_equipment[ guid + "" ] = undefined;
}

create_new_managed_equipment_for_player( player, type, status )
{
	equip_struct = spawnStruct();

	id = level.ztd_managed_equipment_player_ids + "";

	equip_struct.id = id;
	equip_struct.status = status;

	level.ztd_managed_equipment[ player getGUID() + "" ][ id ] = equip_struct;

	player.ztd_owned_equipment[ id ] = equip_struct;

	level.ztd_managed_equipment_player_ids++;

	equip_struct.type = type;

	return equip_struct;
}

delete_managed_equipment_for_player_by_id( player, id )
{
	level.ztd_managed_equipment[ player getGUID() + "" ][ id ] = undefined;
	player.ztd_owned_equipment[ id ] = undefined;
}

find_managed_equipment_for_player_by_id( player, equipment_manager )
{
	return isDefined( equipment_manager ) && isDefined( equipment_mananger.id ) && isDefined( player.ztd_owned_equipment[ id ] );
}

set_player_current_inventory_id( player, id )
{
	player.ztd_current_inventory_equipment_id = id;
}

set_player_current_equipment_manager_inst( player, equip_manager_inst )
{
	player.ztd_equip_manager_inst = equip_manager_inst;
}

get_status_from_id( player, id )
{
	equip_manager = player.ztd_owned_equipment[ id ]
	
	if ( !isDefined( equip_manager ) )
	{
		print( "While getting status for equipment id " + id + " for " + player.name + " id was invalid" );
		return undefined;
	}

	return equip_manager.status;
}

transfer_equipment_manager_to_player( from_player, to_player )
{
	temp_from = from_player.ztd_equip_manager_inst;
	temp_to = to_player.ztd_equip_manager_inst;

	level.ztd_managed_equipment[ player getGUID() + "" ][ id ] = undefined;
	player.ztd_owned_equipment[ id ] = undefined;

	temp_equip_struct_from = player.ztd_owned_equipment[ id ];

	from_player.ztd_equip_manager_inst = temp_to;
	to_player.ztd_equip_manager_inst = temp_from;
}