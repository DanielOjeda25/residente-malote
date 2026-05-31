## inventory_manager.gd
## Sistema de inventario grid 4x2 estilo Resident Evil.
## Autoload o adjunto al jugador.

extends Node
class_name InventoryManager

signal inventory_changed
signal item_added(item: ItemData, slot: int)
signal item_removed(item: ItemData, slot: int)
signal item_combined(item_a: ItemData, item_b: ItemData, result: ItemData)
signal inventory_full

const MAX_SLOTS: int = 8
const GRID_COLS: int = 4
const GRID_ROWS: int = 2

# Cada slot: { "item": ItemData, "quantity": int } o null
var slots: Array = []

# Base de datos de items (cargar resources)
var _item_database: Dictionary = {}

func _ready() -> void:
	# Inicializar slots vacíos
	slots.resize(MAX_SLOTS)
	for i in range(MAX_SLOTS):
		slots[i] = null

	# Cargar base de datos de items
	_load_item_database()

func _load_item_database() -> void:
	var items_path := "res://resources/items/"
	var dir := DirAccess.open(items_path)
	if dir == null:
		push_warning("No se encontró el directorio de items: " + items_path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var item: ItemData = load(items_path + file_name)
			if item:
				_item_database[item.item_id] = item
		file_name = dir.get_next()
	dir.list_dir_end()

func get_item_data(item_id: String) -> ItemData:
	return _item_database.get(item_id, null)

# === OPERACIONES DE INVENTARIO ===

func add_item(item: ItemData, quantity: int = 1) -> bool:
	# Si es stackable, buscar slot existente
	if item.stackable:
		for i in range(MAX_SLOTS):
			if slots[i] != null and slots[i]["item"].item_id == item.item_id:
				var current_qty: int = slots[i]["quantity"]
				if current_qty < item.max_stack:
					slots[i]["quantity"] = mini(current_qty + quantity, item.max_stack)
					item_added.emit(item, i)
					inventory_changed.emit()
					return true

	# Buscar slot vacío
	for i in range(MAX_SLOTS):
		if slots[i] == null:
			slots[i] = { "item": item, "quantity": quantity }
			item_added.emit(item, i)
			inventory_changed.emit()
			Globals.item_picked_up.emit(item)
			return true

	# Inventario lleno
	inventory_full.emit()
	return false

func remove_item_at(slot_index: int) -> ItemData:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return null
	if slots[slot_index] == null:
		return null

	var item: ItemData = slots[slot_index]["item"]
	slots[slot_index] = null
	item_removed.emit(item, slot_index)
	inventory_changed.emit()
	return item

func remove_item_by_id(item_id: String, quantity: int = 1) -> bool:
	for i in range(MAX_SLOTS):
		if slots[i] != null and slots[i]["item"].item_id == item_id:
			if slots[i]["quantity"] <= quantity:
				slots[i] = null
			else:
				slots[i]["quantity"] -= quantity
			inventory_changed.emit()
			return true
	return false

func use_item_at(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return false
	if slots[slot_index] == null:
		return false

	var item: ItemData = slots[slot_index]["item"]

	match item.type:
		ItemData.ItemType.HEALING:
			Globals.heal_player(item.heal_amount)
			remove_item_at(slot_index)
			Globals.item_used.emit(item)
			return true
		ItemData.ItemType.AMMO:
			# La munición se usa automáticamente al recargar
			return false
		ItemData.ItemType.KEY_ITEM:
			# Los items clave se usan contextualmente
			return false
		ItemData.ItemType.WEAPON:
			# Equipar arma — gestionar desde weapon manager
			return false

	return false

func combine_items(slot_a: int, slot_b: int) -> bool:
	if slots[slot_a] == null or slots[slot_b] == null:
		return false

	var item_a: ItemData = slots[slot_a]["item"]
	var item_b: ItemData = slots[slot_b]["item"]

	# Verificar si se pueden combinar
	var result_id := ""
	if item_a.combine_with_id == item_b.item_id:
		result_id = item_a.combine_result_id
	elif item_b.combine_with_id == item_a.item_id:
		result_id = item_b.combine_result_id

	if result_id == "":
		return false

	var result_item := get_item_data(result_id)
	if result_item == null:
		return false

	# Combinar: eliminar ambos, añadir resultado
	remove_item_at(slot_a)
	# Ajustar índice si slot_b > slot_a (ya que removimos uno)
	remove_item_at(slot_b)
	add_item(result_item)
	item_combined.emit(item_a, item_b, result_item)
	return true

func has_item(item_id: String) -> bool:
	for slot in slots:
		if slot != null and slot["item"].item_id == item_id:
			return true
	return false

func get_item_count(item_id: String) -> int:
	var count := 0
	for slot in slots:
		if slot != null and slot["item"].item_id == item_id:
			count += slot["quantity"]
	return count

func get_slot(index: int) -> Dictionary:
	if index < 0 or index >= MAX_SLOTS or slots[index] == null:
		return {}
	return slots[index]

func is_full() -> bool:
	for slot in slots:
		if slot == null:
			return true
	return false
