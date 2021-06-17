function pn_is_internal_object() { return (object_index == objControl || object_index == rousrDissonance) }

//DIALOG

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

//LEVEL

function pn_clear_level_information()
{
	ds_map_clear(global.events);
	ds_list_clear(global.eventsList);
	ds_list_clear(global.levelEventList);
	ds_map_clear(global.levelData);
	ds_list_clear(global.levelDataList);
	
	//Level
	global.levelName = "Untitled";
	global.levelIcon = "largeicon0";

	//Music
	global.levelMusic = ["", ""]; //normal, battle

	//Graphics
	global.skybox = "";
	global.skyboxColor = [0, 0, 0, c_black];
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
	objControl.tabLevelInformation._contents[| 4].SetValue(global.levelMusic[1]);
	objControl.tabLevelInformation._contents[| 6].SetValue(global.skybox);
	objControl.tabLevelInformation._contents[| 7].SetValue(string(make_color_rgb(global.skyboxColor[0] * 255, global.skyboxColor[1] * 255, global.skyboxColor[2] * 255)));
	objControl.tabLevelInformation._contents[| 8].SetValue(string(global.fogDistance[0]));
	objControl.tabLevelInformation._contents[| 9].SetValue(string(global.fogDistance[1]));
	objControl.tabLevelInformation._contents[| 10].SetValue(string(make_color_rgb(global.fogColor[0] * 255, global.fogColor[1] * 255, global.fogColor[2] * 255)));
	objControl.tabLevelInformation._contents[| 11].SetValue(string(global.fogColor[3]));
	objControl.tabLevelInformation._contents[| 12].SetValue(string(global.lightNormal[0]));
	objControl.tabLevelInformation._contents[| 13].SetValue(string(global.lightNormal[1]));
	objControl.tabLevelInformation._contents[| 14].SetValue(string(global.lightNormal[2]));
	objControl.tabLevelInformation._contents[| 15].SetValue(string(make_color_rgb(global.lightColor[0] * 255, global.lightColor[1] * 255, global.lightColor[2] * 255)));
	objControl.tabLevelInformation._contents[| 16].SetValue(string(global.lightColor[3]));
	objControl.tabLevelInformation._contents[| 17].SetValue(string(make_color_rgb(global.lightAmbientColor[0] * 255, global.lightAmbientColor[1] * 255, global.lightAmbientColor[2] * 255)));
	objControl.tabLevelInformation._contents[| 18].SetValue(string(global.lightAmbientColor[3]));
	global.skyboxColor[3] = make_color_rgb(global.skyboxColor[0] * 255, global.skyboxColor[1] * 255, global.skyboxColor[2] * 255);
}

//EVENTS

enum eEventAction
{
	wait,
	waitMessage,
	waitTrigger,
	setRoom,
	setSkyboxTexture,
	fadeSkyboxColor,
	fadeFog,
	fadeLight,
	triggerEvent,
	gotoLevel,
	_message,
	lockPlayer,
	pauseEvent,
	resumeEvent,
	stopEvent,
	restoreCamera,
	lockCamera,
	lockCameraToActor,
	lockCameraToPosition,
	unlockCameraDirection,
	setCameraPosition,
	setCameraRoll,
	setCameraFOV,
	setCameraTarget,
	lerpCamera
}

function pn_reset_events_list()
{
	ds_list_clear(global.eventsList);
	for (var key = ds_map_find_first(global.events); !is_undefined(key); key = ds_map_find_next(global.events, key)) ds_list_add(global.eventsList, key);
}

