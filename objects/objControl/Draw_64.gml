/// @description Draw GUI
draw_rectangle(0, 0, 511, global.windowHeightPrevious, false);
global.ui.Render();
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(512, 0, "X: " + string(global.cursorX) + "\nY: " + string(global.cursorY) + "\nZ: " + string(global.floorZ));