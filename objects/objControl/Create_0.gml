/// @description Initialize Editor

/*--------
ASSET MAPS
--------*/

global.sprites = ds_map_create();
global.materials = ds_map_create();
global.fonts = ds_map_create();
global.sounds = ds_map_create();
global.music = ds_map_create();

ini_open("config.ini");
global.dataDirectory = ini_read_string("config", "gameDirectory", "") + "/data";
ini_close();

if !(directory_exists(global.dataDirectory)) show_message("WARNING: The specified folder path does not have a Project Nightmare Engine data folder. Set a valid one in config.ini!");

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
global.levelEvent = 0;
global.levelEventList = ds_list_create();
global.events = ds_map_create();
global.eventsList = ds_list_create();
global.levelData = ds_map_create();
global.levelDataList = ds_list_create();
global.channel = FMODGMS_Chan_CreateChannel();

pn_clear_level_information();

global.windowWidthPrevious = window_get_width();
global.windowHeightPrevious = window_get_height();

global.cameraX = 0;
global.cameraY = 0;
global.cameraZ = 0;
global.cameraYaw = 0;
global.cameraPitch = 0;
global.camera3D = true;
global.camera3DControl = false;
global.cameraMouseX = 0;
global.cameraMouseY = 0;
global.camera3DMouseX = 0;
global.camera3DMouseY = 0;
global.zoom = 1;

global.cursorX = 0;
global.cursorY = 0;
global.floorZ = 0;
global.gridSize = 16;

global.eventEditor = false;
global.eventSelected = -65536;

//Update loop
global.busy = true;
global.clock = new iota_clock();
global.clock.set_update_frequency(60);

