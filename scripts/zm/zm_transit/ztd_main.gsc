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
	replaceFunc( maps\mp\zombies\_zm_utility::has_deployed_equipment, ::has_deployed_equipment_override );	
	replaceFunc( maps\mp\zombies\_zm_spawner::zombie_death_points, ::zombie_death_points_override );
	replaceFunc( maps\mp\zombies\_zm_spawner::zombie_pathing, ::zombie_pathing_override );
	replaceFunc( maps\mp\zombies\_zm_ai_basic::find_flesh, ::find_flesh_override );
	level thread on_player_connect();
	level thread command_thread();
}

init()
{
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
								level.custom_turret_weapon = level.ztd_turret_types[ randomInt( level.ztd_turret_types.size ) ];
							}
							else 
							{
								level.custom_turret_weapon = commands[ 2 ];
							}
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
			case "dumpturrets":
				if ( isDefined( player.owned_turrets ) )
				{
					for ( i = 0; i < player.owned_turrets.size; i++ )
					{
						dumpTurret( player.owned_turrets[ i ].turret, player.owned_turrets[ i ].turret.currentweapon + "_user_dumped_" + player.name + "_" + i );
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

		self thread zombie_pathing();

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

zombie_pathing()
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