/// @description Initialize Editor

/*--------
ASSET MAPS
--------*/

global.sprites = ds_map_create();
global.materials = ds_map_create();
global.fonts = ds_map_create();
global.sounds = ds_map_create();
global.music = ds_map_create();

/*-----
SYSTEMS
-----*/

smf_init();

FMODGMS_Sys_Create();
FMODGMS_Sys_Initialize(2);

colmesh_init();

/*----------
GAME SYSTEMS
----------*/

//Level
global.levelRoom = 0;
global.levelName = "Loading";
global.levelIcon = "largeicon0";
global.levelData = ds_map_create();
global.events = ds_map_create();

//Graphics
global.skybox = noone;
global.skyboxColor = [0, 0, 0];
global.fogDistance = [0, 65536];
global.fogColor = c_black;
global.lightNormal = [-1, 0, -1];
global.lightColor = c_white;

//Music
global.channel = [FMODGMS_Chan_CreateChannel(), FMODGMS_Chan_CreateChannel()]; //normal, battle
global.levelMusic = [noone, noone]; //normal, battle

//Update loop
global.clock = new iota_clock();
global.clock.set_update_frequency(60);

//Settings
global.bind = undefined;