tabLevelInformation = new EmuTab("Level Information");
tabLevelInformation.AddContent([
	new EmuInput(8, EMU_AUTO, 496, 24, "Level Name", global.levelName, "(level name shown by RPC)", 1000, E_InputTypes.STRING, function () { global.levelName = value; }),
	new EmuInput(8, EMU_AUTO, 496, 24, "Level Icon", global.levelIcon, "(large icon shown by RPC)", 1000, E_InputTypes.STRING, function () { global.levelIcon = value; }),
	new EmuInput(8, EMU_AUTO, 496, 24, "Music", global.levelMusic[0], "(music track name)", 1000, E_InputTypes.STRING, function () { global.levelMusic[0] = value; }),
	new EmuButton(8, EMU_AUTO, 496, 24, "Play/Stop Music", function()
	{
		if (FMODGMS_Chan_Get_Position(global.channel) > 0) FMODGMS_Chan_StopChannel(global.channel);
		else
		{
			repeat (ds_map_size(global.music))
			{
				var track = ds_map_find_first(global.music);
				FMODGMS_Snd_Unload(global.music[? track]);
				ds_map_delete(global.music, track);
			}
			pn_music_load(global.levelMusic[0]);
			if !(ds_map_exists(global.music, global.levelMusic[0])) pn_show_message("Play/Stop Music: Unknown track '" + global.levelMusic[1] + "'!");
			else FMODGMS_Snd_PlaySound(global.music[? global.levelMusic[0]], global.channel);
		}
	}),
	new EmuInput(8, EMU_AUTO, 496, 24, "Battle Music", global.levelMusic[1], "(music track name)", 1000, E_InputTypes.STRING, function () { global.levelMusic[1] = value; }),
	new EmuButton(8, EMU_AUTO, 496, 24, "Play/Stop Battle Music", function()
	{
		if (FMODGMS_Chan_Get_Position(global.channel) > 0) FMODGMS_Chan_StopChannel(global.channel);
		else
		{
			repeat (ds_map_size(global.music))
			{
				var track = ds_map_find_first(global.music);
				FMODGMS_Snd_Unload(global.music[? track]);
				ds_map_delete(global.music, track);
			}
			pn_music_load(global.levelMusic[1]);
			if !(ds_map_exists(global.music, global.levelMusic[1])) pn_show_message("Play/Stop Battle Music: Unknown track '" + global.levelMusic[1] + "'!");
			else FMODGMS_Snd_PlaySound(global.music[? global.levelMusic[1]], global.channel);
		}
	}),
	new EmuInput(8, EMU_AUTO, 496, 24, "Skybox Texture", global.skybox, "(material name)", 1000, E_InputTypes.STRING, function () { global.skybox = value; }),
	new EmuInput(8, EMU_AUTO, 496, 24, "Skybox Color", string(make_color_rgb(global.skyboxColor[0] * 255, global.skyboxColor[1] * 255, global.skyboxColor[2] * 255)), "(BGR integer, 0 - 16777215)", 10, E_InputTypes.INT, function ()
	{
		var color = real(value);
		global.skyboxColor = [color_get_red(color) / 255, color_get_green(color) / 255, color_get_blue(color) / 255, color];
	}),
	new EmuInput(8, EMU_AUTO, 496, 24, "Fog Start Distance", string(global.fogDistance[0]), "", 10, E_InputTypes.REAL, function () { global.fogDistance[0] = real(value); }),
	new EmuInput(8, EMU_AUTO, 496, 24, "Fog End Distance", string(global.fogDistance[1]), "", 10, E_InputTypes.REAL, function () { global.fogDistance[1] = real(value); }),
	new EmuInput(8, EMU_AUTO, 496, 24, "Fog Color", string(make_color_rgb(global.fogColor[0] * 255, global.fogColor[1] * 255, global.fogColor[2] * 255)), "(BGR integer, 0 - 16777215)", 10, E_InputTypes.INT, function ()
	{
		var color = real(value);
		global.fogColor = [color_get_red(color) / 255, color_get_green(color) / 255, color_get_blue(color) / 255, global.fogColor[3]];
	}),
	new EmuInput(8, EMU_AUTO, 496, 24, "Fog Alpha", string(global.fogColor[3]), "(0.0 - 1.0)", 16, E_InputTypes.REAL, function () { global.fogColor[3] = real(value); }),
	new EmuInput(8, EMU_AUTO, 496, 24, "Light Normal X", string(global.lightNormal[0]), "(-1.0 - 1.0)", 16, E_InputTypes.REAL, function () { global.lightNormal[0] = real(value); }),
	new EmuInput(8, EMU_AUTO, 496, 24, "Light Normal Y", string(global.lightNormal[1]), "(-1.0 - 1.0)", 16, E_InputTypes.REAL, function () { global.lightNormal[1] = real(value); }),
	new EmuInput(8, EMU_AUTO, 496, 24, "Light Normal Z", string(global.lightNormal[2]), "(-1.0 - 1.0)", 16, E_InputTypes.REAL, function () { global.lightNormal[2] = real(value); }),
	new EmuInput(8, EMU_AUTO, 496, 24, "Light Color", string(make_color_rgb(global.lightColor[0] * 255, global.lightColor[1] * 255, global.lightColor[2] * 255)), "(BGR integer, 0 - 16777215)", 10, E_InputTypes.INT, function ()
	{
		var color = real(value);
		global.lightColor = [color_get_red(color) / 255, color_get_green(color) / 255, color_get_blue(color) / 255, global.lightColor[3]];
	}),
	new EmuInput(8, EMU_AUTO, 496, 24, "Light Alpha", string(global.lightColor[3]), "(0.0 - 1.0)", 16, E_InputTypes.REAL, function () { global.lightColor[3] = real(value); }),
	new EmuInput(8, EMU_AUTO, 496, 24, "Light Ambient Color", string(make_color_rgb(global.lightAmbientColor[0] * 255, global.lightAmbientColor[1] * 255, global.lightAmbientColor[2] * 255)), "(BGR integer, 0 - 16777215)", 10, E_InputTypes.INT, function ()
	{
		var color = real(value);
		global.lightAmbientColor = [color_get_red(color) / 255, color_get_green(color) / 255, color_get_blue(color) / 255, global.lightAmbientColor[3]];
	}),
	new EmuInput(8, EMU_AUTO, 496, 24, "Light Ambient Alpha", string(global.lightAmbientColor[3]), "(0.0 - 1.0)", 16, E_InputTypes.REAL, function () { global.lightAmbientColor[3] = real(value); })
]);
tabLevelInformation._contents[| 7].SetRealNumberBounds(0, 16777215); //Skybox Color
tabLevelInformation._contents[| 8].SetRealNumberBounds(0, 2147483647); //Fog Start Distance
tabLevelInformation._contents[| 9].SetRealNumberBounds(0, 2147483647); //Fog End Distance
tabLevelInformation._contents[| 10].SetRealNumberBounds(0, 16777215); //Fog Color
tabLevelInformation._contents[| 11].SetRealNumberBounds(0, 1); //Fog Alpha
tabLevelInformation._contents[| 12].SetRealNumberBounds(-1, 1); //Light Normal X
tabLevelInformation._contents[| 13].SetRealNumberBounds(-1, 1); //Light Normal Y
tabLevelInformation._contents[| 14].SetRealNumberBounds(-1, 1); //Light Normal Z
tabLevelInformation._contents[| 15].SetRealNumberBounds(0, 16777215); //Light Color
tabLevelInformation._contents[| 16].SetRealNumberBounds(0, 1); //Light Alpha
tabLevelInformation._contents[| 17].SetRealNumberBounds(0, 16777215); //Light Ambient Color
tabLevelInformation._contents[| 18].SetRealNumberBounds(0, 1); //Light Ambient Alpha

