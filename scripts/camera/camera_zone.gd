## camera_zone.gd
## Zona que activa una cámara fija cuando el jugador entra.
## Nodo: Area3D con CollisionShape3D (box grande cubriendo la zona)
##
## Estructura:
##   Area3D (este script)
##   ├── CollisionShape3D (zona de activación)
##   └── Camera3D (la cámara fija de esta zona)

extends Area3D

@export var zone_name: String = "zona_default"
@export var camera_sway: bool = true
@export var sway_amount: float = 0.02
@export var sway_speed: float = 0.5

var _camera: Camera3D = null
var _camera_system: Node3D = null
var _original_camera_pos: Vector3
var _time: float = 0.0

func _ready() -> void:
	# Buscar la cámara hija
	for child in get_children():
		if child is Camera3D:
			_camera = child
			_original_camera_pos = _camera.position
			break

	# Buscar el camera system (padre)
	_camera_system = get_parent()

	# Conectar señales de entrada/salida
	body_entered.connect(_on_body_entered)

	# Configurar para detectar solo al jugador (Layer 1)
	collision_layer = 0
	collision_mask = 0b0001  # Layer 1: Player

func _process(delta: float) -> void:
	# Sway cinematográfico sutil
	if camera_sway and _camera and _camera.current:
		_time += delta * sway_speed
		_camera.position = _original_camera_pos + Vector3(
			sin(_time) * sway_amount,
			cos(_time * 0.7) * sway_amount * 0.5,
			0
		)

func get_camera() -> Camera3D:
	return _camera

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and _camera_system and _camera:
		# El jugador entró en esta zona
		Globals.zone_entered.emit(zone_name)
		if _camera_system.has_method("switch_to_camera"):
			_camera_system.switch_to_camera(_camera)
