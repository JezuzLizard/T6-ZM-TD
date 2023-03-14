// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\gametypes_zm\_weaponobjects;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_mgturret;
#include maps\mp\zombies\_zm_buildables;

init()
{
	if ( !maps\mp\zombies\_zm_equipment::is_equipment_included( "equip_turret_zm" ) )
		return;

	precachemodel( "p6_anim_zm_buildable_turret" );
	precacheturret( "zombie_bullet_crouch_zm" );
	level.turret_name = "equip_turret_zm";
	maps\mp\zombies\_zm_equipment::register_equipment( "equip_turret_zm", &"ZOMBIE_EQUIP_TURRET_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_TURRET_HOWTO", "turret_zm_icon", "turret", undefined, ::transferturret, ::dropturret, ::pickupturret, ::placeturret );
	maps\mp\zombies\_zm_equipment::add_placeable_equipment( "equip_turret_zm", "p6_anim_zm_buildable_turret" );
	level thread onplayerconnect();
	maps\mp\gametypes_zm\_weaponobjects::createretrievablehint( "equip_turret", &"ZOMBIE_EQUIP_TURRET_PICKUP_HINT_STRING" );
}

onplayerconnect()
{
	for (;;)
	{
		level waittill( "connecting", player );
		player thread delete_turrets_on_disconnect();
		player thread setupwatchers();
		player thread watchturretuse();
	}
}

setupwatchers()
{
	self waittill( "weapon_watchers_created" );

	watcher = maps\mp\gametypes_zm\_weaponobjects::getweaponobjectwatcher( "equip_turret" );
	watcher.onspawnretrievetriggers = maps\mp\zombies\_zm_equipment::equipment_onspawnretrievableweaponobject;
}

watchturretuse()
{
	self endon( "death" );
	self endon( "disconnect" );

	self.owned_turrets = [];

	for (;;)
	{
		self waittill( "equipment_placed", weapon, weapname );

		if ( weapname == level.turret_name )
		{
			if ( self.owned_turrets.size >= getDvarIntDefault( "sv_max_turrets", 32 ) )
			{
				self cleanupturret( self.owned_turrets[ 0 ] );
			}
			self thread startturretdeploy( weapon );
		}
	}
}

cleanupturret( turret_to_delete )
{
	if ( isdefined( turret_to_delete.stub ) )
	{
		thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( turret_to_delete.stub );
		turret_to_delete.stub = undefined;
	}

	if ( isdefined( turret_to_delete.turret ) )
	{
		if ( isdefined( turret_to_delete.turret.sound_ent ) )
			turret_to_delete.turret.sound_ent delete();

		turret_to_delete.turret notify( "stop_burst_fire_unmanned" );
		turret_to_delete.turret delete();
	}

	if ( isdefined( turret_to_delete.sound_ent ) )
	{
		turret_to_delete.sound_ent delete();
		turret_to_delete.sound_ent = undefined;
	}

	turret_to_delete delete();
}

delete_turrets_on_disconnect()
{
	self waittill( "disconnect" );
	for ( i = 0; i < self.owned_turrets.size; i++ )
	{
		cleanupturret( self.owned_turrets[ i ] );
	}
}

placeturret( origin, angles )
{
	item = self maps\mp\zombies\_zm_equipment::placed_equipment_think( "p6_anim_zm_buildable_turret", "equip_turret_zm", origin, angles );

	if ( isdefined( item ) )
		item.owner = self;

	return item;
}

dropturret()
{
	item = self maps\mp\zombies\_zm_equipment::dropped_equipment_think( "p6_anim_zm_buildable_turret", "equip_turret_zm", self.origin, self.angles );

	return item;
}

pickupturret( item )
{
	item.owner = self;
}

transferturret( fromplayer, toplayer )
{

}

delete_turret_weapon(model)
{
	while (isdefined(self))
	{
		wait 0.05;
	}

	model delete();
}

add_turret_weapon(weapon)
{
	self hidepart("tag_aim");
	self hidepart("tag_part_02");

	model = spawn("script_model", self.origin + (-1, 0, 48));
	model setmodel(getweaponmodel(level.custom_turret_weapon));
	model linkto(self, "tag_aim");

	self thread delete_turret_weapon(model);
}