tabEvents = new EmuTab("Events");
global.tabEventsList = new EmuList(8, EMU_AUTO, 496, 24, "Events:", 32, 8, function ()
{
	var selection = GetSelection();
	if (selection > -1) global.levelEvent = global.eventsList[| selection];
});
global.tabEventsList.SetList(global.eventsList);
tabEvents.AddContent([
	global.tabEventsList,
	new EmuButton(8, EMU_AUTO, 496, 24, "Edit Selected Event...", function ()
	{
		if (!ds_map_empty(global.events) && ds_map_exists(global.events, global.levelEvent))
		{
			pn_reset_current_event_list();
			global.eventEditor = true;
			var event = global.events[? global.levelEvent];
			global.eventUI._contents[| 2].value = event[| 0];
			global.eventUI._contents[| 3].value = event[| 1];
		}
		else pn_show_message("Edit Selected Event...: Select an event first!");
	}),
	new EmuButton(8, EMU_AUTO, 496, 24, "Add Event...", function ()
	{
		var getID = pn_get_integer("Add Event...: Event ID:", global.levelEvent);
		if (ds_map_exists(global.events, getID)) pn_show_message("Add Event...: Event " + string(getID) + " already exists!");
		else
		{
			var newEvent = ds_list_create();
			ds_list_add(newEvent, false, false); //trigger on level start, persistent
			ds_map_add_list(global.events, getID, newEvent);
			pn_reset_events_list();
			global.levelEvent = getID;
		}
	}),
	new EmuButton(8, EMU_AUTO, 496, 24, "Delete Selected Event", function ()
	{
		var selection = global.tabEventsList.GetSelection();
		if (selection > -1) ds_map_delete(global.events, global.eventsList[| selection]);
		pn_reset_events_list();
		global.levelEvent = global.tabEventsList.GetSelection();
	})
]);

tabRooms = new EmuTab("Rooms");
global.tabRoomsList = new EmuList(8, EMU_AUTO, 492, 24, "Rooms:", 32, 8, function ()
{
	var selection = GetSelection();
	if (selection > -1) global.levelRoom = global.levelDataList[| selection];
});
global.tabRoomsList.SetList(global.levelDataList);
tabRooms.AddContent(
[
	global.tabRoomsList,
	new EmuButton(8, EMU_AUTO, 496, 24, "Edit Selected Room...", function ()
	{
		if (!ds_map_empty(global.levelData) && ds_map_exists(global.levelData, global.levelRoom))
		{
			/*pn_reset_current_room_list();
			global.roomEditor = true;
			var _room = global.levelData[? global.levelRoom];*/
		}
		else pn_show_message("Edit Selected Room...: Select a room first!");
	}),
	new EmuButton(8, EMU_AUTO, 496, 24, "Add Room...", function ()
	{
		var getID = pn_get_integer("Add Room...: Room ID:", global.levelEvent);
		if (ds_map_exists(global.levelData, getID)) pn_show_message("Add Room...: Room " + string(getID) + " already exists!");
		else
		{
			ds_map_add(global.levelData, getID, undefined);
			pn_reset_rooms_list();
			global.levelRoom = getID;
		}
	}),
	new EmuButton(8, EMU_AUTO, 496, 24, "Delete Selected Room", function ()
	{
		var selection = global.tabRoomsList.GetSelection();
		if (selection > -1) ds_map_delete(global.levelData, global.levelDataList[| selection]);
		pn_reset_rooms_list();
		global.levelRoom = global.tabRoomsList.GetSelection();
	})
]);

