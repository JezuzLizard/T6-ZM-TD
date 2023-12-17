const char *szWeapTypeNames[9] =
{
  "bullet",
  "grenade",
  "projectile",
  "binoculars",
  "gas",
  "bomb",
  "mine",
  "melee",
  "riotshield"
}; // idb
const char *szWeapClassNames[14] =
{
  "rifle",
  "mg",
  "smg",
  "spread",
  "pistol",
  "grenade",
  "rocketlauncher",
  "turret",
  "non-player",
  "gas",
  "item",
  "melee",
  "Killstreak Alt Stored Weapon",
  "pistol spread"
}; // idb
const char *szWeapInventoryTypeNames[6] = { 
"primary", 
"offhand", 
"item", 
"altmode", 
"melee", 
"dwlefthand" }; // idb
const char *szWeapFireTypeNames[10] =
{
  "Full Auto",
  "Single Shot",
  "2-Round Burst",
  "3-Round Burst",
  "4-Round Burst",
  "5-Round Burst",
  "Stacked Fire", //Shoots the the amount defined in the stackFire field from the clip at 0 firetime
  "Minigun",
  "Charge Shot",
  "Jetgun"
}; // idb
const char *szWeapClipTypeNames[6] = { 
"bottom", 
"top", 
"left", 
"dp28", 
"ptrs", 
"lmg" }; // idb
const char *penetrateTypeNames[4] = { 
"none", 
"small", 
"medium", 
"large" }; // idb
const char *impactTypeNames_0[16] =
{
  "none",
  "bullet_small",
  "bullet_large",
  "bullet_ap",
  "bullet_xtreme",
  "shotgun",
  "grenade_bounce",
  "grenade_explode",
  "rifle_grenade",
  "rocket_explode",
  "rocket_explode_xtreme",
  "projectile_dud",
  "mortar_shell",
  "tank_shell",
  "bolt",
  "blade"
}; // idb
const char *szProjectileExplosionNames[11] =
{
  "grenade", //enables screenshake
  "rocket", //enables screenshake
  "flashbang", //unknown
  "none", //no engine explosion
  "dud", //removes explosion fx and screenshake
  "smoke", //unknown
  "heavy explosive", //bigger screenshake
  "fire", //unknown
  "napalmblob", //unknown
  "bolt", //no explosion on impact
  "shrapnel span" //unknown
}; // idb
const char *szWeapOverlayReticleNames[2] = { 
"none", 
"crosshair" }; // idb
const char *szWeapStanceNames[3] = { 
"stand", 
"duck", 
"prone" }; // idb
const char *offhandClassNames[6] =
{
  "None",
  "Frag Grenade",
  "Smoke Grenade",
  "Flash Grenade",
  "Gear",
  "Supply Drop Marker"
}; // idb
const char *offhandSlotNames[5] = { 
"None", 
"Lethal grenade", 
"Tactical grenade", 
"Equipment", 
"Specific use" }; // idb
const char *activeReticleNames[4] = { 
"None", 
"Pip-On-A-Stick", 
"Bouncing Diamond", 
"Missile Lock" }; // idb
const char *guidedMissileNames[9] =
{
  "None",
  "Sidewinder",
  "Hellfire",
  "Javelin",
  "Ballistic",
  "WireGuided",
  "TVGuided",
  "Drone",
  "HeatSeeking"
}; // idb
const char *stickinessNames[6] =
{
  "Don't stick",
  "Stick to all",
  "Stick to all, except ai and clients",
  "Stick to ground",
  "Stick to ground, maintain yaw",
  "Stick to flesh"
}; // idb
const char *rotateTypeNames[3] =
{
  "Rotate both axis, grenade style",
  "Rotate one axis, blade style",
  "Rotate like a cylinder"
}; // idb
const char *overlayInterfaceNames[3] = { 
"None", 
"Javelin", 
"Turret Scope" }; // idb
const char *ammoCounterClipNames[7] =
{
  "None",
  "Magazine",
  "ShortMagazine",
  "Shotgun",
  "Rocket",
  "Beltfed",
  "AltWeapon"
}; // idb
const char *weapIconRatioNames[3] = { 
"1:1", 
"2:1", 
"4:1" }; // idb
const char *barrelTypeNames[6] =
{
  "Single",
  "Dual Barrel",
  "Dual Barrel Alternate",
  "Quad Barrel",
  "Quad Barrel Alternate",
  "Quad Barrel Double Alternate"
}; // idb