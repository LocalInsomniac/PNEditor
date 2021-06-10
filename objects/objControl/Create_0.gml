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

global.levelRoom = 0;
global.events = ds_map_create();
global.levelData = ds_map_create();
global.channel = [FMODGMS_Chan_CreateChannel(), FMODGMS_Chan_CreateChannel()]; //normal, battle

pn_clear_level_information();

windowWidthPrevious = window_get_width();
windowHeightPrevious = window_get_height();

//Update loop
global.busy = true;
global.clock = new iota_clock();
global.clock.set_update_frequency(60);

tabLevelInformation = new EmuTab("Level Information");
tabLevelInformation.AddContent(
[
	new EmuInput(8, 8, 496, 24, "Level Name", global.levelName, "(level name shown by RPC)", 1000, E_InputTypes.STRING, function () { global.levelName = value; }),
	new EmuInput(8, 36, 496, 24, "Level Icon", global.levelIcon, "(large icon shown by RPC)", 1000, E_InputTypes.STRING, function () { global.levelIcon = value; }),
	new EmuInput(8, 60, 496, 24, "Music", global.levelMusic[0], "(music track name)", 1000, E_InputTypes.STRING, function () { global.levelMusic[0] = value; }),
	new EmuInput(8, 88, 496, 24, "Battle Music", global.levelMusic[1], "(music track name)", 1000, E_InputTypes.STRING, function () { global.levelMusic[1] = value; }),
	new EmuInput(8, 120, 496, 24, "Skybox Texture", global.skybox, "(material name)", 1000, E_InputTypes.STRING, function () { global.skybox = value; }),
	new EmuColorPicker(8, 148, 496, 128, "Skybox Color", make_color_rgb(global.skyboxColor[0] * 255, global.skyboxColor[1] * 255, global.skyboxColor[2] * 255), function () { global.skyboxColor = [color_get_red(value) / 255, color_get_green(value) / 255, color_get_blue(value) / 255]; }),
	new EmuInput(8, 284, 496, 24, "Fog Start Distance", global.fogDistance[0], "", 4294967295, E_InputTypes.INT, function () { global.fogDistance[0] = value; }),
	new EmuInput(8, 312, 496, 24, "Fog End Distance", global.fogDistance[1], "", 4294967295, E_InputTypes.INT, function () { global.fogDistance[1] = value; }),
	new EmuColorPicker(8, 340, 496, 128, "Fog Color", make_color_rgb(global.fogColor[0] * 255, global.fogColor[1] * 255, global.fogColor[2] * 255), function () { global.fogColor = [color_get_red(value) / 255, color_get_green(value) / 255, color_get_blue(value) / 255, global.fogColor[3]]; }),
	new EmuInput(8, 472, 496, 24, "Fog Alpha", global.fogColor[3], "", 1000, E_InputTypes.REAL, function () { global.fogColor[3] = value; })
]);
tabEvents = new EmuTab("Events");
tabRooms = new EmuTab("Rooms");