global.tabPreferences = new EmuTab("Preferences");
global.tabPreferences.AddContent(
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
			for (var i = 0; i < 3; i++) global.skyboxColor[i] = buffer_read(currentLevelBuffer, buffer_f32);
			for (var i = 0; i < 2; i++) global.fogDistance[i] = buffer_read(currentLevelBuffer, buffer_f32);
			for (var i = 0; i < 4; i++) global.fogColor[i] = buffer_read(currentLevelBuffer, buffer_f32);
			for (var i = 0; i < 3; i++) global.lightNormal[i] = buffer_read(currentLevelBuffer, buffer_f32);
			for (var i = 0; i < 4; i++) global.lightColor[i] = buffer_read(currentLevelBuffer, buffer_f32);
			for (var i = 0; i < 4; i++) global.lightAmbientColor[i] = buffer_read(currentLevelBuffer, buffer_f32);
			
			var events = buffer_read(currentLevelBuffer, buffer_u16), rooms = buffer_read(currentLevelBuffer, buffer_u16);
			
			buffer_delete(currentLevelBuffer);
			
			//Events
			show_debug_message(string(events) + " events found");
			for (var i = 1, n = events + 1; i < n; i++)
			{
				var loadEvent = ds_list_create(), j = 3;
				
				currentLevelBuffer = carton_get_buffer(levelCarton, i);
				
				ds_list_add(loadEvent, buffer_read(currentLevelBuffer, buffer_u8));
				ds_list_add(loadEvent, buffer_read(currentLevelBuffer, buffer_u8));
				repeat (buffer_read(currentLevelBuffer, buffer_u16))
				{
					var actionData = string_parse(buffer_read(currentLevelBuffer, buffer_string), true), eventAction, actionArgs = array_length(actionData), j = 0;
					if (actionArgs == 1) eventAction = actionData[0]; //Action has no arguments, therefore a string
					else
					{
						eventAction = [];
						repeat (actionArgs)
						{
							eventAction[@ array_length(eventAction)] = actionData[j];
							j++;
						}
					}
					ds_list_add(loadEvent, eventAction);
				}
				
				buffer_delete(currentLevelBuffer);
				
				var eventID = carton_get_metadata(levelCarton, i);
				show_debug_message(string(i) + "/" + string(n) + ", ID " + eventID + ", " + string(ds_list_size(loadEvent)) + " actions");
				ds_map_add_list(global.events, real(eventID), loadEvent);
			}
			pn_reset_events_list();
			
			//Rooms
			/*for (var i = n, n = n + rooms; i < n; i++)
			{
				currentLevelBuffer = carton_get_buffer(levelCarton, i);
				buffer_delete(currentLevelBuffer);
			}
			pn_reset_rooms_list();*/
			
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
			for (var i = 0; i < 3; i++) buffer_write(currentLevelBuffer, buffer_f32, global.skyboxColor[i]);
			for (var i = 0; i < 2; i++) buffer_write(currentLevelBuffer, buffer_f32, global.fogDistance[i]);
			for (var i = 0; i < 4; i++) buffer_write(currentLevelBuffer, buffer_f32, global.fogColor[i]);
			for (var i = 0; i < 3; i++) buffer_write(currentLevelBuffer, buffer_f32, global.lightNormal[i]);
			for (var i = 0; i < 4; i++) buffer_write(currentLevelBuffer, buffer_f32, global.lightColor[i]);
			for (var i = 0; i < 4; i++) buffer_write(currentLevelBuffer, buffer_f32, global.lightAmbientColor[i]);
			
			buffer_write(currentLevelBuffer, buffer_u16, ds_map_size(global.events)); //Event amount
			buffer_write(currentLevelBuffer, buffer_u16, ds_map_size(global.levelData)); //Room amount
			
			carton_add(levelCarton, "", currentLevelBuffer);
			buffer_delete(currentLevelBuffer);
			
			//Events
			for (var key = ds_map_find_first(global.events); !is_undefined(key); key = ds_map_find_next(global.events, key))
			{
				currentLevelBuffer = buffer_create(1, buffer_grow, 1);
				
				var event = global.events[? key];
				
				buffer_write(currentLevelBuffer, buffer_u8, event[| 0]);
				buffer_write(currentLevelBuffer, buffer_u8, event[| 1]);
				buffer_write(currentLevelBuffer, buffer_u16, ds_list_size(event) - 2);
				
				for (var i = 2; i < ds_list_size(event); i++)
				{
					var action = event[| i], n = array_length(action), eventString = is_array(action) ? "" : string(action);
					if (n > 1)
					{
						var j = 0;
						repeat (n)
						{
							eventString += is_string(action[j]) ? "s:" + action[j] : string(action[j]);
							j++;
							if (j != n) eventString += "|";
						}
					}
					buffer_write(currentLevelBuffer, buffer_string, eventString);
				}
				
				carton_add(levelCarton, string(key), currentLevelBuffer);
				buffer_delete(currentLevelBuffer);
			}
			
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
	}),
	new EmuCheckbox(8, 136, 496, 24, "3D Mode", global.camera3D, function () { global.camera3D = value; }),
	new EmuInput(8, 164, 496, 24, "Grid Size", string(global.gridSize), "", 10, E_InputTypes.REAL, function () { global.gridSize = real(value); })
]);
global.tabPreferences._contents[| 5].SetRealNumberBounds(1, 4294967295); //Grid Size

