#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_equip_turret;
#include maps\mp\zombies\_zm_weapons;

#include scripts\zm\_gametype_setup;

#include scripts\zm\zm_transit\ztd_placeables\electric_trap;
#include scripts\zm\zm_transit\ztd_placeables\shield;
#include scripts\zm\zm_transit\ztd_placeables\turbine;
#include scripts\zm\zm_transit\ztd_placeables\turret;

#include scripts\zm\zm_transit\ztd_utility;

main()
{
	replaceFunc( maps\mp\zombies\_zm_utility::spawn_zombie, ::spawn_zombie_override );
	replaceFunc( maps\mp\zombies\_zm_utility::has_deployed_equipment, ::has_deployed_equipment_override );
	replaceFunc( maps\mp\zombies\_zm_utility::init_zombie_run_cycle, ::init_zombie_run_cycle_override );
	replaceFunc( maps\mp\zombies\_zm_spawner::zombie_death_points, ::zombie_death_points_override );
	//replaceFunc( maps\mp\zombies\_zm_spawner::zombie_pathing, ::zombie_pathing_override );
	//replaceFunc( maps\mp\zombies\_zm_ai_basic::find_flesh, ::find_flesh_override );
	//replaceFunc( maps\mp\zombies\_zm_zonemgr::zone_init, ::zone_init_override );
	replaceFunc( maps\mp\zombies\_zm::init_levelvars, ::init_levelvars_override );
	//replaceFunc( maps\mp\zombies\_zm_utility::wait_network_frame, ::wait_network_frame_override );
	//replaceFunc( maps\mp\animscripts\zm_utility::wait_network_frame, ::wait_network_frame_override );
	replaceFunc( maps\mp\zombies\_zm_utility::include_weapon, ::include_weapon_override );
	replaceFunc( maps\mp\gametypes_zm\_zm_gametype::menu_init, ::menu_init_override );

	replaceFunc( maps\mp\zm_transit_classic::init_bus, ::init_bus_override );
	replaceFunc( maps\mp\zm_transit_classic::banking_and_weapon_locker_main, ::banking_and_weapon_locker_main_override );
	replaceFunc( maps\mp\zm_transit_sq::init, ::sq_init_override );
	replaceFunc( maps\mp\zm_transit_sq::start_transit_sidequest, ::start_transit_sidequest_override );
	replaceFunc( maps\mp\zm_transit_power::initializepower, ::initializepower_override );

	level.round_spawn_func = ::round_spawning_override;
	level.round_think_func = ::round_think_override;
	//level.create_spawner_list_func = ::create_spawner_list_override;

	delete_buildable_parts();

	level thread on_player_connect();
	level thread command_thread();
	level thread menu_onmenuresponse();

	print( getDvar( "ztd_gametype" ) );
	print( getDvar( "ztd_location" ) );
}

init()
{
	precacheshellshock( "electrocution" );
	if ( getDvar( "g_gametype" ) != "zclassic" )
	{
		maps\mp\zombies\_zm_equip_turbine::init();
		maps\mp\zombies\_zm_equip_turret::init();
		maps\mp\zombies\_zm_equip_electrictrap::init();
	}

	level.ignore_equipment = ::zombie_ignore_equipment;

	/*
	level.loaded_weapon_names = getAllLoadedWeaponNames();

	foreach ( weapon_name in level.loaded_weapon_names )
	{
		if ( weapon_name == "" )
		{
			continue;
		}
		dumpWeapon( weapon_name, level.weapon_dump_path );

		path = level.weapon_parse_path;
		file = path + "/" + weapon_name + ".json";
		if ( fileExists( file ) )
		{
			parseWeapon( weapon_name, path );
		}

		//setWeaponField( weapon_name, "barreltype", "Quad Barrel Double Alternate" );
	}
	*/

	level.ztd_turret_types = [];
	level.ztd_turret_types[ 0 ] = "sticky_grenade_zm";
	level.ztd_turret_types[ 1 ] = "m1911_upgraded_zm";
	level.ztd_turret_types[ 2 ] = "judge_zm";
	level.ztd_turret_types[ 3 ] = "fivesevendw_zm";
	level.ztd_turret_types[ 4 ] = "saritch_zm";
	level.ztd_turret_types[ 5 ] = "galil_zm";
	level.ztd_turret_types[ 6 ] = "dsr50_zm";
	level.ztd_turret_types[ 7 ] = "rpd_zm";
	level.ztd_turret_types[ 8 ] = "usrpg_zm";
	level.ztd_turret_types[ 9 ] = "ray_gun_zm";
	level.ztd_turret_types[ 10 ] = "knife_ballistic_zm";
	level.ztd_turret_types[ 11 ] = "raygun_mark2_upgraded_zm";

	level.closest_player_override = undefined;

	level waittill( "connected", player );
	player waittill( "spawned_player" );
	wait 5;

	player notify( "stop_player_out_of_playable_area_monitor" );
	level.player_out_of_playable_area_monitor = false;
	while ( true )
	{
		level.player_out_of_playable_area_monitor = false;
		wait 0.05;
	}
}

all_zombies_path_to_exit( position_to_play )
{
	attractor_point = spawn( "script_model", position_to_play );
	attractor_point setmodel( "tag_origin" );
	attractor_point create_zombie_point_of_interest( 1536, 32, 10000 );
	attractor_point.attract_to_origin = 1;
	attractor_point thread create_zombie_point_of_interest_attractor_positions( 4, 45 );
	attractor_point thread maps\mp\zombies\_zm_weap_cymbal_monkey::wait_for_attractor_positions_complete();
}