function pn_reset_current_event_list()
{
	ds_list_clear(global.levelEventList);
	global.eventSelected = -1;
	var currentEvent = global.events[? global.levelEvent];
	for (var i = 2; i < ds_list_size(currentEvent); i++)
	{
		var eventAction = currentEvent[| i], label = "Unknown action " + string(eventAction);
		if (is_array(eventAction)) switch (eventAction[0])
		{
			case (eEventAction.wait): label = "0: Wait " + string(eventAction[1]) + " tick(s)"; break
			case (eEventAction.setRoom): label = "3: Set current room to " + string(eventAction[1]); break
			case (eEventAction.setSkyboxTexture): label = "4: Set skybox texture to " + eventAction[1]; break
			case (eEventAction.fadeSkyboxColor):
				label = "5: Fade skybox BGR color to " + string(eventAction[1]) + 
						" in " + string(eventAction[2]) + 
						" tick(s)";
			break
			case (eEventAction.fadeFog):
				label = "6: Fade fog to start " + string(eventAction[1]) + 
						", end " + string(eventAction[2]) + 
						", BGR color " + string(eventAction[3]) + 
						", alpha " + string(eventAction[4]) + 
						" in " + string(eventAction[5]) + 
						" tick(s)";
			break
			case (eEventAction.fadeLight):
				label = "7: Fade light to X normal " + string(eventAction[1]) + 
						", Y normal " + string(eventAction[2]) + 
						", Z normal " + string(eventAction[3]) + 
						", BGR color " + string(eventAction[4]) + 
						", alpha " + string(eventAction[5]) + 
						", BGR ambient color " + string(eventAction[6]) + 
						", ambient alpha " + string(eventAction[7]) + 
						" in " + string(eventAction[8]) + 
						" tick(s)";
			break
			case (eEventAction.triggerEvent): label = "8: Trigger event " + string(eventAction[1]); break
			case (eEventAction.gotoLevel): label = "9: Go to level " + string(eventAction[1]); break
			case (eEventAction._message): label = "10: Message \"" + eventAction[1] + "\""; break
			case (eEventAction.lockPlayer): label = "11: " + (eventAction[1] ? "Lock" : "Unlock") + " player"; break
			case (eEventAction.pauseEvent):
			case (eEventAction.resumeEvent):
			case (eEventAction.stopEvent):
				label = (eventAction[0] == eEventAction.pauseEvent ? "12: Pause " : (eventAction[0] == eEventAction.resumeEvent ? "13: Resume " : "14: Stop ")) + 
						(eventAction[1] == -3 ? "all non-level events" : (eventAction[1] == -2 ? "all level events" : (eventAction[1] == -1 ? "all events" : "event " + string(eventAction[1]))));
			break
			case (eEventAction.lockCamera): label = "16: " + (eventAction[1] ? "Lock" : "Unlock") + " camera position " + (eventAction[2] ? "smoothly" : "linearly"); break
			case (eEventAction.lockCameraToActor): label = "17: Lock camera towards actor " + string(eventAction[1]) + (eventAction[2] ? " smoothly" : " linearly"); break
			case (eEventAction.lockCameraToPosition):
				label = "18: Lock camera towards position X " + string(eventAction[1]) + 
						", Y " + string(eventAction[2]) +
						", Z " + string(eventAction[3]) + 
						(eventAction[2] ? " smoothly" : " linearly");
			break
			case (eEventAction.setCameraPosition):
				label = "20: Set camera position to X " + string(eventAction[1]) + 
						", Y " + string(eventAction[2]) +
						", Z " + string(eventAction[3]);
			break
			case (eEventAction.setCameraRoll): label = "21: Set camera roll to " + string(eventAction[1]) + " degrees"; break
			case (eEventAction.setCameraFOV): label = "22: Set camera FOV to " + string(eventAction[1]) + " degrees"; break
			case (eEventAction.setCameraTarget): label = "23: Set camera target to actor" + string(eventAction[1]); break
			case (eEventAction.lerpCamera):
				label = "24: Lerp camera from previous position " + (eventAction[2] ? "smoothly" : "linearly") + 
						" in " + string(eventAction[3]) + 
						"tick(s)"; break
		}
		else switch (eventAction)
		{
			case (eEventAction.waitMessage): label = "1: Wait until message box closes"; break
			case (eEventAction.waitTrigger): label = "2: Wait until player leaves trigger area"; break
			case (eEventAction.restoreCamera): label = "15: Restore camera settings"; break
			case (eEventAction.unlockCameraDirection): label = "19: Unlock camera direction"; break
		}
		ds_list_add(global.levelEventList, label);
	}
}

