#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

#include scripts\zm\zm_transit\ztd_placeables\electric_trap;
#include scripts\zm\zm_transit\ztd_placeables\shield;
#include scripts\zm\zm_transit\ztd_placeables\turbine;
#include scripts\zm\zm_transit\ztd_placeables\turret;

main()
{
	precacheItem( "m32_zm" );
	precacheItem( "fnfal_zm" );
	precacheItem( "equip_turret_zm_turret" );
	precacheModel( "t6_wpn_zmb_raygun_world" );
	level thread on_player_connect();
	level thread command_thread();
}

on_player_connect()
{
	while ( true )
	{
		level waittill( "connected", player );
		player thread give_turret();
	}
}

command_thread()
{
	while ( true )
	{
		level waittill( "say", message, player, ishidden );
		if ( !ishidden )
		{
			continue;
		}
		commands = strTok( message, " " );
		if ( commands.size < 2 )
		{
			player iPrintln( "Usage: /give <item> [weapon]" );
			continue;
		}
		switch ( commands[ 0 ] )
		{
			case "give":
				switch ( commands[ 1 ] )
				{
					case "gasmask":
						player zombie_devgui_equipment_give( "equip_gasmask_zm" );
						break;
					case "hacker":
						player zombie_devgui_equipment_give( "equip_hacker_zm" );
						break;
					case "turbine":
						player zombie_devgui_equipment_give( "equip_turbine_zm" );
						break;
					case "turret":
						if ( isDefined( commands[ 2 ] ) )
						{
							level.custom_turret_weapon = commands[ 2 ];
						}
						player zombie_devgui_equipment_give( "equip_turret_zm" );
						break;
					case "electrictrap":
						player zombie_devgui_equipment_give( "equip_electrictrap_zm" );
						break;
					case "riotshield":
						player zombie_devgui_equipment_give( "riotshield_zm" );
						break;
					case "jetgun":
						player zombie_devgui_equipment_give( "jetgun_zm" );
						break;
					case "springpad":
						player zombie_devgui_equipment_give( "equip_springpad_zm" );
						break;
					case "subwoofer":
						player zombie_devgui_equipment_give( "equip_subwoofer_zm" );
						break;
					case "headchopper":
						player zombie_devgui_equipment_give( "equip_headchopper_zm" );
						break;
				}
				break;
		}

	}
}

zombie_devgui_equipment_give( equipment )
{
	if ( maps\mp\zombies\_zm_equipment::is_equipment_included( equipment ) )
		self maps\mp\zombies\_zm_equipment::equipment_buy( equipment );
}