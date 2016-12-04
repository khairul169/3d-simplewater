tool
extends EditorPlugin

const Water = preload("simple_water.gd");
const WaterType = "Water";

func _enter_tree():
	add_custom_type(WaterType, "Quad", Water, preload("icon.png"));

func _exit_tree():
	remove_custom_type(WaterType);


