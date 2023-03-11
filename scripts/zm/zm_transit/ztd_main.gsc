#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

#include scripts\zm\zm_transit\ztd_placeables\electric_trap;
#include scripts\zm\zm_transit\ztd_placeables\shield;
#include scripts\zm\zm_transit\ztd_placeables\turbine;
#include scripts\zm\zm_transit\ztd_placeables\turret;

main()
{
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
		level waitill( "say", message, player, ishidden );
		if ( !ishidden )
		{
			continue;
		}
		switch ( message )
		{
			case "give_gasmask":
				player zombie_devgui_equipment_give( "equip_gasmask_zm" );
				break;
			case "give_hacker":
				player zombie_devgui_equipment_give( "equip_hacker_zm" );
				break;
			case "give_turbine":
				player zombie_devgui_equipment_give( "equip_turbine_zm" );
				break;
			case "give_turret":
				player zombie_devgui_equipment_give( "equip_turret_zm" );
				break;
			case "give_electrictrap":
				player zombie_devgui_equipment_give( "equip_electrictrap_zm" );
				break;
			case "give_riotshield":
				player zombie_devgui_equipment_give( "riotshield_zm" );
				break;
			case "give_jetgun":
				player zombie_devgui_equipment_give( "jetgun_zm" );
				break;
			case "give_springpad":
				player zombie_devgui_equipment_give( "equip_springpad_zm" );
				break;
			case "give_subwoofer":
				player zombie_devgui_equipment_give( "equip_subwoofer_zm" );
				break;
			case "give_headchopper":
				player zombie_devgui_equipment_give( "equip_headchopper_zm" );
				break;
		}
	}
}

zombie_devgui_equipment_give( equipment )
{
	if ( maps\mp\zombies\_zm_equipment::is_equipment_included( equipment ) )
		self maps\mp\zombies\_zm_equipment::equipment_buy( equipment );
}