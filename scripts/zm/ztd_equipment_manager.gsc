#define EQUIPMENT_STARTING_HEALTH 10000
#define TURRET_DEFAULTS_CSV "mp/ztd_turret_defaults.csv"
#define TURRET_DEFAULTS_CSV_MAX_COLUMN 16

init()
{
	level.ztd_managed_equipment = [];

	level.ztd_managed_equipment_id = 0;

	level thread on_player_connecting();

	parse_turret_defaults_csv();
}

register_default_special_property( type, subtype, property, value )
{
	if ( !isDefined( level.ztd_special_property_defaults ) )
	{
		level.ztd_special_property_defaults = [];
	}

	if ( !isDefined( level.ztd_special_property_defaults[ type ] ) )
	{
		level.ztd_special_property_defaults[ type ] = [];
	}

	if ( !isDefined( level.ztd_special_property_defaults[ type ][ subtype ] ) )
	{
		level.ztd_special_property_defaults[ type ][ subtype ] = [];
	}

	level.ztd_special_property_defaults[ type ][ subtype ][ property ] = value;
}

parse_turret_defaults_csv()
{
	for ( i = 0; i < TURRET_DEFAULTS_CSV_MAX_COLUMN; i++ )
	{
		column_name = tablelookupcolumnforrow( TURRET_DEFAULTS_CSV, 0, i );

		for ( j = 1; tablelookuprownum( TURRET_DEFAULTS_CSV, 0, j ) > -1; j++ )
		{
			subtype = tablelookupcolumnforrow( TURRET_DEFAULTS_CSV, j, 0 );

			value_for_column = tablelookupcolumnforrow( TURRET_DEFAULTS_CSV, j, i );

			register_default_special_property( "equip_turret_zm", subtype, column_name, float( value_for_column ) );
		}
	}
}

private set_struct_field( field, value )
{
	structSet( self, field, value );
}

private get_struct_field( field )
{
	return structGet( self, field );
}

private copy_array_fields_into_struct( array )
{
	if ( !isDefined( array ) )
	{
		print( "copy_array_fields_into_struct: Invalid array" );
		return;
	}
	keys = getArrayKeys( array );
	for ( i = 0; i < keys.size; i++ )
	{
		self set_struct_field( keys[ i ], array[ keys[ i ] ] );
	}
}

copy_properties_into_struct( equipment_manager, type, subtype )
{
	if ( !isDefined( equipment_manager ) || !isDefined( equipment_manager.properties ) )
	{
		print( "copy_properties_into_struct: Invalid equipment manager" );
		return;
	}

	if ( !isDefined( level.zombie_equipment[ type ] ) )
	{
		print( "copy_properties_into_struct: Invalid equipment type" );
		return;
	}

	equipment_manager.properties copy_array_fields_into_struct( level.ztd_special_property_defaults[ type ][ subtype ] );
}

on_player_connecting()
{
	for (;;)
	{
		level waittill( "connecting", player );

		player thread on_player_disconnect();

		level.ztd_managed_equipment[ player getGUID() + "" ] = [];

		player.ztd_owned_equipment = [];
		player.current_inventory_equipment_manager = undefined;
		player.ztd_current_inventory_equipment_id = "-1";
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
	equipment_manager = spawnStruct();

	id = level.ztd_managed_equipment_id + "";

	equipment_manager.id = id;
	equipment_manager.status = status;
	equipment_manager.health = EQUIPMENT_STARTING_HEALTH;
	equipment_manager.damagetaken = 0;
	equipment_manager.type = type;
	equipment_manager.owner = player;
	equipment_manager.original_owner = player;
	equipment_manager.unitrigger = undefined;
	equipment_manager.placed_equipment = undefined;
	switch ( type )
	{
		case "equip_turret_zm":
			equipment_manager.turret = undefined;
			break;
	}
	equipment_manager.purchase_time = getTime();
	equipment_manager.place_time = undefined;

	equipment_manager.properties = spawnStruct();

	level.ztd_managed_equipment[ player getGUID() + "" ][ id ] = equipment_manager;

	player.ztd_owned_equipment[ id ] = equipment_manager;

	level.ztd_managed_equipment_id++;

	return equipment_manager;
}

delete_managed_equipment_for_player( player, equipment_manager )
{
	if ( !isDefined( equipment_manager ) )
	{
		print( "delete_managed_equipment_for_player: Attempted to delete equipment_manager but it didn't exist" );
		return;
	}
	level.ztd_managed_equipment[ player getGUID() + "" ][ equipment_manager.id ] = undefined;
	player.ztd_owned_equipment[ equipment_manager.id ] = undefined;
}

get_status_from_id( player, id )
{
	equipment_manager = player.ztd_owned_equipment[ id ]
	
	if ( !isDefined( equipment_manager ) )
	{
		print( "While getting status for equipment id " + id + " for " + player.name + " id was invalid" );
		return undefined;
	}

	return equip_manager.status;
}

transfer_equipment_manager_to_player( from_player, to_player, from_equipment_manager )
{
	from_id = from_equipment_manager.id;

	temp_equipment_manager_from = to_player.ztd_owned_equipment[ from_id ];

	temp_equipment_manager_from.owner = to_player;

	level.ztd_managed_equipment[ to_player getGUID() + "" ][ from_id ] = temp_equipment_manager_from;
	to_player.ztd_owned_equipment[ from_id ] = temp_equipment_manager_from;

	level.ztd_managed_equipment[ from_player getGUID() + "" ][ from_id ] = undefined;
	from_player.ztd_owned_equipment[ from_id ] = undefined;
}

get_total_equipment_placed_by_player_of_type( player, type )
{
	total = 0;

	if ( player.ztd_owned_equipment.size > 0 )
	{
		keys = getArrayKeys( player.ztd_owned_equipment );
		for ( i = 0; i < keys.size; i++ )
		{
			if ( player.ztd_owned_equipment[ keys[ i ] ].status == "field" && player.ztd_owned_equipment[ keys[ i ] ].type == type )
			{
				total++;
			}
		}
	}

	return total;
}

get_oldest_placed_equipment_for_player_of_type( player, type )
{
	oldest = 2147000000;

	oldest_equipment = undefined;

	keys = getArrayKeys( player.ztd_owned_equipment );

	for ( i = 0; i < keys.size; i++ )
	{
		if ( isDefined( player.ztd_owned_equipment[ keys[ i ] ].place_time ) && player.ztd_owned_equipment[ keys[ i ] ].place_time < oldest )
		{
			oldest_equipment = player.ztd_owned_equipment[ keys[ i ] ];
			oldest = player.ztd_owned_equipment[ keys[ i ] ].place_time
		}
	}

	return oldest_equipment;
}