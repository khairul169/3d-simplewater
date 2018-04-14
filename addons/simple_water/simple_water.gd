tool
extends MeshInstance

export(Color) var waterColor = Color(0.4, 0.5, 0.6, 0.2) setget _set_color
export(float, 0.1, 100.0, 0.1) var waterTiling = 0.3 setget _set_tiling
export(float, 0.0, 100.0, 0.01) var waterDensity = 1.0 setget _set_density
export(float, 0.01, 0.1, 0.01) var waveStrength = 0.01 setget _set_strength
export(ImageTexture) var waterDudvMap = preload("res://addons/simple_water/textures/waterDUDV.png") setget _set_dudv
export(float, 0.0, 2.0, 0.1) var refractiveFactor = 0.5 setget _set_refractFactor

onready var basevp = get_node('/root')
var mat
var reflection
var reflection_cam

func _init():
	mesh = PlaneMesh.new()
	update()

func update():
	
	mat = get_material_override()
	if (!mat):
		mat = preload("res://addons/simple_water/water_shader.tres")
		set_material_override(mat)
	
	mat.set_shader_param("waterTint", waterColor)
	mat.set_shader_param("waterTiling", waterTiling)
	mat.set_shader_param("fogDensity", waterDensity)
	mat.set_shader_param("waterDistortion", waveStrength)
	mat.set_shader_param("dudvMap", waterDudvMap)
	mat.set_shader_param("refractiveFactor", refractiveFactor)

func _ready():
	for i in get_children():
		i.queue_free()
	
	# Creating render viewport
	if (!reflection):
		reflection = Viewport.new()
		reflection.size = basevp.size / 2.0
		reflection.render_target_v_flip = true
		#reflection.debug_draw = Viewport.DEBUG_DRAW_UNSHADED
		add_child(reflection)
	
	# Creating camera
	if (!reflection_cam):
		reflection_cam = Camera.new()
		reflection.add_child(reflection_cam)
	
	var reflectTex = reflection.get_texture()
	reflectTex.flags = Texture.FLAG_FILTER
	mat.set_shader_param("reflectionTex", reflectTex)
	
	set_process(true)

func _process(delta):
	if (!basevp):
		return
	
	var baseCamera = basevp.get_camera()
	if (!baseCamera):
		return
	
	var trans = baseCamera.get_global_transform()
	var waterHeight = get_global_transform().origin.y
	
	var reflectionTrans = trans
	var lookDir = trans.basis[2]
	lookDir.y = -lookDir.y
	
	reflectionTrans = reflectionTrans.looking_at(trans.origin-lookDir, Vector3(0,1,0))
	reflectionTrans.origin = trans.origin
	reflectionTrans.origin.y *= -1
	reflectionTrans.origin.y += waterHeight*2
	
	reflection_cam.set_global_transform(reflectionTrans)

func _physics_process(delta):
	_process(delta)

func _set_strength(new):
	waveStrength = new
	update()

func _set_density(new):
	waterDensity = new
	update()

func _set_tiling(new):
	waterTiling = new
	update()

func _set_color(new):
	waterColor = new
	update()

func _set_dudv(new):
	waterDudvMap = new
	update()

func _set_refractFactor(new):
	refractiveFactor = new
	update()