tabPreferences = new EmuTab("Preferences");
tabPreferences.AddContent(
[
	new EmuText(0, 0, 512, 48, "PN Editor 1.0\nby Can't Sleep"),
	new EmuButton(8, 52, 496, 24, "Open...", function ()
	{
		var getFile = pn_get_open_filename("Project Nightmare Level file|*.pnl", "");
		if (getFile != "")
		{
			pn_clear_level_information();
			var levelCarton = carton_load(getFile, true), currentLevelBuffer = carton_get_buffer(levelCarton, 0);
			//Level information
			global.levelName = buffer_read(currentLevelBuffer, buffer_string);
			global.levelIcon = buffer_read(currentLevelBuffer, buffer_string);
			for (var i = 0; i < 2; i++) global.levelMusic[i] = buffer_read(currentLevelBuffer, buffer_string);
			global.skybox = buffer_read(currentLevelBuffer, buffer_string);
			for (var i = 0; i < 3; i++) global.skyboxColor[i] = buffer_read(currentLevelBuffer, buffer_u8);
			for (var i = 0; i < 2; i++) global.fogDistance[i] = buffer_read(currentLevelBuffer, buffer_u32);
			for (var i = 0; i < 4; i++) global.fogColor[i] = buffer_read(currentLevelBuffer, buffer_u8);
			for (var i = 0; i < 3; i++) global.lightNormal[i] = buffer_read(currentLevelBuffer, buffer_s8);
			for (var i = 0; i < 4; i++) global.lightColor[i] = buffer_read(currentLevelBuffer, buffer_u8);
			for (var i = 0; i < 4; i++) global.lightAmbientColor[i] = buffer_read(currentLevelBuffer, buffer_u8);
			buffer_delete(currentLevelBuffer);
			pn_clear_level_information_ui();
			carton_destroy(levelCarton);
		}
	}),
	new EmuButton(8, 80, 496, 24, "Save as...", function ()
	{
		var getFile = pn_get_save_filename("Project Nightmare Level file|*.pnl", global.levelName + ".pnl");
		if (getFile != "")
		{
			var levelCarton = carton_create(), currentLevelBuffer = buffer_create(1, buffer_grow, 1);
			//Level information
			buffer_write(currentLevelBuffer, buffer_string, global.levelName);
			buffer_write(currentLevelBuffer, buffer_string, global.levelIcon);
			for (var i = 0; i < 2; i++) buffer_write(currentLevelBuffer, buffer_string, global.levelMusic[i]);
			buffer_write(currentLevelBuffer, buffer_string, global.skybox);
			for (var i = 0; i < 3; i++) buffer_write(currentLevelBuffer, buffer_u8, global.skyboxColor[i]);
			for (var i = 0; i < 2; i++) buffer_write(currentLevelBuffer, buffer_u32, global.fogDistance[i]);
			for (var i = 0; i < 4; i++) buffer_write(currentLevelBuffer, buffer_u8, global.fogColor[i]);
			for (var i = 0; i < 3; i++) buffer_write(currentLevelBuffer, buffer_s8, global.lightNormal[i]);
			for (var i = 0; i < 4; i++) buffer_write(currentLevelBuffer, buffer_u8, global.lightColor[i]);
			for (var i = 0; i < 4; i++) buffer_write(currentLevelBuffer, buffer_u8, global.lightAmbientColor[i]);
			carton_add(levelCarton, "", currentLevelBuffer);
			buffer_delete(currentLevelBuffer);
			//Events
			//Rooms
			carton_save(levelCarton, getFile, true);
			carton_destroy(levelCarton);
		}
	}),
	new EmuButton(8, 108, 496, 24, "Clear...", function ()
	{
		if (pn_show_question("Are you sure you want to clear the current level? All unsaved progress will be lost."))
		{
			pn_clear_level_information();
			pn_clear_level_information_ui();
		}
	})
]);

tabs = new EmuTabGroup(0, 0, 512, 540, 2, 24);
tabs.AddTabs(0, tabPreferences);
tabs.AddTabs(1, [tabLevelInformation, tabEvents, tabRooms]);

editor = new EmuRenderSurface(512, 0, 720, 540, function (mx, my)
{
	draw_set_color(c_white);
	draw_text(mx, my, ":badklass:");
}, function (mx, my) {}, function () {}, function () {});

global.ui = new EmuCore(0, 0, 512, 540);
global.ui.AddContent([tabs, editor]);

global.clock.add_cycle_method(function ()
{
	var windowWidth = window_get_width(), windowHeight = window_get_height();
	if (windowWidth != windowWidthPrevious || windowHeight != windowHeightPrevious)
	{
		camera_set_view_size(view_camera[0], windowWidth, windowHeight);
		surface_resize(application_surface, windowWidth, windowHeight);
		global.ui.height = windowHeight;
		tabs.height = windowHeight;
		editor.width = windowWidth - 512;
		editor.height = windowHeight;
		windowWidthPrevious = windowWidth;
		windowHeightPrevious = windowHeight;
	}
});