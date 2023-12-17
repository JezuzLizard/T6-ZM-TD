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
	{
		include_equipment( "equip_turret_zm" );
	}
	precachemodel( "p6_anim_zm_buildable_turret" );
	precacheturret( "zombie_bullet_crouch_zm" );
	level.turret_name = "equip_turret_zm";
	maps\mp\zombies\_zm_equipment::register_equipment( "equip_turret_zm", &"ZOMBIE_EQUIP_TURRET_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_TURRET_HOWTO", "turret_zm_icon", "turret", undefined, ::transferturret, ::dropturret, ::pickupturret, ::placeturret );
	maps\mp\zombies\_zm_equipment::add_placeable_equipment( "equip_turret_zm", "p6_anim_zm_buildable_turret" );
	level thread onplayerconnect();
	maps\mp\gametypes_zm\_weaponobjects::createretrievablehint( "equip_turret", &"ZOMBIE_EQUIP_TURRET_PICKUP_HINT_STRING" );

	level.ztd_turret_ids = [];
}

onplayerconnect()
{
	for (;;)
	{
		level waittill( "connecting", player );
		player thread on_player_disconnect();
		level.ztd_turret_ids[ player getGUID() + "" ] = 0;
		player thread setupwatchers();
		player thread watchturretuse();
	}
}

on_player_disconnect()
{
	guid = self getGUID();
	self waittill( "disconnect" );
	level.ztd_turret_ids[ guid + "" ] = undefined;

	for ( i = 0; i < self.owned_turrets.size; i++ )
	{
		cleanup_buildable_turret( self.owned_turrets[ i ] );
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
			if ( self.owned_turrets.size >= getDvarIntDefault( "sv_max_turrets", 96 ) )
			{
				self cleanup_buildable_turret( self.owned_turrets[ 0 ] );
			}
			self thread startturretdeploy( weapon );
		}
	}
}

//TODO: fix removing old turrets
cleanup_buildable_turret( turret_to_delete )
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

cleanup_turret( turret_to_delete )
{
	turret_to_delete delete();
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
	if ( isDefined( item ) )
	{
		//item.damagetaken = self.damagetaken; //TODO: store each player's turret health
	}
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
	model setmodel(getweaponmodel(weapon));
	model linkto(self, "tag_aim");

	self thread delete_turret_weapon(model);
}