startturretdeploy( weapon )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_turret_zm_taken" );

	if ( !isdefined( level.turret_max_health ) )
		level.turret_max_health = 60;

	level.ignore_equipment = ::zombie_ignore_equipment;

	if ( isdefined( weapon ) )
	{
		weapon hide();
		wait 0.1;

		if ( isdefined( weapon.power_on ) && weapon.power_on )
			weapon.turret notify( "stop_burst_fire_unmanned" );

		if ( !isdefined( weapon ) )
			return;

		if ( isDefined( level.custom_turret_weapon ) )
		{
			turret = spawnTurret( "misc_turret", weapon.origin, level.custom_turret_weapon );
			turret.currentweapon = level.custom_turret_weapon;
			dumpTurret( turret, level.custom_turret_weapon );
		}
		else 
		{
			turret = spawnturret( "misc_turret", weapon.origin, "zombie_bullet_crouch_zm" );
			turret.currentweapon = "zombie_bullet_crouch_zm";
			dumpTurret( turret, "zombie_bullet_crouch_zm" );
		}
		turret.turrettype = "sentry";
		turret setturrettype( turret.turrettype );
		turret setmodel( "p6_anim_zm_buildable_turret" );
		//turret attach
		//turret setModel( "t6_wpn_zmb_raygun_world" );
		turret add_turret_weapon(level.custom_turret_weapon);
		turret.origin = weapon.origin;
		turret.angles = weapon.angles;
		turret linkto( weapon );
		turret makeunusable();
		turret.owner = self;
		turret setowner( turret.owner );
		turret maketurretunusable();
		//turret MakeTurretUsable();
		turret setmode( "auto_nonai" );
		turret setdefaultdroppitch( 45.0 );
		turret setconvergencetime( 0.3 );
		turret setTopArc(180);
		turret setRightArc(180);
		turret setBottomArc(180);
		turret setLeftArc(180);
		turret setAiSpread(2);
		turret setPlayerSpread(2);
		/*
		turret setTurretField( "inuse", true );
		turret setTurretField( "flags", 4099 );
		turret setTurretField( "manualtarget.number", 69 );
		turret setTurretField( "targetpos", ( 0, 0, 0 ) );
		turret setTurretField( "arcmin[0]", 1.0 );
		turret setTurretField( "arcmin[1]", 1.0 );
		turret setTurretField( "detachSentient.number", 69 );
		turret setTurretField( "eteam", 1 );
		turret setTurretField( "firesnd", 69 );
		turret setTurretField( "turretrotatestate", 0 );
		*/
		turret setTurretField( "initialYawmin", -90.0 );
		turret setTurretField( "initialYawmax", 90.0 );
		turret setTurretField( "forwardangledot", -1.0 );
		//turret setTurretField( "droppitch", -90.0 );
		turret setTurretField( "suppresstime", 3000 );
		turret setTurretField( "stance", 1 );
		turret setTurretField( "accuracy", 0.38 );
		turret setTurretField( "aispread", 2.0 );
		turret setTurretField( "playerspread", 2.0 );
		turret setturretteam( self.team );
		if ( isDefined( level.custom_turret_weapon ) )
		{
			dumpTurret( turret, level.custom_turret_weapon + "_modified" );
		}
		else 
		{
			dumpTurret( turret, "zombie_bullet_crouch_zm_modified" );
		}
		turret.team = self.team;
		turret.damage_own_team = false;
		turret.turret_active = 1;
		weapon.turret = turret;

		turret.script_delay_min = 0.05;
		turret.script_delay_max = 0.1;
		turret.script_burst_min = 10;
		turret.script_burst_max = 20;

		turret.arclimits = turret getTurretArcLimits();

		turret thread maps\mp\zombies\_zm_mgturret::burst_fire_unmanned();

		self.owned_turrets[ self.owned_turrets.size ] = weapon;

		while ( isdefined( weapon ) )
		{
			wait 0.1;
		}

		if ( isdefined( turret ) )
		{
			turret notify( "stop_burst_fire_unmanned" );
			turret notify( "turret_deactivated" );
			turret delete();
		}
	}
}

zombie_ignore_equipment( zombie )
{
	return true;
}