function pn_event_edit_action(_action)
{
	if (is_array(_action)) switch (_action[0])
	{
		case (eEventAction.wait): _action[1] = pn_get_integer("1 - Wait: Ticks?", _action[1]); break
		case (eEventAction.setRoom): _action[1] = pn_get_integer("3 - Set current room: Room ID?", _action[1]); break
		case (eEventAction.setSkyboxTexture): _action[1] = pn_get_integer("4 - Set skybox texture: Material name?", _action[1]); break
		case (eEventAction.fadeSkyboxColor):
			_action[1] = pn_get_integer("5 - Fade skybox color: BGR color?", _action[1]);
			_action[2] = pn_get_integer("5 - Fade skybox color: Ticks?", _action[2]);
		break
		case (eEventAction.fadeFog):
			_action[1] = pn_get_integer("6 - Fade fog: Start distance?", _action[1]);
			_action[2] = pn_get_integer("6 - Fade fog: End distance?", _action[2]);
			_action[3] = pn_get_integer("6 - Fade fog: BGR color?", _action[3]);
			_action[4] = pn_get_integer("6 - Fade fog: Alpha?", _action[4]);
			_action[5] = pn_get_integer("6 - Fade fog: Ticks?", _action[5]);
		break
		case (eEventAction.fadeLight):
			_action[1] = pn_get_integer("7 - Fade light: X normal?", _action[1]);
			_action[2] = pn_get_integer("7 - Fade light: Y normal?", _action[2]);
			_action[3] = pn_get_integer("7 - Fade light: Z normal?", _action[3]);
			_action[4] = pn_get_integer("7 - Fade light: BGR color?", _action[4]);
			_action[5] = pn_get_integer("7 - Fade light: Alpha?", _action[5]);
			_action[6] = pn_get_integer("7 - Fade light: ambient BGR color?", _action[6]);
			_action[7] = pn_get_integer("7 - Fade light: Ambient alpha?", _action[7]);
			_action[8] = pn_get_integer("7 - Fade light: Ticks?", _action[8]);
		break
		case (eEventAction.triggerEvent): _action[1] = pn_get_integer("8 - Trigger event: Event ID?", _action[1]); break
		case (eEventAction.gotoLevel): _action[1] = pn_get_integer("9 - Go to level: Level ID?", _action[1]); break
		case (eEventAction._message): _action[1] = pn_get_string("10 - Message: Message?\n" + @"\n = new line", _action[1]); break
		case (eEventAction.lockPlayer): _action[1] = pn_show_question("11 - Lock player: Lock player controls?"); break
		case (eEventAction.pauseEvent): _action[1] = pn_get_integer("12 - Pause event: Event ID?\n-1 = all events\n-2 = only level events\n-3 = only non-level events", _action[1]); break
		case (eEventAction.resumeEvent): _action[1] = pn_get_integer("13 - Resume event: Event ID?\n-1 = all events\n-2 = only level events\n-3 = only non-level events", _action[1]); break
		case (eEventAction.stopEvent): _action[1] = pn_get_integer("14 - Stop event: Event ID?\n-1 = all events\n-2 = only level events\n-3 = only non-level events", _action[1]); break
		case (eEventAction.lockCamera): _action[1] = pn_show_question("16 - Lock camera position: Lock camera position?"); break
		case (eEventAction.lockCameraToActor):
			_action[1] = pn_get_integer("17 - Lock camera towards actor: Actor tag?", _action[1]);
			_action[2] = pn_show_question("17 - Lock camera towards actor: Turn smoothly?");
		break
		case (eEventAction.lockCameraToPosition):
			_action[1] = pn_get_integer("18 - Lock camera towards position: X?", _action[1]);
			_action[2] = pn_get_integer("18 - Lock camera towards position: Y?", _action[2]);
			_action[3] = pn_get_integer("18 - Lock camera towards position: Z?", _action[3]);
			_action[4] = pn_show_question("18 - Lock camera towards position: Turn smoothly?");
		break
		case (eEventAction.setCameraPosition):
			_action[1] = pn_get_integer("20 - Set camera position: X?", _action[1]);
			_action[2] = pn_get_integer("20 - Set camera position: Y?", _action[2]);
			_action[3] = pn_get_integer("20 - Set camera position: Z?", _action[3]);
		break
		case (eEventAction.setCameraRoll): _action[1] = pn_get_integer("21 - Set camera roll: Angle?", _action[1]); break
		case (eEventAction.setCameraFOV): _action[1] = pn_get_integer("22 - Set camera FOV: Angle?", _action[1]); break
		case (eEventAction.setCameraTarget): _action[1] = pn_get_integer("23 - Set camera target: Actor tag?", _action[1]); break
		case (eEventAction.lerpCamera):
			_action[1] = pn_show_question("24 - Lock camera towards position: Turn smoothly?");
			_action[2] = pn_get_integer("24 - Lock camera towards position: Ticks?", _action[2]);
		break
	}
}