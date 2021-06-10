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
	new EmuInput(8, 8, 496, 24, "Level Name", global.levelName, "(name of the level shown by RPC)", 1000, E_InputTypes.STRING, function () { global.levelName = value; }),
	new EmuInput(8, 36, 496, 24, "Level Icon", global.levelIcon, "(name of the large icon shown by RPC)", 1000, E_InputTypes.STRING, function () { global.levelIcon = value; })
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
			objControl.tabLevelInformation._contents[| 0].SetValue("Untitled");
			objControl.tabLevelInformation._contents[| 1].SetValue("largeicon0");
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