## inventory_ui.gd
## Pantalla de inventario estilo Resident Evil con grid 4x2.
## Se superpone al juego y pausa la acción.
##
## Estructura:
##   CanvasLayer (layer 50)
##   └── Control (este script)
##       ├── Background (ColorRect semitransparente)
##       ├── InventoryPanel (PanelContainer)
##       │   ├── Title (Label "INVENTARIO")
##       │   └── GridContainer (4 columnas)
##       │       └── 8x SlotButton (TextureButton o Button)
##       ├── ItemInfo (PanelContainer)
##       │   ├── ItemName (Label)
##       │   ├── ItemDescription (RichTextLabel)
##       │   └── ButtonsContainer
##       │       ├── UseButton
##       │       ├── CombineButton
##       │       └── ExamineButton
##       └── PromptLabel (Label inferior)

extends Control

@export var inventory: InventoryManager
@export var slot_size: Vector2 = Vector2(64, 64)

var _selected_slot: int = -1
var _combine_mode: bool = false
var _combine_first_slot: int = -1
var _slot_buttons: Array[Button] = []

# Referencias UI
@onready var grid_container: GridContainer = $InventoryPanel/GridContainer
@onready var item_name_label: Label = $ItemInfo/ItemName
@onready var item_desc_label: RichTextLabel = $ItemInfo/ItemDescription
@onready var use_button: Button = $ItemInfo/ButtonsContainer/UseButton
@onready var combine_button: Button = $ItemInfo/ButtonsContainer/CombineButton
@onready var examine_button: Button = $ItemInfo/ButtonsContainer/ExamineButton
@onready var prompt_label: Label = $PromptLabel

func _ready() -> void:
	# Configurar grid
	grid_container.columns = InventoryManager.GRID_COLS

	# Crear botones de slot
	for i in range(InventoryManager.MAX_SLOTS):
		var btn := Button.new()
		btn.custom_minimum_size = slot_size
		btn.text = ""
		btn.pressed.connect(_on_slot_pressed.bind(i))
		btn.focus_mode = Control.FOCUS_ALL
		grid_container.add_child(btn)
		_slot_buttons.append(btn)

	# Conectar botones de acción
	use_button.pressed.connect(_on_use_pressed)
	combine_button.pressed.connect(_on_combine_pressed)
	examine_button.pressed.connect(_on_examine_pressed)

	# Escuchar señales
	Globals.inventory_toggled.connect(_on_inventory_toggled)
	if inventory:
		inventory.inventory_changed.connect(_refresh_display)

	# Inicialmente oculto
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_clear_item_info()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("inventory_toggle") or event.is_action_pressed("ui_cancel"):
		_close_inventory()
		get_viewport().set_input_as_handled()

func _on_inventory_toggled(is_open: bool) -> void:
	if is_open:
		_open_inventory()
	else:
		_close_inventory()

func _open_inventory() -> void:
	visible = true
	_selected_slot = -1
	_combine_mode = false
	_refresh_display()
	_clear_item_info()
	prompt_label.text = "TAB para cerrar"
	# Dar foco al primer slot
	if _slot_buttons.size() > 0:
		_slot_buttons[0].grab_focus()

func _close_inventory() -> void:
	visible = false
	_combine_mode = false
	Globals.change_state(Globals.GameState.PLAYING)
	Globals.inventory_toggled.emit(false)

func _refresh_display() -> void:
	if inventory == null:
		return

	for i in range(InventoryManager.MAX_SLOTS):
		var slot_data := inventory.get_slot(i)
		var btn := _slot_buttons[i]

		if slot_data.is_empty():
			btn.text = "---"
			btn.modulate = Color(0.5, 0.5, 0.5, 0.5)
		else:
			var item: ItemData = slot_data["item"]
			var qty: int = slot_data["quantity"]
			btn.text = item.item_name
			if item.stackable and qty > 1:
				btn.text += " x" + str(qty)
			btn.modulate = Color.WHITE

		# Highlight del slot seleccionado
		if i == _selected_slot:
			btn.modulate = Color(1, 1, 0)  # Amarillo
		elif _combine_mode and i == _combine_first_slot:
			btn.modulate = Color(0, 1, 1)  # Cian

func _on_slot_pressed(slot_index: int) -> void:
	if inventory == null:
		return

	var slot_data := inventory.get_slot(slot_index)

	if _combine_mode:
		# Segundo slot para combinar
		if slot_index != _combine_first_slot and not slot_data.is_empty():
			var success := inventory.combine_items(_combine_first_slot, slot_index)
			if success:
				prompt_label.text = "¡Items combinados!"
			else:
				prompt_label.text = "No se pueden combinar estos items."
			_combine_mode = false
			_selected_slot = -1
			_refresh_display()
			_clear_item_info()
		return

	if slot_data.is_empty():
		_selected_slot = -1
		_clear_item_info()
		_refresh_display()
		return

	_selected_slot = slot_index
	_show_item_info(slot_data["item"])
	_refresh_display()

func _show_item_info(item: ItemData) -> void:
	item_name_label.text = item.item_name
	item_desc_label.text = item.description

	# Mostrar/ocultar botones según tipo
	use_button.visible = item.type == ItemData.ItemType.HEALING
	combine_button.visible = item.combine_with_id != ""
	examine_button.visible = true

	prompt_label.text = "Selecciona una acción"

func _clear_item_info() -> void:
	item_name_label.text = ""
	item_desc_label.text = "Selecciona un item"
	use_button.visible = false
	combine_button.visible = false
	examine_button.visible = false

func _on_use_pressed() -> void:
	if _selected_slot >= 0 and inventory:
		inventory.use_item_at(_selected_slot)
		_selected_slot = -1
		_refresh_display()
		_clear_item_info()
		prompt_label.text = "Item usado."

func _on_combine_pressed() -> void:
	_combine_mode = true
	_combine_first_slot = _selected_slot
	prompt_label.text = "Selecciona el segundo item para combinar..."
	_refresh_display()

func _on_examine_pressed() -> void:
	if _selected_slot >= 0 and inventory:
		var slot_data := inventory.get_slot(_selected_slot)
		if not slot_data.is_empty():
			var item: ItemData = slot_data["item"]
			prompt_label.text = item.description