startturretdeploy( weapon )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_turret_zm_taken" );

	if ( !isdefined( level.turret_max_health ) )
		level.turret_max_health = 1000;

	if ( isdefined( weapon ) )
	{
		weapon hide();
		wait 0.1;

		if ( isdefined( weapon.power_on ) && weapon.power_on )
			weapon.turret notify( "stop_burst_fire_unmanned" );

		if ( !isdefined( weapon ) )
			return;

		if ( isDefined( self.custom_turret_weapon ) )
		{
			turret = spawnTurret( "misc_turret", weapon.origin, self.custom_turret_weapon );
			turret.currentweapon = self.custom_turret_weapon;
			dumpTurret( turret, self.custom_turret_weapon );
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
		if ( isDefined( self.custom_turret_weapon ) && self.custom_turret_weapon != "zombie_bullet_crouch_zm" )
		{
			turret add_turret_weapon(self.custom_turret_weapon);
		}
		turret.origin = weapon.origin;
		turret.angles = weapon.angles;
		turret linkto( weapon );
		turret makeunusable();
		turret.owner = self;
		turret setowner( turret.owner );
		if ( !isDefined( weapon.damagetaken ) )
		{
			weapon.damagetaken = 0;
			weapon.maxhealth = level.turret_max_health;
			weapon.health = 10000000;
			turret.health = 10000000;
		}
		turret.damagetaken = weapon.damagetaken;
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
		if ( isDefined( self.custom_turret_weapon ) )
		{
			dumpTurret( turret, self.custom_turret_weapon + "_modified" );
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

		turret thread turret_waittill_stop_burst_fire_unmanned();

		turret thread turret_waittill_death();

		turret thread turret_waittill_remote_start();

		weapon thread buildable_turret_waittill_damage();

		turret thread print_health();

		self.owned_turrets[ self.owned_turrets.size ] = weapon;

		//self.custom_turret_weapon = undefined;

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

turret_waittill_stop_burst_fire_unmanned()
{
	self waittill( "stop_burst_fire_unmanned" );
	print( "stop_burst_fire_unmanned notify triggered" );
}

turret_waittill_death()
{
	self waittill( "death" );
	print( "death notify triggered" );
}

turret_waittill_remote_start()
{
	self waittill( "remote_start" );
	print( "remote_start triggered" );
}

//self == buildable
buildable_turret_waittill_damage()
{
	while ( isDefined( self.turret ) )
	{
		self.turret waittill( "damage", amount, attacker, direction, point, mod, tagname, modelname, partname, weaponname, idflags );
		if ( isDefined( self.turret.owner ) )
		{
			//print( self.turret.owner.name + "'s turret took " + amount + " damage from " + attacker.classname + " with mod " + mod + "  health remaining: " + self.turret.health );
		}
		else if ( isDefined( self.turret.currentweapon ) && isDefined( attacker.classname ) )
		{
			//print( "turret of type " + self.turret.currentweapon + " took " + amount + " damage from " + attacker.classname + " with mod " + mod + "  health remaining: " + self.turret.health );
		}
		else
		{
			//print( "turret took " + amount + " damage health remaining: " + self.turret.health );
		}
		self rollback_turret_health( amount );
		if ( !isDefined( attacker ) )
		{
			continue;
		}
		if ( attacker.classname == "worldspawn" || attacker.classname == "misc_turret" )
		{
			continue;
		}
		if ( isPlayer( attacker ) )
		{
			continue;
		}
		self.damagetaken += amount;
		if ( self.damagetaken >= self.maxhealth )
		{
			cleanup_buildable_turret( self );
		}
	}
}

rollback_turret_health( amount )
{
	self.health += amount;
}

print_health()
{
	while ( isDefined( self ) )
	{
		//print( "turret health " + self.health );
		wait 1;
	}
}

startturretdeploy2( custom_origin )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_turret_zm_taken" );

	if ( isDefined( custom_origin ) )
	{
		spawn_origin = custom_origin;
	}
	else 
	{
		spawn_origin = self.origin;
	}

	if ( !isdefined( level.turret_max_health ) )
		level.turret_max_health = 1000;

	if ( isDefined( self.custom_turret_weapon ) )
	{
		turret = spawnTurret( "misc_turret", spawn_origin, self.custom_turret_weapon );
		turret.currentweapon = self.custom_turret_weapon;
		dumpTurret( turret, self.custom_turret_weapon );
	}
	else 
	{
		turret = spawnturret( "misc_turret", spawn_origin, "zombie_bullet_crouch_zm" );
		turret.currentweapon = "zombie_bullet_crouch_zm";
		dumpTurret( turret, "zombie_bullet_crouch_zm" );
	}
	turret.turrettype = "sentry";
	turret setturrettype( turret.turrettype );
	turret setmodel( "p6_anim_zm_buildable_turret" );
	if ( isDefined( self.custom_turret_weapon ) && self.custom_turret_weapon != "zombie_bullet_crouch_zm" )
	{
		turret add_turret_weapon(self.custom_turret_weapon);
	}
	turret.origin = spawn_origin;
	turret.angles = self.angles;
	//turret linkto( self );
	turret makeunusable();
	turret.owner = self;
	turret setowner( turret.owner );

	turret.health = 10000000;

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

	turret setTurretField( "initialYawmin", -90.0 );
	turret setTurretField( "initialYawmax", 90.0 );
	turret setTurretField( "forwardangledot", -1.0 );
	turret setTurretField( "suppresstime", 3000 );
	turret setTurretField( "stance", 1 );
	turret setTurretField( "accuracy", 0.38 );
	turret setTurretField( "aispread", 2.0 );
	turret setTurretField( "playerspread", 2.0 );
	turret setturretteam( self.team );
	if ( isDefined( self.custom_turret_weapon ) )
	{
		dumpTurret( turret, self.custom_turret_weapon + "_modified" );
	}
	else 
	{
		dumpTurret( turret, "zombie_bullet_crouch_zm_modified" );
	}
	turret.team = self.team;
	turret.damage_own_team = false;
	turret.turret_active = 1;

	turret.script_delay_min = 0.05;
	turret.script_delay_max = 0.1;
	turret.script_burst_min = 10;
	turret.script_burst_max = 20;

	turret.arclimits = turret getTurretArcLimits();

	turret thread maps\mp\zombies\_zm_mgturret::burst_fire_unmanned();

	turret thread turret_waittill_damage();

	self.owned_turrets[ self.owned_turrets.size ] = turret;

	turret.id = level.ztd_turret_ids[ self getGUID() + "" ];

	level.ztd_turret_ids++;
	//self.custom_turret_weapon = undefined;
}

//self == turret
turret_waittill_damage()
{
	while ( isDefined( self ) )
	{
		self waittill( "damage", amount, attacker, direction, point, mod, tagname, modelname, partname, weaponname, idflags );
		if ( isDefined( self.owner ) )
		{
			//print( self.owner.name + "'s turret took " + amount + " damage from " + attacker.classname + " with mod " + mod + "  health remaining: " + self.health );
		}
		else if ( isDefined( self.currentweapon ) && isDefined( attacker.classname ) )
		{
			//print( "turret of type " + self.currentweapon + " took " + amount + " damage from " + attacker.classname + " with mod " + mod + "  health remaining: " + self.health );
		}
		else
		{
			//print( "turret took " + amount + " damage health remaining: " + self.health );
		}
		self rollback_turret_health( amount );
		if ( !isDefined( attacker ) )
		{
			continue;
		}
		if ( attacker.classname == "worldspawn" || attacker.classname == "misc_turret" )
		{
			continue;
		}
		if ( isPlayer( attacker ) )
		{
			continue;
		}
		self.damagetaken += amount;
		if ( self.damagetaken >= self.maxhealth )
		{
			cleanup_turret( self );
		}
	}
}

startturretdeploy3( custom_origin )
{
	turret = spawn( "script_model", custom_origin );
	turret.currentweapon = "zombie_bullet_crouch_zm";
	turret setmodel( "p6_anim_zm_buildable_turret" );
	if ( isDefined( self.custom_turret_weapon ) && self.custom_turret_weapon != "zombie_bullet_crouch_zm" )
	{
		turret add_turret_weapon(self.custom_turret_weapon);
	}
	turret.angles = self.angles;
	turret.owner = self;
	turret setowner( turret.owner );
}