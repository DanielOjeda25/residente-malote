## door.gd
## Puerta interactable — puede requerir llave.
##
## Estructura:
##   StaticBody3D (este script)
##   ├── CollisionShape3D (colisión física)
##   ├── MeshInstance3D (modelo de la puerta)
##   └── InteractArea (opcional)

extends StaticBody3D

@export var door_id: String = "door_01"
@export var required_key_id: String = ""  # Dejar vacío si no requiere llave
@export var locked_message: String = "Está cerrada con llave..."
@export var open_message: String = ""
@export var consumes_key: bool = true  # ¿Se consume la llave al usarla?
@export var target_scene: String = ""  # Ruta a escena destino (si es transición)
@export var open_angle: float = 90.0
@export var open_speed: float = 2.0

var _is_locked: bool = true
var _is_open: bool = false
var _is_animating: bool = false
var _original_rotation: float = 0.0

func _ready() -> void:
	_is_locked = required_key_id != ""
	_original_rotation = rotation_degrees.y
	collision_layer = 0b1010  # Layer 2 (Environment) + Layer 4 (Interactable)
	collision_mask = 0
	add_to_group("interactable")

func interact(player: CharacterBody3D) -> void:
	if _is_animating:
		return

	if _is_open:
		_close_door()
		return

	if _is_locked:
		_try_unlock(player)
	else:
		_open_door()

func _try_unlock(player: CharacterBody3D) -> void:
	if required_key_id == "":
		_is_locked = false
		_open_door()
		return

	# Buscar la llave en el inventario del jugador
	var inventory: InventoryManager = player.get_node_or_null("InventoryManager")
	if inventory == null:
		inventory = get_tree().get_first_node_in_group("inventory")

	if inventory and inventory.has_item(required_key_id):
		# Tiene la llave
		_is_locked = false
		if consumes_key:
			inventory.remove_item_by_id(required_key_id)
		if open_message != "":
			Globals.dialog_shown.emit(open_message)
		else:
			Globals.dialog_shown.emit("Has usado la llave.")
		_open_door()
	else:
		# No tiene la llave
		Globals.dialog_shown.emit(locked_message)

func _open_door() -> void:
	_is_animating = true
	_is_open = true

	# Animación de apertura
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "rotation_degrees:y",
		_original_rotation + open_angle, 1.0 / open_speed)
	await tween.finished

	_is_animating = false

	# Desactivar colisión para que el jugador pueda pasar
	collision_layer = 0
	collision_mask = 0

func _close_door() -> void:
	_is_animating = true

	# Reactivar colisión (estaba desactivada al abrir): Env (Layer 2) + Interactable (Layer 4)
	collision_layer = 0b1010
	collision_mask = 0

	# Animación de cierre (vuelve a la rotación original)
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "rotation_degrees:y",
		_original_rotation, 1.0 / open_speed)
	await tween.finished

	_is_open = false
	_is_animating = false
	Globals.dialog_shown.emit("Cierras la puerta.")

func get_interact_prompt() -> String:
	if _is_locked:
		return "Puerta cerrada con llave"
	elif _is_open:
		return "Cerrar puerta"
	return "Abrir puerta"
