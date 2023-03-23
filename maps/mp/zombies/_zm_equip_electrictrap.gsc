// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\gametypes_zm\_weaponobjects;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm_traps;

init()
{
	if ( !maps\mp\zombies\_zm_equipment::is_equipment_included( "equip_electrictrap_zm" ) )
		return;

	level.electrictrap_name = "equip_electrictrap_zm";
	maps\mp\zombies\_zm_equipment::register_equipment( "equip_electrictrap_zm", &"ZOMBIE_EQUIP_ELECTRICTRAP_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_ELECTRICTRAP_HOWTO", "etrap_zm_icon", "electrictrap", undefined, ::transfertrap, ::droptrap, ::pickuptrap, ::placetrap );
	maps\mp\zombies\_zm_equipment::add_placeable_equipment( "equip_electrictrap_zm", "p6_anim_zm_buildable_etrap" );
	level thread onplayerconnect();
	maps\mp\gametypes_zm\_weaponobjects::createretrievablehint( "equip_electrictrap", &"ZOMBIE_EQUIP_ELECTRICTRAP_PICKUP_HINT_STRING" );
	level._effect["etrap_on"] = loadfx( "maps/zombie/fx_zmb_tranzit_electric_trap_on" );
	thread wait_init_damage();
}

wait_init_damage()
{
	while ( !isdefined( level.zombie_vars ) || !isdefined( level.zombie_vars["zombie_health_start"] ) )
		wait 1;

	level.etrap_damage = maps\mp\zombies\_zm::ai_zombie_health( 50 );
}

onplayerconnect()
{
	for (;;)
	{
		level waittill( "connecting", player );

		player thread onplayerspawned();
	}
}

onplayerspawned()
{
	self endon( "disconnect" );
	self thread setupwatchers();

	for (;;)
	{
		self waittill( "spawned_player" );

		self thread watchelectrictrapuse();
	}
}

setupwatchers()
{
	self waittill( "weapon_watchers_created" );

	watcher = maps\mp\gametypes_zm\_weaponobjects::getweaponobjectwatcher( "equip_electrictrap" );
	watcher.onspawnretrievetriggers = maps\mp\zombies\_zm_equipment::equipment_onspawnretrievableweaponobject;
}

watchelectrictrapuse()
{
	self notify( "watchElectricTrapUse" );
	self endon( "watchElectricTrapUse" );
	self endon( "death" );
	self endon( "disconnect" );

	self.owned_electric_traps = [];

	for (;;)
	{
		self waittill( "equipment_placed", weapon, weapname );

		if ( weapname == level.electrictrap_name )
		{
			if ( self.owned_electric_traps.size >= getDvarIntDefault( "sv_max_electric_traps", 96 ) )
			{
				self cleanupoldtrap( self.owned_electric_traps[ 0 ] );
			}
			self thread startelectrictrapdeploy( weapon );
		}
	}
}

cleanupoldtrap( trap_to_delete )
{
	if ( isdefined( trap_to_delete ) )
	{
		if ( isdefined( trap_to_delete.stub ) )
		{
			thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( trap_to_delete.stub );
			trap_to_delete.stub = undefined;
		}

		trap_to_delete delete();
	}
}

watchforcleanup( weapon )
{
	self notify( "etrap_cleanup" );
	self endon( "etrap_cleanup" );
	self waittill_any( "death_or_disconnect", "equip_electrictrap_zm_taken", "equip_electrictrap_zm_pickup" );
	cleanupoldtrap( weapon );
}

placetrap( origin, angles )
{
	item = self maps\mp\zombies\_zm_equipment::placed_equipment_think( "p6_anim_zm_buildable_etrap", "equip_electrictrap_zm", origin, angles );

	if ( isdefined( item ) )
	{
		item.owner = self;
	}

	return item;
}

droptrap()
{
	item = self maps\mp\zombies\_zm_equipment::dropped_equipment_think( "p6_anim_zm_buildable_etrap", "equip_electrictrap_zm", self.origin, self.angles );

	if ( isdefined( item ) )
		item.electrictrap_health = self.electrictrap_health;

	self.electrictrap_health = undefined;
	return item;
}

