#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_spawner;

#include scripts\zm\zm_transit\ztd_placeables\electric_trap;
#include scripts\zm\zm_transit\ztd_placeables\shield;
#include scripts\zm\zm_transit\ztd_placeables\turbine;
#include scripts\zm\zm_transit\ztd_placeables\turret;

main()
{
	replaceFunc( maps\mp\zombies\_zm_utility::spawn_zombie, ::spawn_zombie_override );
	replaceFunc( maps\mp\zombies\_zm_spawner::zombie_death_points, ::zombie_death_points_override );
	level thread on_player_connect();
	level thread command_thread();
}

init()
{
}

spawn_zombie_override( spawner, target_name, spawn_point, round_number )
{
	if ( !isdefined( spawner ) )
	{
/#
		println( "ZM >> spawn_zombie - NO SPAWNER DEFINED" );
#/
		return undefined;
	}

	while ( getfreeactorcount() < 1 )
		wait 0.05;

	spawner.script_moveoverride = 1;

	if ( isdefined( spawner.script_forcespawn ) && spawner.script_forcespawn )
	{
		guy = spawner spawnactor();

		if ( isdefined( level.giveextrazombies ) )
			guy [[ level.giveextrazombies ]]();

		guy enableaimassist();

		if ( isdefined( round_number ) )
			guy._starting_round_number = round_number;

		guy.aiteam = level.zombie_team;
		guy clearentityowner();
		level.zombiemeleeplayercounter = 0;
		guy thread run_spawn_functions();
		guy forceteleport( spawner.origin );
		guy show();

		guy ztd_spawn_funcs();
	}

	spawner.count = 666;

	if ( !spawn_failed( guy ) )
	{
		if ( isdefined( target_name ) )
			guy.targetname = target_name;

		return guy;
	}

	return undefined;
}

ztd_spawn_funcs()
{
	//self.actor_killed_override = ::ztd_actor_killed;
	self thread ztd_on_damage();
}

ztd_on_damage()
{
	self endon( "death" );
	while ( true )
	{ 
		self waittill( "damage", amount, attacker, direction, point, mod, tagname, modelname, partname, weaponname, idflags );
		if ( !isDefined( attacker ) )
		{
			continue;
		}
		if ( !isSubStr( attacker.classname, "turret" ) )
		{
			continue;
		}
		if ( !isDefined( attacker.owner ) )
		{
			continue;
		}
		attacker.owner maps\mp\zombies\_zm_score::player_add_points( "damage", mod, self.damagelocation, is_true( self.isdog ), attacker.team );
	}
}

/*
ztd_actor_killed( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime )
{
	if ( attacker.classname == "misc_turret" && isDefined( attacker.owner ) )
	{
		player player_add_points( event, mod, hit_location, is_dog, zombie_team, damage_weapon )
	}
}
*/

zombie_death_points_override( origin, mod, hit_location, attacker, zombie, team )
{
	if ( !isdefined( attacker ) )
		return;

	if ( zombie_can_drop_powerups( zombie ) )
	{
		if ( isdefined( zombie.in_the_ground ) && zombie.in_the_ground == 1 )
		{
			trace = bullettrace( zombie.origin + vectorscale( ( 0, 0, 1 ), 100.0 ), zombie.origin + vectorscale( ( 0, 0, -1 ), 100.0 ), 0, undefined );
			origin = trace["position"];
			level thread zombie_delay_powerup_drop( origin );
		}
		else
		{
			trace = groundtrace( zombie.origin + vectorscale( ( 0, 0, 1 ), 5.0 ), zombie.origin + vectorscale( ( 0, 0, -1 ), 300.0 ), 0, undefined );
			origin = trace["position"];
			level thread zombie_delay_powerup_drop( origin );
		}
	}

	if ( isPlayer( attacker ) )
	{
		level thread maps\mp\zombies\_zm_audio::player_zombie_kill_vox( hit_location, attacker, mod, zombie );
	}
	
	event = "death";

	if ( isdefined( zombie.damageweapon ) && issubstr( zombie.damageweapon, "knife_ballistic_" ) && ( mod == "MOD_MELEE" || mod == "MOD_IMPACT" ) )
		event = "ballistic_knife_death";

	if ( isdefined( zombie.deathpoints_already_given ) && zombie.deathpoints_already_given )
		return;

	zombie.deathpoints_already_given = 1;

	if ( isdefined( zombie.damageweapon ) && is_equipment( zombie.damageweapon ) )
		return;

	if ( isPlayer( attacker ) )
	{
		attacker maps\mp\zombies\_zm_score::player_add_points( event, mod, hit_location, undefined, team, attacker.currentweapon );
	}
	else if ( isSubStr( attacker.classname, "turret" ) && isDefined( attacker.owner ) )
	{
		attacker.owner maps\mp\zombies\_zm_score::player_add_points( event, mod, hit_location, undefined, team, attacker.currentweapon );
		attacker.owner.kills++;
	}
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