## pickup.gd
## Item que el jugador puede recoger. Se coloca en el mundo.
## Nodo: Area3D (o StaticBody3D)
##
## Estructura:
##   StaticBody3D (este script)
##   ├── CollisionShape3D
##   ├── MeshInstance3D (modelo visual del item)
##   └── InteractArea (Area3D, para highlight)

extends StaticBody3D

@export var item_resource: ItemData
@export var pickup_id: String = ""  # ID único para persistencia
@export var quantity: int = 1
@export var examine_text: String = "Has encontrado un objeto."
@export var bob_animation: bool = true
@export var bob_height: float = 0.1
@export var bob_speed: float = 2.0
@export var glow_color: Color = Color(1, 1, 0.5, 0.8)

var _original_y: float = 0.0
var _time: float = 0.0
var _mesh: MeshInstance3D = null

func _ready() -> void:
	# Verificar si ya fue recogido
	if pickup_id != "" and Globals.is_item_collected(pickup_id):
		queue_free()
		return

	# Configurar colisiones para interacción
	collision_layer = 0b1000  # Layer 4: Interactables
	collision_mask = 0

	_original_y = position.y

	# Referencia al mesh
	if has_node("MeshInstance3D"):
		_mesh = $MeshInstance3D

	# Añadir al grupo de interactables
	add_to_group("interactable")

func _process(delta: float) -> void:
	if bob_animation:
		_time += delta * bob_speed
		position.y = _original_y + sin(_time) * bob_height

func interact(player: CharacterBody3D) -> void:
	if item_resource == null:
		push_warning("Pickup sin item_resource asignado: " + name)
		return

	# Intentar añadir al inventario del jugador
	var inventory: InventoryManager = player.get_node_or_null("InventoryManager")
	if inventory == null:
		inventory = get_tree().get_first_node_in_group("inventory")

	if inventory and inventory.add_item(item_resource, quantity):
		# Éxito — marcar como recogido y eliminar
		if pickup_id != "":
			Globals.mark_item_collected(pickup_id)

		# Mostrar texto
		Globals.dialog_shown.emit(examine_text)

		# Efecto de desaparición
		_disappear()
	else:
		# Inventario lleno
		Globals.dialog_shown.emit("No hay espacio en el inventario.")

func _disappear() -> void:
	# Breve animación de recogida
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector3.ZERO, 0.2)
	if _mesh:
		tween.tween_property(_mesh, "transparency", 1.0, 0.2)
	await tween.finished
	queue_free()

func get_interact_prompt() -> String:
	if item_resource:
		return "Recoger " + item_resource.item_name
	return "Recoger"