ztd_normal_transit()
{
	print( "Running gametype " + getDvar( "ztd_gametype" ) + " on location " + getDvar( "ztd_location" ) );
	/*
	level.zombie_spawn_locations = [];
	level.enemy_dog_locations = [];
	level.zombie_screecher_locations = [];
	level.zombie_avogadro_locations = [];
	level.zombie_leaper_locations = [];
	level.zombie_brutus_locations = [];
	level.zombie_mechz_locations = [];
	//Corner back area on bus depot
	register_ztd_zombie_spawn( "zombie", undefined, undefined, "riser_location", ( -6017.34, 5444.38, -63.8758 ), ( 0, 45, 0 ) );
	register_ztd_zombie_spawn( "zombie", undefined, undefined, "riser_location", ( -6078.86, 5510.25, -63.875 ), ( 0, 45, 0 ) );
	register_ztd_zombie_spawn( "zombie", undefined, undefined, "riser_location", ( -6168.16, 5503.32, -55.875 ), ( 0, 45, 0 ) );
	register_ztd_zombie_spawn( "zombie", undefined, undefined, "riser_location", ( -6276.78, 5503.59, -55.875 ), ( 0, 45, 0 ) );
	register_ztd_zombie_spawn( "zombie", undefined, undefined, "riser_location", ( -6278.29, 5422.87, -55.875 ), ( 0, 45, 0 ) );
	register_ztd_zombie_spawn( "zombie", undefined, undefined, "riser_location", ( -6171.77, 5423.03, -55.875 ), ( 0, 45, 0 ) );
	register_ztd_zombie_spawn( "zombie", undefined, undefined, "riser_location", ( -6136.35, 5358.91, -63.875 ), ( 0, 45, 0 ) );
	*/
	level.struct_class_names[ "script_noteworthy" ][ "inert_location" ] = [];

	//Exit
	//exit_point = ( -7893.29, 4764.46, -57.8442 );
	//level thread all_zombies_path_to_exit( exit_point );
}

register_ztd_zombie_spawn( ai_type, zone = "none", script_string = "find_flesh", spawn_type, origin, angles )
{
	spawn_location = spawnStruct();
	spawn_location.ai_type = ai_type;
	spawn_location.script_string = script_string;
	spawn_location.targetname = zone;
	spawn_location.origin = origin;
	spawn_location.angles = angles;
	spawn_location.script_noteworthy = spawn_type;
	spawn_location.is_blocked = false;
	switch ( spawn_type )
	{
		case "dog_location":
			level.enemy_dog_locations[ level.enemy_dog_locations.size ] = spawn_location;
			break;
		case "screecher_location":
			level.zombie_screecher_locations[ level.zombie_screecher_locations.size ] = spawn_location;
			break;
		case "avogadro_location":
			level.zombie_avogadro_locations[ level.zombie_avogadro_locations.size ] = spawn_location;
			break;
		case "leaper_location":
			level.zombie_leaper_locations[ level.zombie_leaper_locations.size ] = spawn_location;
			break;
		case "brutus_location":
			level.zombie_brutus_locations[ level.zombie_brutus_locations.size ] = spawn_location;
			break;
		case "mechz_location":
			level.zombie_mechz_locations[ level.zombie_mechz_locations.size ] = spawn_location;
			break;
		case "riser_location":
			print( "register_ztd_zombie_spawn() added riser_location" );
			level.zombie_spawn_locations[ level.zombie_spawn_locations.size ] = spawn_location;
			break;
	}
}