tabs = new EmuTabGroup(0, 0, 512, 720, 2, 24);
tabs.AddTabs(0, global.tabPreferences);
tabs.AddTabs(1, [tabLevelInformation, tabEvents, tabRooms]);

global.cameraViewMatrix = [undefined, matrix_build_lookat(global.cameraX, global.cameraY, global.cameraZ, global.cameraX + dcos(global.cameraYaw), global.cameraY - dsin(global.cameraYaw), global.cameraZ + dtan(global.cameraPitch), 0, 0, 1)];
global.cameraProjMatrix = [undefined, matrix_build_projection_perspective_fov(-45, -(window_get_width() - 512) / window_get_height(), 1, 65536)];


editor = new EmuRenderSurface(512, 0, 768, 720, function (mx, my)
{
	draw_clear(global.skyboxColor[3]);
	draw_set_color(c_white);
	
	camera_set_view_mat(view_camera[0], global.cameraViewMatrix[global.camera3D]);
	camera_set_proj_mat(view_camera[0], global.cameraProjMatrix[global.camera3D]);
	camera_apply(view_camera[0]);
	
	if !(global.camera3D) matrix_set(matrix_world, matrix_build(-global.cameraX, -global.cameraY, 0, 0, 0, 0, global.zoom, global.zoom, -global.zoom));
	draw_text(0, 0, "TEST");
	draw_text(0, 32, "TEST TEST TEST TEST TEST TEST TEST TEST TEST\n TEST TEST TEST TEST TEST\nTEST\nTEST");
	draw_set_alpha(0.5);
	draw_rectangle(global.cursorX - 2, global.cursorY - 2, global.cursorX + 2, global.cursorY + 2, false);
	draw_set_alpha(1);
	smf_matrix_reset();
}, function (mx, my)
{
	//Editor area-specific controls
	if (global.camera3DControl || !point_in_rectangle(window_mouse_get_x(), window_mouse_get_y(), 0, 0, 512, global.windowHeightPrevious))
	{
		if (global.camera3D)
		{
			if (mouse_check_button_pressed(mb_left) && !global.camera3DControl)
			{
				global.camera3DMouseX = display_mouse_get_x();
				global.camera3DMouseY = display_mouse_get_y();
				global.camera3DControl = true;
			}
			
			global.cameraViewMatrix[1] = matrix_build_lookat(global.cameraX, global.cameraY, global.cameraZ, global.cameraX + dcos(global.cameraYaw), global.cameraY - dsin(global.cameraYaw), global.cameraZ + dtan(global.cameraPitch), 0, 0, 1);
		}
		else
		{
			//Move camera
			if (mouse_check_button(mb_middle))
		    {
		        global.cameraX = global.cameraX + (global.cameraMouseX - mx) //* global.zoom;
		        global.cameraY = global.cameraY + (global.cameraMouseY - my) //* global.zoom;
		    }
		
			global.zoom = max(0.1, global.zoom + (mouse_wheel_up() - mouse_wheel_down()) * 0.1);
		
			//Move cursor
			var cx = (global.cameraX + mx) / global.zoom, cy = (global.cameraY + my) / global.zoom;
			global.cursorX = pn_snap_round(cx, global.gridSize);
			global.cursorY = pn_snap_round(cy, global.gridSize);
		}
		
		//Toggle 3D camera
		if (keyboard_check_pressed(ord("Q")))
		{
			global.camera3D = !global.camera3D;
			global.tabPreferences._contents[| 4].value = global.camera3D;
		}
		
		//Reset camera
		if (keyboard_check_pressed(ord("R")))
		{
			global.cameraX = 0;
			global.cameraY = 0;
			global.cameraZ = 0;
			global.cameraYaw = 0;
			global.cameraPitch = 0;
			global.zoom = 1;
		}
		
		//3D camera control
		if (global.camera3DControl)
		{
			//Mouselook
			global.cameraYaw -= (display_mouse_get_x() - global.camera3DMouseX) / 5;
			global.cameraPitch = clamp(global.cameraPitch - ((display_mouse_get_y() - global.camera3DMouseY) / 5), -89.95, 89.95);
			display_mouse_set(global.camera3DMouseX, global.camera3DMouseY);
			
			//Movement code by YAL
		    var keyX = (keyboard_check(ord("W")) - keyboard_check(ord("S"))), keyY = keyboard_check(ord("D")) - keyboard_check(ord("A")), keyZ = keyboard_check(ord("Z")) - keyboard_check(ord("X")), keyL = point_distance(0, 0, keyX, keyY), speedX = keyX * 6, speedY = keyY * 6, speedZ = keyZ * 6, fastModifier = 1 + keyboard_check(vk_control); //length of moving vector
		    if (keyL > 1) //If needed, normalize vector to prevent faster diagonal movement
		    {
		        keyX /= keyL;
		        keyY /= keyL;
		        keyL = 1;
		    }
		    global.cameraX += fastModifier * (lengthdir_x(lengthdir_x(speedX, global.cameraYaw), global.cameraPitch) + lengthdir_x(speedY, global.cameraYaw - 90));
		    global.cameraY += fastModifier * (lengthdir_x(lengthdir_y(speedX, global.cameraYaw), global.cameraPitch) + lengthdir_y(speedY, global.cameraYaw - 90));
		    global.cameraZ -= fastModifier * (lengthdir_y(speedX, global.cameraPitch) + speedZ);
			
			if (!global.camera3D || mouse_check_button_released(mb_left)) global.camera3DControl = false;
		}
	}
	
	//Update previous camera mouse position
	global.cameraMouseX = mx;
	global.cameraMouseY = my;
}, function ()
{
	global.cameraViewMatrix[0] = camera_get_view_mat(view_camera[0]);
	global.cameraProjMatrix[0] = camera_get_proj_mat(view_camera[0]);
	show_debug_message(string(global.cameraViewMatrix[0]) + ", " + string(global.cameraProjMatrix[0]));
	cam_3d_enable();
}, function () {});

