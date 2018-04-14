tool
extends EditorPlugin

const Water = preload("simple_water.gd");
const WaterType = "Water";

func _enter_tree():
	print('hi_there')
	add_custom_type(WaterType, "MeshInstance", Water, preload("icon.png"));

func _exit_tree():
	remove_custom_type(WaterType);


