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
	global.levelMusic = [noone, noone]; //normal, battle

	//Graphics
	global.skybox = noone;
	global.skyboxColor = [0, 0, 0];
	global.fogDistance = [0, 65536];
	global.fogColor = [0, 0, 0, 0];
	global.lightNormal = [-1, 0, -1];
	global.lightColor = [0, 0, 0, 0];
}