print_origin()
{
	self endon( "disconnect" );
	while ( true )
	{
		debug_mode = getDvarInt( "ztd_print_debug" );
		if ( debug_mode <= 0 )
		{
			wait 0.1;
			continue;
		}
		if ( self meleeButtonPressed() )
		{
			origin_str = "origin: " + self.origin;
			angles_str = "angles: " + self.angles;
			anglestoforward_str = "anglestoforward: " + anglesToForward( self.angles );
			zone_str = self maps\mp\zombies\_zm_zonemgr::get_player_zone();
			turrets_owned_str = self.name + " owns " + self.owned_turrets.size + " turrets";
			total_turrets_owned_str = getEntArray( "misc_turret", "classname" );

			logprint( origin_str + "\n" );
			logprint( angles_str + "\n" );
			logprint( anglestoforward_str + "\n" );
			logprint( turrets_owned_str + "\n" );

			
			print( origin_str );
			print( angles_str );
			print( anglestoforward_str );
			print( turrets_owned_str );
			if ( isDefined( zone_str ) )
			{
				zone_message_str = self.name + " is in " + zone_str + " zone";
				logprint( zone_message_str + "\n" );
				print( zone_message_str );
				zone_str = undefined;
				zone_message_str = undefined;
			}
			if ( isDefined( total_turrets_owned_str ) )
			{
				turret_message_str = "There are " + total_turrets_owned_str.size + " total turrets with a max of " + getDvarIntDefault( "sv_max_turrets", 96 );
				logprint( turret_message_str + "\n" );
				print( turret_message_str );
				turret_message_str = undefined;
			}
			origin_str = undefined;
			angles_str = undefined;
			anglestoforward_str = undefined;
			turrets_owned_str = undefined;
			while ( self meleeButtonPressed() )
				wait 0.05;
		}

		wait 0.05;
	}
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
	self thread ztd_pathing();
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

ztd_pathing()
{
	
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
		player.owned_turrets = [];
		player thread print_origin();
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
		switch ( commands[ 0 ] )
		{
			case "give":
				if ( commands.size < 2 )
				{
					player iPrintln( "Usage: /give <item> [weapon]" );
					continue;
				}
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
							if ( commands[ 2 ] == "random" )
							{
								player.custom_turret_weapon = level.ztd_turret_types[ randomInt( level.ztd_turret_types.size ) ];
							}
							else 
							{
								player.custom_turret_weapon = commands[ 2 ];
							}
						}
						else 
						{
							player.custom_turret_weapon = "zombie_bullet_crouch_zm";
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
					case "weapon":
						if ( commands.size < 3 )
						{
							player iPrintLn( "Usage: /give weapon <weapon>" );
							continue;
						}
						player weapon_give( commands[ 2 ] );
						break;
				}
				break;
			case "dumpturrets":
				if ( isDefined( player.owned_turrets ) )
				{
					for ( i = 0; i < player.owned_turrets.size; i++ )
					{
						dumpTurret( player.owned_turrets[ i ].turret, player.owned_turrets[ i ].turret.currentweapon + "_user_dumped_" + player.name + "_" + i );
					}
				}
				break;
			case "dumpallturrets":
				foreach ( player in level.players )
				{
					if ( isDefined( player.owned_turrets ) )
					{
						for ( i = 0; i < player.owned_turrets.size; i++ )
						{
							dumpTurret( player.owned_turrets[ i ].turret, player.owned_turrets[ i ].turret.currentweapon + "_user_dumped_" + player.name + "_" + i );
						}
					}
				}
				break;
			case "points":
				if ( isDefined( commands[ 1 ] ) )
				{
					points_val = int( commands[ 1 ] );
				}
				else 
				{
					points_val = 10000;
				}
				player.score += points_val;
				break;
			case "spawnturret":
				if ( isDefined( commands[ 1 ] ) )
				{
					count = int( commands[ 1 ] );
				}
				else 
				{
					count = 1;
				}

				player.custom_turret_weapon = "zombie_bullet_crouch_zm";
				if ( isDefined( commands[ 3 ] ) )
				{
					//points = create_polygon( player.origin, count, int( commands[ 3 ] ) );
					//points = create_spiral( player.origin, int( commands[ 3 ] ) );
					points = create_sphere( player.origin, int( commands[ 3 ] ) );
					foreach ( point in points )
					{
						if ( commands[ 2 ] == "random" )
						{
							player.custom_turret_weapon = level.ztd_turret_types[ randomInt( self.ztd_turret_types.size ) ];
						}
						else 
						{
							player.custom_turret_weapon = commands[ 2 ];
						}
						player startturretdeploy2( point );
					}
				}
				else 
				{
					for ( i = 0; i < count; i++ )
					{
						if ( isDefined( commands[ 2 ] ) )
						{
							if ( commands[ 2 ] == "random" )
							{
								player.custom_turret_weapon = level.ztd_turret_types[ randomInt( self.ztd_turret_types.size ) ];
							}
							else 
							{
								player.custom_turret_weapon = commands[ 2 ];
							}
						}
						player startturretdeploy2();
					}
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

has_deployed_equipment_override( weaponname )
{
	return false;
}

find_flesh_override()
{
	self endon( "death" );
	level endon( "intermission" );
	self endon( "stop_find_flesh" );

	if ( level.intermission )
		return;

	self.ai_state = "find_flesh";
	self.helitarget = 1;
	self.ignoreme = 0;
	self.nododgemove = 1;
	self.ignore_player = [];
	self maps\mp\zombies\_zm_spawner::zombie_history( "find flesh -> start" );
	self.goalradius = 32;

	if ( isdefined( self.custom_goalradius_override ) )
		self.goalradius = self.custom_goalradius_override;

	while ( true )
	{
		zombie_poi = undefined;

		if ( isdefined( level.zombietheaterteleporterseeklogicfunc ) )
			self [[ level.zombietheaterteleporterseeklogicfunc ]]();

		if ( isdefined( level._poi_override ) )
			zombie_poi = self [[ level._poi_override ]]();

		if ( !isdefined( zombie_poi ) )
			zombie_poi = self get_zombie_point_of_interest( self.origin );

		players = get_players();

		if ( !isdefined( self.ignore_player ) || players.size == 1 )
			self.ignore_player = [];
		else if ( !isdefined( level._should_skip_ignore_player_logic ) || ![[ level._should_skip_ignore_player_logic ]]() )
		{
			i = 0;

			while ( i < self.ignore_player.size )
			{
				if ( isdefined( self.ignore_player[i] ) && isdefined( self.ignore_player[i].ignore_counter ) && self.ignore_player[i].ignore_counter > 3 )
				{
					self.ignore_player[i].ignore_counter = 0;
					self.ignore_player = arrayremovevalue( self.ignore_player, self.ignore_player[i] );

					if ( !isdefined( self.ignore_player ) )
						self.ignore_player = [];

					i = 0;
					continue;
				}

				i++;
			}
		}

		player = get_closest_valid_player( self.origin, self.ignore_player );

		if ( !isdefined( player ) && !isdefined( zombie_poi ) )
		{
			self maps\mp\zombies\_zm_spawner::zombie_history( "find flesh -> can't find player, continue" );

			if ( isdefined( self.ignore_player ) )
			{
				if ( isdefined( level._should_skip_ignore_player_logic ) && [[ level._should_skip_ignore_player_logic ]]() )
				{
					wait 1;
					continue;
				}

				self.ignore_player = [];
			}

			wait 1;
			continue;
		}

		if ( !isdefined( level.check_for_alternate_poi ) || ![[ level.check_for_alternate_poi ]]() )
		{
			self.enemyoverride = zombie_poi;
			self.favoriteenemy = player;
		}

		self thread zombie_pathing_override();

		if ( players.size > 1 )
		{
			for ( i = 0; i < self.ignore_player.size; i++ )
			{
				if ( isdefined( self.ignore_player[i] ) )
				{
					if ( !isdefined( self.ignore_player[i].ignore_counter ) )
					{
						self.ignore_player[i].ignore_counter = 0;
						continue;
					}

					self.ignore_player[i].ignore_counter += 1;
				}
			}
		}

		self thread attractors_generated_listener();

		if ( isdefined( level._zombie_path_timer_override ) )
			self.zombie_path_timer = [[ level._zombie_path_timer_override ]]();
		else
			self.zombie_path_timer = gettime() + randomfloatrange( 1, 3 ) * 1000;

		while ( gettime() < self.zombie_path_timer )
			wait 0.1;

		self notify( "path_timer_done" );
		self maps\mp\zombies\_zm_spawner::zombie_history( "find flesh -> bottom of loop" );
		debug_print( "Zombie is re-acquiring enemy, ending breadcrumb search" );
		self notify( "zombie_acquire_enemy" );
	}
}

zombie_pathing_override()
{
	self endon( "death" );
	self endon( "zombie_acquire_enemy" );
	level endon( "intermission" );
	assert( isdefined( self.favoriteenemy ) || isdefined( self.enemyoverride ) );
	self._skip_pathing_first_delay = 1;
	self thread zombie_follow_enemy();

	self waittill( "bad_path" );

	level.zombie_pathing_failed++;

	if ( isdefined( self.enemyoverride ) )
	{
		debug_print( "Zombie couldn't path to point of interest at origin: " + self.enemyoverride[0] + " Falling back to breadcrumb system" );

		if ( isdefined( self.enemyoverride[1] ) )
		{
			self.enemyoverride = self.enemyoverride[1] invalidate_attractor_pos( self.enemyoverride, self );
			self.zombie_path_timer = 0;
			return;
		}
	}
	else if ( isdefined( self.favoriteenemy ) )
		debug_print( "Zombie couldn't path to player at origin: " + self.favoriteenemy.origin + " Falling back to breadcrumb system" );
	else
		debug_print( "Zombie couldn't path to a player ( the other 'prefered' player might be ignored for encounters mode ). Falling back to breadcrumb system" );

	if ( !isdefined( self.favoriteenemy ) )
	{
		self.zombie_path_timer = 0;
		return;
	}
	else
		self.favoriteenemy endon( "disconnect" );

	players = get_players();
	valid_player_num = 0;

	for ( i = 0; i < players.size; i++ )
	{
		if ( is_player_valid( players[i], 1 ) )
			valid_player_num += 1;
	}

	if ( players.size > 1 )
	{
		if ( isdefined( level._should_skip_ignore_player_logic ) && [[ level._should_skip_ignore_player_logic ]]() )
		{
			self.zombie_path_timer = 0;
			return;
		}

		if ( array_check_for_dupes( self.ignore_player, self.favoriteenemy ) )
			self.ignore_player[self.ignore_player.size] = self.favoriteenemy;

		if ( self.ignore_player.size < valid_player_num )
		{
			self.zombie_path_timer = 0;
			return;
		}
	}

	crumb_list = self.favoriteenemy.zombie_breadcrumbs;
	bad_crumbs = [];

	while ( true )
	{
		if ( !is_player_valid( self.favoriteenemy, 1 ) )
		{
			self.zombie_path_timer = 0;
			return;
		}

		goal = zombie_pathing_get_breadcrumb( self.favoriteenemy.origin, crumb_list, bad_crumbs, randomint( 100 ) < 20 );

		if ( !isdefined( goal ) )
		{
			debug_print( "Zombie exhausted breadcrumb search" );
			level.zombie_breadcrumb_failed++;
			goal = self.favoriteenemy.spectator_respawn.origin;
		}

		debug_print( "Setting current breadcrumb to " + goal );
		self.zombie_path_timer += 100;
		self setgoalpos( goal );

		self waittill( "bad_path" );

		debug_print( "Zombie couldn't path to breadcrumb at " + goal + " Finding next breadcrumb" );

		for ( i = 0; i < crumb_list.size; i++ )
		{
			if ( goal == crumb_list[i] )
			{
				bad_crumbs[bad_crumbs.size] = i;
				break;
			}
		}
	}
}

zombie_follow_enemy()
{
	self endon( "death" );
	self endon( "zombie_acquire_enemy" );
	self endon( "bad_path" );
	level endon( "intermission" );

	if ( !isdefined( level.repathnotifierstarted ) )
	{
		level.repathnotifierstarted = 1;
		level thread zombie_repath_notifier();
	}

	if ( !isdefined( self.zombie_repath_notify ) )
		self.zombie_repath_notify = "zombie_repath_notify_" + self getentitynumber() % 4;

	while ( true )
	{
		if ( !isdefined( self._skip_pathing_first_delay ) )
			level waittill( self.zombie_repath_notify );
		else
			self._skip_pathing_first_delay = undefined;

		if ( !( isdefined( self.ignore_enemyoverride ) && self.ignore_enemyoverride ) && isdefined( self.enemyoverride ) && isdefined( self.enemyoverride[1] ) )
		{
			if ( distancesquared( self.origin, self.enemyoverride[0] ) > 1 )
				self orientmode( "face motion" );
			else
				self orientmode( "face point", self.enemyoverride[1].origin );

			self.ignoreall = 1;
			goalpos = self.enemyoverride[0];

			if ( isdefined( level.adjust_enemyoverride_func ) )
				goalpos = self [[ level.adjust_enemyoverride_func ]]();

			self setgoalpos( goalpos );
		}
		else if ( isdefined( self.favoriteenemy ) )
		{
			self.ignoreall = 0;
			self orientmode( "face default" );
			goalpos = self.favoriteenemy.origin;

			if ( isdefined( level.enemy_location_override_func ) )
				goalpos = [[ level.enemy_location_override_func ]]( self, self.favoriteenemy );

			self setgoalpos( goalpos );

			if ( !isdefined( level.ignore_path_delays ) )
			{
				distsq = distancesquared( self.origin, self.favoriteenemy.origin );

				if ( distsq > 10240000 )
					wait( 2.0 + randomfloat( 1.0 ) );
				else if ( distsq > 4840000 )
					wait( 1.0 + randomfloat( 0.5 ) );
				else if ( distsq > 1440000 )
					wait( 0.5 + randomfloat( 0.5 ) );
			}
		}

		if ( isdefined( level.inaccesible_player_func ) )
			self [[ level.inaccessible_player_func ]]();
	}
}

round_think_override( restart = 0 )
{
/#
	println( "ZM >> round_think start" );
#/
	level endon( "end_round_think" );

	if ( !( isdefined( restart ) && restart ) )
	{
		if ( isdefined( level.initial_round_wait_func ) )
			[[ level.initial_round_wait_func ]]();

		if ( !( isdefined( level.host_ended_game ) && level.host_ended_game ) )
		{
			players = get_players();

			foreach ( player in players )
			{
				if ( !( isdefined( player.hostmigrationcontrolsfrozen ) && player.hostmigrationcontrolsfrozen ) )
				{
					player freezecontrols( 0 );
/#
					println( " Unfreeze controls 8" );
#/
				}

				player maps\mp\zombies\_zm_stats::set_global_stat( "rounds", level.round_number );
			}
		}
	}

	setroundsplayed( level.round_number );

	for (;;)
	{
		maxreward = 50 * level.round_number;

		if ( maxreward > 500 )
			maxreward = 500;

		level.zombie_vars["rebuild_barrier_cap_per_round"] = maxreward;
		level.pro_tips_start_time = gettime();
		level.zombie_last_run_time = gettime();

		if ( isdefined( level.zombie_round_change_custom ) )
			[[ level.zombie_round_change_custom ]]();
		else
		{
			level thread maps\mp\zombies\_zm_audio::change_zombie_music( "round_start" );
			round_one_up();
		}

		maps\mp\zombies\_zm_powerups::powerup_round_start();
		players = get_players();
		array_thread( players, maps\mp\zombies\_zm_blockers::rebuild_barrier_reward_reset );

		if ( !( isdefined( level.headshots_only ) && level.headshots_only ) && !restart )
			level thread award_grenades_for_survivors();

		bbprint( "zombie_rounds", "round %d player_count %d", level.round_number, players.size );
/#
		println( "ZM >> round_think, round=" + level.round_number + ", player_count=" + players.size );
#/
		level.round_start_time = gettime();

		print( "round_think()" );
		while ( level.zombie_spawn_locations.size <= 0 )
			wait 0.1;

		level thread [[ level.round_spawn_func ]]();
		level notify( "start_of_round" );
		recordzombieroundstart();
		players = getplayers();

		for ( index = 0; index < players.size; index++ )
		{
			zonename = players[index] get_current_zone();

			if ( isdefined( zonename ) )
				players[index] recordzombiezone( "startingZone", zonename );
		}

		if ( isdefined( level.round_start_custom_func ) )
			[[ level.round_start_custom_func ]]();

		[[ level.round_wait_func ]]();
		level.first_round = 0;
		level notify( "end_of_round" );
		level thread maps\mp\zombies\_zm_audio::change_zombie_music( "round_end" );
		uploadstats();

		if ( isdefined( level.round_end_custom_logic ) )
			[[ level.round_end_custom_logic ]]();

		players = get_players();

		if ( isdefined( level.no_end_game_check ) && level.no_end_game_check )
		{
			level thread last_stand_revive();
			level thread spectators_respawn();
		}
		else if ( 1 != players.size )
			level thread spectators_respawn();

		players = get_players();
		array_thread( players, maps\mp\zombies\_zm_pers_upgrades_system::round_end );
		timer = level.zombie_vars["zombie_spawn_delay"];

		if ( timer > 0.08 )
			level.zombie_vars["zombie_spawn_delay"] = timer * 0.95;
		else if ( timer < 0.08 )
			level.zombie_vars["zombie_spawn_delay"] = 0.08;

		if ( level.gamedifficulty == 0 )
			level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
		else
			level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];

		level.round_number++;

		if ( 255 < level.round_number )
			level.round_number = 255;

		setroundsplayed( level.round_number );
		matchutctime = getutc();
		players = get_players();

		foreach ( player in players )
		{
			if ( level.curr_gametype_affects_rank && level.round_number > 3 + level.start_round )
				player maps\mp\zombies\_zm_stats::add_client_stat( "weighted_rounds_played", level.round_number );

			player maps\mp\zombies\_zm_stats::set_global_stat( "rounds", level.round_number );
			player maps\mp\zombies\_zm_stats::update_playing_utc_time( matchutctime );
		}

		check_quickrevive_for_hotjoin();
		level round_over();
		level notify( "between_round_over" );
		restart = 0;
	}
}

round_spawning_override()
{
	level endon( "intermission" );
	level endon( "end_of_round" );
	level endon( "restart_round" );
/#
	level endon( "kill_round" );
#/
	if ( level.intermission )
		return;

	ai_calculate_health( level.round_number );
	count = 0;
	players = get_players();

	for ( i = 0; i < players.size; i++ )
		players[i].zombification_time = 0;

	max = level.zombie_vars["zombie_max_ai"];
	multiplier = level.round_number / 5;

	if ( multiplier < 1 )
		multiplier = 1;

	if ( level.round_number >= 10 )
		multiplier *= ( level.round_number * 0.15 );

	player_num = get_players().size;

	if ( player_num == 1 )
		max += int( 0.5 * level.zombie_vars["zombie_ai_per_player"] * multiplier );
	else
		max += int( ( player_num - 1 ) * level.zombie_vars["zombie_ai_per_player"] * multiplier );

	if ( !isdefined( level.max_zombie_func ) )
		level.max_zombie_func = ::default_max_zombie_func;

	if ( !( isdefined( level.kill_counter_hud ) && level.zombie_total > 0 ) )
	{
		level.zombie_total = [[ level.max_zombie_func ]]( max );
		level notify( "zombie_total_set" );
	}

	if ( isdefined( level.zombie_total_set_func ) )
		level thread [[ level.zombie_total_set_func ]]();

	if ( level.round_number < 10 || level.speed_change_max > 0 )
		level thread zombie_speed_up();

	mixed_spawns = 0;
	old_spawn = undefined;

	while ( true )
	{
		while ( get_current_zombie_count() >= level.zombie_ai_limit || level.zombie_total <= 0 )
			wait 0.1;

		while ( get_current_actor_count() >= level.zombie_actor_limit )
		{
			clear_all_corpses();
			wait 0.1;
		}

		while ( getDvarInt( "ztd_disable_zombie_spawning" ) == 1 )
		{
			wait 0.1;
		}

		flag_wait( "spawn_zombies" );

		while ( level.zombie_spawn_locations.size <= 0 )
		{
			print( "no spawn locations available" );
			wait 0.1;
		}

		run_custom_ai_spawn_checks();
		spawn_point = level.zombie_spawn_locations[randomint( level.zombie_spawn_locations.size )];

		if ( !isdefined( old_spawn ) )
			old_spawn = spawn_point;
		else if ( spawn_point == old_spawn )
			spawn_point = level.zombie_spawn_locations[randomint( level.zombie_spawn_locations.size )];

		old_spawn = spawn_point;

		if ( isdefined( level.zombie_spawners ) )
		{
			if ( isdefined( level.use_multiple_spawns ) && level.use_multiple_spawns )
			{
				if ( isdefined( spawn_point.script_int ) )
				{
					if ( isdefined( level.zombie_spawn[spawn_point.script_int] ) && level.zombie_spawn[spawn_point.script_int].size )
						spawner = random( level.zombie_spawn[spawn_point.script_int] );
					else
					{
/#
						assertmsg( "Wanting to spawn from zombie group " + spawn_point.script_int + "but it doens't exist" );
#/
					}
				}
				else if ( isdefined( level.zones[spawn_point.zone_name].script_int ) && level.zones[spawn_point.zone_name].script_int )
					spawner = random( level.zombie_spawn[level.zones[spawn_point.zone_name].script_int] );
				else if ( isdefined( level.spawner_int ) && ( isdefined( level.zombie_spawn[level.spawner_int].size ) && level.zombie_spawn[level.spawner_int].size ) )
					spawner = random( level.zombie_spawn[level.spawner_int] );
				else
					spawner = random( level.zombie_spawners );
			}
			else
				spawner = random( level.zombie_spawners );

			ai = spawn_zombie( spawner, spawner.targetname, spawn_point );
		}

		if ( isdefined( ai ) )
		{
			level.zombie_total--;
			ai thread round_spawn_failsafe();
			count++;
		}

		wait( level.zombie_vars["zombie_spawn_delay"] );
		wait_network_frame();
	}
}

init_levelvars_override()
{
	level.is_zombie_level = 1;
	level.laststandpistol = "m1911_zm";
	level.default_laststandpistol = "m1911_zm";
	level.default_solo_laststandpistol = "m1911_upgraded_zm";
	level.start_weapon = "m1911_zm";
	level.first_round = 1;
	level.start_round = getgametypesetting( "startRound" );
	level.round_number = level.start_round;
	level.enable_magic = getgametypesetting( "magic" );
	level.headshots_only = getgametypesetting( "headshotsonly" );
	level.player_starting_points = level.round_number * 500;
	level.round_start_time = 0;
	level.pro_tips_start_time = 0;
	level.intermission = 0;
	level.dog_intermission = 0;
	level.zombie_total = 0;
	level.total_zombies_killed = 0;
	level.hudelem_count = 0;
	level.current_zombie_array = [];
	level.current_zombie_count = 0;
	level.zombie_total_subtract = 0;
	level.destructible_callbacks = [];
	level.zombie_vars = [];

	foreach ( team in level.teams )
		level.zombie_vars[team] = [];

	difficulty = 1;
	column = int( difficulty ) + 1;
	set_zombie_var( "zombie_health_increase", 100, 0, column );
	set_zombie_var( "zombie_health_increase_multiplier", 0.1, 1, column );
	set_zombie_var( "zombie_health_start", 150, 0, column );
	set_zombie_var( "zombie_spawn_delay", 2.0, 1, column );
	set_zombie_var( "zombie_new_runner_interval", 10, 0, column );
	set_zombie_var( "zombie_move_speed_multiplier", 8, 0, column );
	set_zombie_var( "zombie_move_speed_multiplier_easy", 2, 0, column );
	set_zombie_var( "zombie_max_ai", 24, 0, column );
	set_zombie_var( "zombie_ai_per_player", 6, 0, column );
	set_zombie_var( "below_world_check", -1000 );
	set_zombie_var( "spectators_respawn", 1 );
	set_zombie_var( "zombie_use_failsafe", 1 );
	set_zombie_var( "zombie_between_round_time", 10 );
	set_zombie_var( "zombie_intermission_time", 15 );
	set_zombie_var( "game_start_delay", 0, 0, column );
	set_zombie_var( "penalty_no_revive", 0.1, 1, column );
	set_zombie_var( "penalty_died", 0.0, 1, column );
	set_zombie_var( "penalty_downed", 0.05, 1, column );
	set_zombie_var( "starting_lives", 1, 0, column );
	set_zombie_var( "zombie_score_kill_4player", 50 );
	set_zombie_var( "zombie_score_kill_3player", 50 );
	set_zombie_var( "zombie_score_kill_2player", 50 );
	set_zombie_var( "zombie_score_kill_1player", 50 );
	set_zombie_var( "zombie_score_kill_4p_team", 30 );
	set_zombie_var( "zombie_score_kill_3p_team", 35 );
	set_zombie_var( "zombie_score_kill_2p_team", 45 );
	set_zombie_var( "zombie_score_kill_1p_team", 0 );
	set_zombie_var( "zombie_score_damage_normal", 10 );
	set_zombie_var( "zombie_score_damage_light", 10 );
	set_zombie_var( "zombie_score_bonus_melee", 80 );
	set_zombie_var( "zombie_score_bonus_head", 50 );
	set_zombie_var( "zombie_score_bonus_neck", 20 );
	set_zombie_var( "zombie_score_bonus_torso", 10 );
	set_zombie_var( "zombie_score_bonus_burn", 10 );
	set_zombie_var( "zombie_flame_dmg_point_delay", 500 );
	set_zombie_var( "zombify_player", 0 );

	if ( issplitscreen() )
		set_zombie_var( "zombie_timer_offset", 280 );

	level thread init_player_levelvars();
	level.gamedifficulty = getgametypesetting( "zmDifficulty" );

	if ( level.gamedifficulty == 0 )
		level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
	else
		level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];

	if ( level.round_number == 1 )
		level.zombie_move_speed = 1;
	else
	{
		for ( i = 1; i <= level.round_number; i++ )
		{
			timer = level.zombie_vars["zombie_spawn_delay"];

			if ( timer > 0.08 )
			{
				level.zombie_vars["zombie_spawn_delay"] = timer * 0.95;
				continue;
			}

			if ( timer < 0.08 )
				level.zombie_vars["zombie_spawn_delay"] = 0.08;
		}
	}

	level.speed_change_max = 0;
	level.speed_change_num = 0;
}

init_zombie_run_cycle_override()
{
    if ( isdefined( level.speed_change_round ) && false)
    {
        if ( level.round_number >= level.speed_change_round )
        {
            speed_percent = 0.2 + ( level.round_number - level.speed_change_round ) * 0.2;
            speed_percent = min( speed_percent, 1 );
            change_round_max = int( level.speed_change_max * speed_percent );
            change_left = change_round_max - level.speed_change_num;

            if ( change_left == 0 )
            {
                self set_zombie_run_cycle();
                return;
            }

            change_speed = randomint( 100 );

            if ( change_speed > 80 )
            {
                self change_zombie_run_cycle();
                return;
            }

            zombie_count = get_current_zombie_count();
            zombie_left = level.zombie_ai_limit - zombie_count;

            if ( zombie_left == change_left )
            {
                self change_zombie_run_cycle();
                return;
            }
        }
    }

    self set_zombie_run_cycle();
}

change_zombie_run_cycle()
{
	level.speed_change_num++;

	self set_zombie_run_cycle( "walk" );

	self thread speed_change_watcher();
}

speed_change_watcher()
{
	self waittill( "death" );

	if ( level.speed_change_num > 0 )
		level.speed_change_num--;
}

set_zombie_run_cycle( new_move_speed )
{
	self.zombie_move_speed_original = self.zombie_move_speed;

	if ( isdefined( new_move_speed ) )
		self.zombie_move_speed = new_move_speed;
	else
		self set_run_speed();

	self maps\mp\animscripts\zm_run::needsupdate();
	self.deathanim = self maps\mp\animscripts\zm_utility::append_missing_legs_suffix( "zm_death" );
}

set_run_speed()
{
	rand = randomintrange( level.zombie_move_speed, level.zombie_move_speed + 35 );

	if ( rand <= 35 )
		self.zombie_move_speed = "walk";
	else if ( rand <= 70 )
		self.zombie_move_speed = "run";
	else
		self.zombie_move_speed = "sprint";
}

zone_init_override( zone_name )
{
	if ( isdefined( level.zones[zone_name] ) )
		return;
/#
	println( "ZM >> zone_init (1) = " + zone_name );
#/
	level.zones[zone_name] = spawnstruct();
	zone = level.zones[zone_name];
	zone.is_enabled = 0;
	zone.is_occupied = 0;
	zone.is_active = 0;
	zone.adjacent_zones = [];
	zone.is_spawning_allowed = 0;
	zone.volumes = [];
	volumes = getentarray( zone_name, "targetname" );
/#
	println( "ZM >> zone_init (2) = " + volumes.size );
#/
	for ( i = 0; i < volumes.size; i++ )
	{
		if ( volumes[i].classname == "info_volume" )
			zone.volumes[zone.volumes.size] = volumes[i];
	}

	assert( isdefined( zone.volumes[0] ), "zone_init: No volumes found for zone: " + zone_name );

	if ( isdefined( zone.volumes[0].target ) )
	{
		spots = getstructarray( zone.volumes[0].target, "targetname" );
		zone.spawn_locations = [];
		zone.dog_locations = [];
		zone.screecher_locations = [];
		zone.avogadro_locations = [];
		zone.inert_locations = [];
		zone.quad_locations = [];
		zone.leaper_locations = [];
		zone.brutus_locations = [];
		zone.mechz_locations = [];
		zone.astro_locations = [];
		zone.napalm_locations = [];
		zone.zbarriers = [];
		zone.magic_boxes = [];
		barricades = getstructarray( "exterior_goal", "targetname" );
		box_locs = getstructarray( "treasure_chest_use", "targetname" );

		for ( i = 0; i < spots.size; i++ )
		{
			spots[i].zone_name = zone_name;

			if ( !( isdefined( spots[i].is_blocked ) && spots[i].is_blocked ) )
				spots[i].is_enabled = 1;
			else
				spots[i].is_enabled = 0;

			tokens = strtok( spots[i].script_noteworthy, " " );

			foreach ( token in tokens )
			{
				if ( token == "dog_location" )
				{
					zone.dog_locations[zone.dog_locations.size] = spots[i];
					continue;
				}

				if ( token == "avogadro_location" )
				{
					zone.avogadro_locations[zone.avogadro_locations.size] = spots[i];
					continue;
				}

				if ( token == "brutus_location" )
				{
					zone.brutus_locations[zone.brutus_locations.size] = spots[i];
					continue;
				}

				if ( token == "mechz_location" )
				{
					zone.mechz_locations[zone.mechz_locations.size] = spots[i];
					continue;
				}

				zone.spawn_locations[zone.spawn_locations.size] = spots[i];
			}

			if ( isdefined( spots[i].script_string ) )
			{
				barricade_id = spots[i].script_string;

				for ( k = 0; k < barricades.size; k++ )
				{
					if ( isdefined( barricades[k].script_string ) && barricades[k].script_string == barricade_id )
					{
						nodes = getnodearray( barricades[k].target, "targetname" );

						for ( j = 0; j < nodes.size; j++ )
						{
							if ( isdefined( nodes[j].type ) && nodes[j].type == "Begin" )
								spots[i].target = nodes[j].targetname;
						}
					}
				}
			}
		}

		for ( i = 0; i < barricades.size; i++ )
		{
			targets = getentarray( barricades[i].target, "targetname" );

			for ( j = 0; j < targets.size; j++ )
			{
				if ( targets[j] iszbarrier() && isdefined( targets[j].script_string ) && targets[j].script_string == zone_name )
					zone.zbarriers[zone.zbarriers.size] = targets[j];
			}
		}

		for ( i = 0; i < box_locs.size; i++ )
		{
			chest_ent = getent( box_locs[i].script_noteworthy + "_zbarrier", "script_noteworthy" );

			if ( chest_ent entity_in_zone( zone_name, 1 ) )
				zone.magic_boxes[zone.magic_boxes.size] = box_locs[i];
		}
	}
}

create_spawner_list_override( zkeys )
{
	/*

	*/
}

include_weapon_override( weapon_name, in_box, collector, weighting_func )
{
/#
	println( "ZM >> include_weapon = " + weapon_name );
#/
	if ( !isdefined( in_box ) )
		in_box = 1;

	if ( !isdefined( collector ) )
		collector = 0;

	maps\mp\zombies\_zm_weapons::include_zombie_weapon( weapon_name, in_box, collector, weighting_func );
}

get_next_point( vector, angles, num )
{
	angles_to_forward = anglestoforward( angles );
	x = vector[ 0 ] + num * angles_to_forward[ 0 ];
	y = vector[ 1 ] + num * angles_to_forward[ 1 ];
	final_vector = ( x, y, vector[ 2 ] );
	//logprint( "final_vector: " + final_vector + " vector: " + vector + " angles: " + angles + " angles_to_forward: " + angles_to_forward + " num: " + num + "\n" );
	return final_vector;
}

create_polygon( start_vector, num_sides, radius )
{
	const pi = 3.14;
	polygon = [];
	radians = sin(pi / num_sides ) * (180 / pi);
	length_of_side = 2 * radius * radians;
	angle_of_side = 360 / num_sides;
	polygon[ 0 ] = get_next_point( start_vector, ( 0, -90, 0 ), radius );
	for ( i = 1; i < num_sides; i++ )
	{
		polygon[ i ] = get_next_point( polygon[ i - 1 ], ( 0, angle_of_side * i, 0 ), length_of_side );
	}
	return polygon;
}

create_spiral( start_vector, radius )
{
	points = [];
	for (i = 0; i < 360; i += 4)
	{
		radius -= 10;
		x = cos(i) * radius;
		y = sin(i) * radius;
		point = (start_vector[0] + x, start_vector[1] + y, start_vector[2]);
		points[ points.size ] = point;
	}
	return points;
}

create_sphere( start_vector, radius )
{
	points = [];
	for (i = 0; i < 180; i += 36)
	{
		current_radius = abs(sin(i) * radius);
	//current_radius = radius;
		for (o = 0; o < 360; o += 36)
		{
			x = cos(o) * current_radius;
			y = sin(o) * current_radius;
			point = (x, y, (i / 180) * radius * 2) + start_vector;
			points[ points.size ] = point;
		}
	}
	return points;
}

init_bus_override()
{

}

delete_buildable_parts()
{
	ents = getEntArray();
	foreach ( ent in ents )
	{
		if ( isDefined( ent ) && isDefined( ent.script_gameobjectname ) && ent.script_gameobjectname == "zclassic" )
		{
			ent delete();
		}
	}
}

wait_network_frame_override()
{
	wait 0.1;
}

banking_and_weapon_locker_main_override()
{
}

sq_init_override()
{
}

start_transit_sidequest_override()
{
}

initializepower_override()
{
	registerclientfield( "toplayer", "power_rumble", 1, 1, "int" );
	if ( !isdefined( level.vsmgr_prio_visionset_zm_transit_power_high_low ) )
		level.vsmgr_prio_visionset_zm_transit_power_high_low = 20;
	maps\mp\_visionset_mgr::vsmgr_register_info( "visionset", "zm_power_high_low", 1, level.vsmgr_prio_visionset_zm_transit_power_high_low, 7, 1, ::vsmgr_lerp_power_up_down, 0 );
}

zombie_ignore_equipment( zombie )
{
	return true;
}

menu_init_override()
{
	precachestring( &"open_ingame_menu" );
	game["menu_team"] = "team_marinesopfor";
	game["menu_changeclass_allies"] = "changeclass";
	game["menu_initteam_allies"] = "initteam_marines";
	game["menu_changeclass_axis"] = "changeclass";
	game["menu_initteam_axis"] = "initteam_opfor";
	game["menu_class"] = "class";
	game["menu_changeclass"] = "changeclass";
	game["menu_changeclass_offline"] = "changeclass";
	game["menu_wager_side_bet"] = "sidebet";
	game["menu_wager_side_bet_player"] = "sidebet_player";
	game["menu_changeclass_wager"] = "changeclass_wager";
	game["menu_changeclass_custom"] = "changeclass_custom";
	game["menu_changeclass_barebones"] = "changeclass_barebones";
	game["menu_controls"] = "ingame_controls";
	game["menu_options"] = "ingame_options";
	game["menu_leavegame"] = "popup_leavegame";
	game["menu_restartgamepopup"] = "restartgamepopup";
	game[ "menu_edit_turret" ] = "edit_turret";
	precacheMenu( game[ "menu_edit_turret" ] );
	precachemenu( game["menu_controls"] );
	precachemenu( game["menu_options"] );
	precachemenu( game["menu_leavegame"] );
	precachemenu( game["menu_restartgamepopup"] );
	precachemenu( "scoreboard" );
	precachemenu( game["menu_team"] );
	precachemenu( game["menu_changeclass_allies"] );
	precachemenu( game["menu_initteam_allies"] );
	precachemenu( game["menu_changeclass_axis"] );
	precachemenu( game["menu_class"] );
	precachemenu( game["menu_changeclass"] );
	precachemenu( game["menu_initteam_axis"] );
	precachemenu( game["menu_changeclass_offline"] );
	precachemenu( game["menu_changeclass_wager"] );
	precachemenu( game["menu_changeclass_custom"] );
	precachemenu( game["menu_changeclass_barebones"] );
	precachemenu( game["menu_wager_side_bet"] );
	precachemenu( game["menu_wager_side_bet_player"] );
	precachestring( &"MP_HOST_ENDED_GAME" );
	precachestring( &"MP_HOST_ENDGAME_RESPONSE" );
	level thread maps\mp\gametypes_zm\_zm_gametype::menu_onplayerconnect();
}

edit_turret_pick_up_cb( args )
{
	cmd_name = args[ 0 ];
}

register_edit_turret_response_callbacks()
{
	register_edit_turret_response_callback( "pick_up", ::edit_turret_pick_up_cb );
	register_edit_turret_response_callback( "sell", ::edit_turret_sell_cb );
	register_edit_turret_response_callback( "transfer", ::edit_turret_transfer_cb );
	register_edit_turret_response_callback( "change_targeting", ::edit_turret_change_targeting_cb );
	register_edit_turret_response_callback( "increase_damage", ::edit_turret_increase_damage_cb );
	register_edit_turret_response_callback( "increase_firerate", ::edit_turret_increase_firerate_cb );
	register_edit_turret_response_callback( "increase_turn_speed", ::edit_turret_increase_turn_speed_cb );
	register_edit_turret_response_callback( "increase_arclimits", ::edit_turret_increase_arclimits_cb );
	register_edit_turret_response_callback( "increase_shotcount", ::edit_turret_increase_shotcount_cb );
	register_edit_turret_response_callback( "increase_accuracy", ::edit_turret_increase_accuracy_cb );
	register_edit_turret_response_callback( "increase_range", ::edit_turret_increase_range_cb );
	register_edit_turret_response_callback( "increase_reload_speed", ::edit_turret_increase_reload_speed_cb );
	register_edit_turret_response_callback( "increase_clip_size", ::edit_turret_increase_clip_size_cb );
	register_edit_turret_response_callback( "reduce_spread", ::edit_turret_reduce_spread_cb );
}

register_edit_turret_response_callback( response, callback )
{
	if ( !isDefined( level.ztd_edit_turret_callbacks ) )
	{
		level.ztd_edit_turret_callbacks = [];
	}

	if ( isDefined( level.ztd_edit_turret_callbacks[ response ] ) )
	{
		print( "Duplicate edit_turret callback <" + response + "> added; replacing the current one" );
	}

	level.ztd_edit_turret_callbacks[ response ] = callback;
}

execute_edit_turret_response_callback( response )
{
	args = strTok( response, " " );

	if ( !isDefined( level.ztd_edit_turret_callbacks[ args[ 0 ] ] ) )
	{
		print( "Unknown edit_turret response " + args[ 0 ] );
		return;
	}

	self [[ level.ztd_edit_turret_callbacks[ args[ 0 ] ] ]]( args );
}

register_buy_turret_response_item()
{
	register_buy_turret_response_item( "ray_gun_zm", 1000 );
}

register_buy_turret_response_item( item_name, cost )
{
	if ( !isDefined( level.ztd_buy_turret_items ) )
	{
		level.ztd_buy_turret_items = [];
	}

	s = spawnStruct();

	s.cost = cost;

	level.ztd_buy_turret_items[ item_name ] = s;
}

execute_buy_turret_response_callback( response )
{
	args = strTok( response, " " );

	if ( !isDefined( level.ztd_buy_turret_items[ args[ 0 ] ] ) )
	{
		print( "Unknown buy_turret response " + args[ 0 ] );
		return;
	}
	
	if ( self.score < level.ztd_buy_turret_items[ args[ 0 ] ].cost )
	{
		print( "Not enough points" );
		return;
	}

	equipment_manager = scripts\zm\ztd_equipment_manager::create_new_managed_equipment_for_player( self, "equip_turret_zm", "inventory" );

	self.ztd_current_inventory_equipment_id = equip_manager.id;

	self.custom_turret_weapon = args[ 0 ];

	self maps\mp\zombies\_zm_equipment::equipment_buy( "equip_turret_zm", equipment_manager );
}

menu_onmenuresponse()
{
	const max_response_len = 128;
	self endon( "disconnect" );

	for (;;)
	{
		self waittill( "menuresponse", menu, response );

		if ( response == "" )
		{
			continue;
		}

		if ( response.size > max_response_len )
		{
			continue;
		}

		switch ( menu )
		{
			case "edit_turret":
				self execute_edit_turret_response_callback( response );
				break;
			case "buy_turret":
				self execute_buy_turret_response_callback( response );
				break;
			default:
				break;
		}
	}
}