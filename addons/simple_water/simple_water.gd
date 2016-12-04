tool
extends Quad

export(NodePath) var environmentNode;
export(Color) var waterColor = Color(0.4, 0.5, 0.6, 0.2) setget _set_color, _get_color;
export(float, 0.1, 100.0, 1.0) var waterTiling = 1.0 setget _set_tiling, _get_tiling;
export(float, 0.01, 0.1, 0.01) var waveStrength = 0.01 setget _set_strength, _get_strength;
export(ImageTexture) var waterDudvMap = load("res://addons/simple_water/textures/waterDUDV.png") setget _set_dudv, _get_dudv;
export(int, 1, 8, 1) var waterQuality = 1;
export(float, 0.0, 1.0, 0.1) var refractiveFactor = 0.5 setget _set_refractFactor, _get_refractFactor;

var basevp;
var mat;
var reflection;
var reflection_cam;
var refraction;
var refraction_cam;

func _init():
	set_axis(Vector3.AXIS_Y);
	update();

func update():
	mat = get_material_override();
	
	if (!mat):
		mat = ShaderMaterial.new();
		mat.set_shader(load("res://addons/simple_water/shader.tres"));
		set_material_override(mat);
	
	mat.set_shader_param("waterTint", waterColor);
	mat.set_shader_param("waterTiling", waterTiling);
	mat.set_shader_param("waterDistortion", waveStrength);
	mat.set_shader_param("dudvMap", waterDudvMap);
	mat.set_shader_param("refractiveFactor", refractiveFactor);

func _ready():
	basevp = get_viewport();
	
	for i in get_children():
		i.queue_free();
	
	# Creating render viewport
	if (!reflection):
		reflection = Viewport.new();
		reflection.set_as_render_target(true);
		reflection.set_use_own_world(true);
		reflection.set_render_target_filter(true);
		reflection.set_render_target_gen_mipmaps(true);
		reflection.set_rect(Rect2(Vector2(), basevp.get_rect().size/waterQuality));
		add_child(reflection);
	
	if (!refraction):
		refraction = Viewport.new();
		refraction.set_as_render_target(true);
		refraction.set_use_own_world(true);
		refraction.set_render_target_filter(true);
		refraction.set_render_target_gen_mipmaps(true);
		refraction.set_rect(Rect2(Vector2(), basevp.get_rect().size/waterQuality));
		refraction.set_render_target_vflip(true);
		add_child(refraction);
	
	# Creating camera
	if (!reflection_cam):
		reflection_cam = Camera.new();
		reflection.add_child(reflection_cam);
	
	if (!refraction_cam):
		refraction_cam = Camera.new();
		refraction.add_child(refraction_cam);
	
	# Adding level instance
	if (environmentNode != null && typeof(environmentNode) == TYPE_NODE_PATH):
		var envNode = get_node(environmentNode);
		
		envNode = envNode.duplicate();
		reflection.add_child(envNode);
		
		envNode = envNode.duplicate();
		refraction.add_child(envNode);
	
	set_fixed_process(true);

func _fixed_process(delta):
	if (!basevp):
		return;
	
	var baseCamera = basevp.get_camera();
	if (!baseCamera):
		return;
	
	var trans = baseCamera.get_global_transform();
	var waterHeight = get_global_transform().origin.y;
	
	var reflectionTrans = trans;
	var lookDir = trans.basis[2];
	lookDir.y = -lookDir.y;
	
	reflectionTrans = reflectionTrans.looking_at(trans.origin-lookDir, Vector3(0,1,0));
	reflectionTrans.origin = trans.origin;
	reflectionTrans.origin.y *= -1;
	reflectionTrans.origin.y += waterHeight*2;
	
	reflection_cam.set_global_transform(reflectionTrans);
	
	var refractionTrans = trans;
	refraction_cam.set_global_transform(refractionTrans);
	
	var reflectTex = reflection.get_render_target_texture();
	var refractTex = refraction.get_render_target_texture();
	
	mat.set_shader_param("reflectionTex", reflectTex);
	mat.set_shader_param("refractionTex", refractTex);

func _set_strength(new):
	waveStrength = new;
	update();

func _get_strength():
	return waveStrength;

func _set_tiling(new):
	waterTiling = new;
	update();

func _get_tiling():
	return waterTiling;

func _set_color(new):
	waterColor = new;
	update();

func _get_color():
	return waterColor;

func _set_dudv(new):
	waterDudvMap = new;
	update();

func _get_dudv():
	return waterDudvMap;

func _set_refractFactor(new):
	refractiveFactor = new;
	update();

func _get_refractFactor():
	return refractiveFactor;