pickuptrap( item )
{
	item.owner = self;
	self.electrictrap_health = item.electrictrap_health;
	item.electrictrap_health = undefined;
}

transfertrap( fromplayer, toplayer )
{
}

startelectrictrapdeploy( weapon )
{
	self endon( "disconnect" );
	self endon( "equip_electrictrap_zm_taken" );
	self thread watchforcleanup( weapon );
	electricradius = 45;

	if ( isdefined( weapon ) )
	{
		weapon.power_on = 1;

		self thread electrictrapthink( weapon, electricradius );

		self thread maps\mp\zombies\_zm_buildables::delete_on_disconnect( weapon );

		weapon.owner = self;

		weapon thread trapfx();

		if ( !isdefined( weapon.electrap_sound_ent ) )
			electrap_sound_ent = spawn( "script_origin", self.origin );

		electrap_sound_ent playsound( "wpn_zmb_electrap_start" );
		electrap_sound_ent playloopsound( "wpn_zmb_electrap_loop", 2 );

		weapon.electrap_sound_ent = electrap_sound_ent;

		electrap_sound_ent thread destroy_sound_on_trap_death( self, weapon );

		self.owned_electric_traps[ self.owned_electric_traps.size ] = weapon;

		weapon waittill( "death" );

		self notify( "etrap_cleanup" );
	}
}

destroy_sound_on_trap_death( player, weapon )
{
	while ( isDefined( player ) && isDefined( weapon ) )
	{
		wait 0.05;
	}

	self playsound( "wpn_zmb_electrap_stop" );
	self delete();
}

trapfx()
{
	while ( isdefined( self ) && ( isdefined( self.power_on ) && self.power_on ) )
	{
		playfxontag( level._effect["etrap_on"], self, "tag_origin" );
		wait 0.3;
	}
}

zombie_ignore_electrictrap_for_time( time )
{
	self.ignore_electric_trap = true;
	wait time;
	self.ignore_electric_trap = false;
}

zap_zombie( zombie )
{
	if ( isdefined( zombie.ignore_electric_trap ) && zombie.ignore_electric_trap || is_true( zombie.killed_by_electrictrap ))
		return;

	electrictrap_damage = self calculate_electrictrap_damage( self.owner, zombie );

	if ( zombie.health > electrictrap_damage )
	{
		zombie thread maps\mp\zombies\_zm_traps::electroctute_death_fx();
		zombie dodamage( electrictrap_damage, self.origin, self.owner, self.owner, "none" );
		zombie thread zombie_ignore_electrictrap_for_time( 0.5 );
		return;
	}

	self playsound( "wpn_zmb_electrap_zap" );

	zombie thread play_elec_vocals();
	zombie thread maps\mp\zombies\_zm_traps::electroctute_death_fx();
	zombie.is_on_fire = 0;
	zombie notify( "stop_flame_damage" );

	zombie.killed_by_electrictrap = true;
	zombie thread electrictrapkill( self );
}

calculate_electrictrap_damage( player, zombie )
{
	damage = int( ( zombie.maxhealth * 0.10 ) + 1000 );
	return damage;
}

electrictrapthink( weapon, electricradius )
{
	weapon endon( "death" );
	radiussquared = electricradius * electricradius;

	while ( isdefined( weapon ) )
	{
		zombies = getaiarray( level.zombie_team );

		foreach ( zombie in zombies )
		{
			if ( !isdefined( zombie ) || !isalive( zombie ) )
				continue;

			if ( isdefined( zombie.ignore_electric_trap ) && zombie.ignore_electric_trap )
				continue;

			if ( distancesquared( weapon.origin, zombie.origin ) < radiussquared )
			{
				weapon zap_zombie( zombie );
			}
		}

		wait 0.05;
	}
}

electrictrapkill( weapon )
{
	self endon( "death" );
	wait( randomfloatrange( 0.1, 0.4 ) );
	self dodamage( self.health + 666, self.origin, weapon.owner, weapon.owner, "none" );
}

debugelectrictrap( radius )
{
}
