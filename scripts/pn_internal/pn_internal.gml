function pn_is_internal_object() { return (object_index == objControl || object_index == rousrDissonance) }

function pn_show_message(_string)
{
	global.busy = true;
	return (show_message(_string))
}

function pn_show_question(_string)
{
	global.busy = true;
	return (show_question(_string))
}

function pn_get_integer(_string, _default)
{
	global.busy = true;
	var input = get_integer(_string, _default);
	return (is_undefined(input) ? _default : input)
}

function pn_get_string(_string, _default)
{
	global.busy = true;
	var input = get_string(_string, _default);
	return (is_undefined(input) ? _default : input)
}

function pn_get_open_filename(_filter, _filename)
{
	global.busy = true;
	return (get_open_filename(_filter, _filename))
}

function pn_get_save_filename(_filter, _filename)
{
	global.busy = true;
	return (get_save_filename(_filter, _filename))
}

function pn_clear_level_information()
{
	ds_map_clear(global.events);
	ds_map_clear(global.levelData);
	
	//Level
	global.levelName = "Untitled";
	global.levelIcon = "largeicon0";

	//Music
	global.levelMusic = ["", ""]; //normal, battle

	//Graphics
	global.skybox = "";
	global.skyboxColor = [0, 0, 0];
	global.fogDistance = [0, 65536];
	global.fogColor = [0, 0, 0, 1];
	global.lightNormal = [-1, 0, -1];
	global.lightColor = [1, 1, 1, 1];
	global.lightAmbientColor = [0.5, 0.5, 0.5, 1];
}

function pn_clear_level_information_ui()
{
	objControl.tabLevelInformation._contents[| 0].SetValue(global.levelName);
	objControl.tabLevelInformation._contents[| 1].SetValue(global.levelIcon);
	objControl.tabLevelInformation._contents[| 2].SetValue(global.levelMusic[0]);
	objControl.tabLevelInformation._contents[| 3].SetValue(global.levelMusic[1]);
	objControl.tabLevelInformation._contents[| 4].SetValue(global.skybox);
	objControl.tabLevelInformation._contents[| 5].SetValue(make_color_rgb(global.skyboxColor[0] * 255, global.skyboxColor[1] * 255, global.skyboxColor[2] * 255));
	objControl.tabLevelInformation._contents[| 6].SetValue(global.fogDistance[0]);
	objControl.tabLevelInformation._contents[| 7].SetValue(global.fogDistance[1]);
	objControl.tabLevelInformation._contents[| 8].SetValue(make_color_rgb(global.fogColor[0] * 255, global.fogColor[1] * 255, global.fogColor[2] * 255));
	objControl.tabLevelInformation._contents[| 9].SetValue(global.fogColor[3]);
}