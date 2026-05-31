## fixed_camera_system.gd
## Gestiona las cámaras fijas del nivel y transiciones entre ellas.
## Colocar en un nodo raíz del nivel que contenga todas las CameraZone.
##
## Estructura:
##   Node3D (este script)
##   ├── CameraZone_Plaza (Area3D con camera_zone.gd)
##   │   └── Camera3D
##   ├── CameraZone_Callejon (Area3D con camera_zone.gd)
##   │   └── Camera3D
##   └── ... más zonas

extends Node3D

@export var fade_duration: float = 0.4
@export var initial_camera_index: int = 0

var _cameras: Array[Camera3D] = []
var _active_camera: Camera3D = null
var _fade_overlay: ColorRect = null
var _is_transitioning: bool = false

func _ready() -> void:
	# Recoger todas las cámaras de las zonas hijas
	for child in get_children():
		if child is Area3D and child.has_method("get_camera"):
			var cam: Camera3D = child.get_camera()
			if cam:
				_cameras.append(cam)
				cam.current = false

	# Crear overlay de fade (Canvas Layer)
	_create_fade_overlay()

	# Activar cámara inicial
	if _cameras.size() > initial_camera_index:
		_activate_camera_immediate(_cameras[initial_camera_index])

func _create_fade_overlay() -> void:
	var canvas_layer := CanvasLayer.new()
	canvas_layer.layer = 100
	canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas_layer)

	_fade_overlay = ColorRect.new()
	_fade_overlay.color = Color(0, 0, 0, 0)
	_fade_overlay.anchors_preset = Control.PRESET_FULL_RECT
	_fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(_fade_overlay)

func switch_to_camera(camera: Camera3D) -> void:
	if camera == _active_camera:
		return
	if _is_transitioning:
		return
	_is_transitioning = true
	await _fade_transition(camera)
	_is_transitioning = false

func _fade_transition(new_camera: Camera3D) -> void:
	# Fade out
	var tween := create_tween()
	tween.tween_property(_fade_overlay, "color:a", 1.0, fade_duration * 0.5)
	await tween.finished

	# Cambiar cámara
	_activate_camera_immediate(new_camera)

	# Fade in
	tween = create_tween()
	tween.tween_property(_fade_overlay, "color:a", 0.0, fade_duration * 0.5)
	await tween.finished

func _activate_camera_immediate(camera: Camera3D) -> void:
	if _active_camera:
		_active_camera.current = false
	_active_camera = camera
	_active_camera.current = true
	Globals.camera_changed.emit(_active_camera)

func get_active_camera() -> Camera3D:
	return _active_camera