global.ui = new EmuCore(0, 0, 512, 720);
global.ui.AddContent([tabs, editor]);

global.eventUIList = new EmuList(8, EMU_AUTO, 496, 24, "Actions: ", 32, 16, function ()
{
	var selection = GetSelection();
	if (selection > -1 && keyboard_check(vk_control)) pn_event_edit_action(selection + 2);
	global.eventSelected = selection + 2;
});
global.eventUIList.SetList(global.levelEventList);

global.eventUI = new EmuCore(0, 0, 512, 720);
global.eventUI.AddContent(
[
	global.eventUIList,
	new EmuText(8, EMU_AUTO, 496, 24, "Hold Control while clicking an action to edit it."),
	new EmuCheckbox(8, EMU_AUTO, 496, 24, "Trigger on Level Start", false, function() { global.events[? global.levelEvent][| 0] = value; }),
	new EmuCheckbox(8, EMU_AUTO, 496, 24, "Persistent", false, function() { global.events[? global.levelEvent][| 1] = value; }),
	new EmuButton(8, EMU_AUTO, 244, 24, "Move Up", function ()
	{
		var event = global.events[? global.levelEvent], action = event[| global.eventSelected];
		ds_list_delete(event, global.eventSelected);
		global.eventSelected = max(2, global.eventSelected - 1);
		ds_list_insert(event, global.eventSelected, action);
		pn_reset_current_event_list();
	}),
	new EmuButton(258, EMU_AUTO, 244, 24, "Move Down", function ()
	{
		var event = global.events[? global.levelEvent], action = event[| global.eventSelected];
		ds_list_delete(event, global.eventSelected);
		global.eventSelected = min(ds_list_size(event), global.eventSelected + 1);
		ds_list_insert(event, global.eventSelected, action);
		pn_reset_current_event_list();
	}),
	new EmuButton(8, EMU_AUTO, 496, 24, "Add Action...", function ()
	{
		var currentEvent = global.events[? global.levelEvent], getAction = pn_get_integer("Add Action...: Action ID...", ds_list_empty(currentEvent) ? 0 : (is_array(currentEvent[| ds_list_size(currentEvent) - 1]) ? currentEvent[| ds_list_size(currentEvent) - 1][0] : currentEvent[| ds_list_size(currentEvent) - 1])), addAction;
		switch (getAction)
		{
			case (eEventAction.wait):
			case (eEventAction.setRoom):
			case (eEventAction.gotoLevel):
			case (eEventAction.lockPlayer):
			case (eEventAction.lockCamera): 
			case (eEventAction.setCameraRoll): 
			case (eEventAction.setCameraFOV): 
			case (eEventAction.setCameraTarget): addAction = [getAction, 0]; break
			
			case (eEventAction.triggerEvent):
			case (eEventAction.pauseEvent):
			case (eEventAction.resumeEvent):
			case (eEventAction.stopEvent): addAction = [getAction, global.levelEvent]; break
			
			case (eEventAction.setSkyboxTexture): addAction = [getAction, global.skybox]; break
			
			case (eEventAction.fadeSkyboxColor): addAction = [getAction, global.skyboxColor[3], 0]; break
			
			case (eEventAction.fadeFog): addAction = [getAction, global.fogDistance[0], global.fogDistance[1], make_color_rgb(global.fogColor[0] * 255, global.fogColor[1] * 255, global.fogColor[2] * 255), global.fogColor[3], 0]; break
			
			case (eEventAction.fadeLight): addAction = [getAction, global.lightNormal[0], global.lightNormal[1], global.lightNormal[2], make_color_rgb(global.lightColor[0] * 255, global.lightColor[1] * 255, global.lightColor[2] * 255), global.lightColor[3], make_color_rgb(global.lightAmbientColor[0] * 255, global.lightAmbientColor[1] * 255, global.lightAmbientColor[2] * 255), global.lightAmbientColor[3], 0]; break
			
			case (eEventAction._message): addAction = [getAction, ""]; break
			
			case (eEventAction.lockCameraToActor): 
			case (eEventAction.lerpCamera):
			case (eEventAction.exclamation): addAction = [getAction, 0, 0]; break
			
			case (eEventAction.lockCameraToPosition): addAction = [getAction, global.cameraMouseX, global.cameraMouseY, global.cameraZ, 0]; break
			
			case (eEventAction.setCameraPosition): addAction = [getAction, global.cameraMouseX, global.cameraMouseY, global.cameraZ];
			
			default: addAction = getAction;
		}
		ds_list_add(currentEvent, addAction);
		pn_event_edit_action(ds_list_size(currentEvent) - 1);
	}),
	new EmuButton(8, EMU_AUTO, 496, 24, "Delete Selected Action...", function ()
	{
		if (global.eventSelected > -1) ds_list_delete(global.events[? global.levelEvent], global.eventSelected);
		pn_reset_current_event_list();
	}),
	new EmuButton(8, EMU_AUTO, 496, 24, "Done", function () { global.eventEditor = false; }),
	editor
]);

global.clock.add_cycle_method(function ()
{
	var windowWidth = window_get_width(), windowHeight = window_get_height();
	if ((windowWidth != global.windowWidthPrevious || windowHeight != global.windowHeightPrevious) && windowWidth && windowHeight)
	{
		show_debug_message(string(windowWidth) + ", " + string(windowHeight));
		camera_set_view_size(view_camera[0], windowWidth, windowHeight);
		surface_resize(application_surface, windowWidth, windowHeight);
		global.ui.height = windowHeight;
		tabs.height = windowHeight;
		editor.width = windowWidth - 512;
		editor.height = windowHeight;
		global.windowWidthPrevious = windowWidth;
		global.windowHeightPrevious = windowHeight;
		global.cameraProjMatrix[1] = matrix_build_projection_perspective_fov(-45, -(windowWidth - 512) / windowHeight, 1, 65536);
	}
});