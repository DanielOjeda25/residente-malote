## hud.gd
## Interfaz en pantalla: vida, munición, prompts de interacción, mensajes.
## Nodo: CanvasLayer → Control
##
## Estructura:
##   CanvasLayer
##   └── Control (este script)
##       ├── HealthBar (ProgressBar o TextureProgressBar)
##       ├── AmmoLabel (Label)
##       ├── InteractPrompt (Label, centro-inferior)
##       └── MessageBox (PanelContainer con Label, para diálogos)

extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var ammo_label: Label = $AmmoLabel
@onready var interact_prompt: Label = $InteractPrompt
@onready var message_box: PanelContainer = $MessageBox
@onready var message_label: Label = $MessageBox/MessageLabel

var _message_timer: float = 0.0
var _showing_message: bool = false

func _ready() -> void:
	# Conectar señales globales
	Globals.player_damaged.connect(_on_player_damaged)
	Globals.player_healed.connect(_on_player_healed)
	Globals.dialog_shown.connect(_on_dialog_shown)
	Globals.game_paused.connect(_on_game_paused)

	# Inicializar
	health_bar.max_value = Globals.player_max_health
	health_bar.value = Globals.player_health
	interact_prompt.visible = false
	message_box.visible = false
	_update_ammo()

func _process(delta: float) -> void:
	# Actualizar HUD cada frame
	_update_health()
	_update_ammo()
	_update_interact_prompt()
	_update_message(delta)

func _update_health() -> void:
	health_bar.value = Globals.player_health

	# Cambiar color según vida
	var health_pct := float(Globals.player_health) / float(Globals.player_max_health)
	if health_pct > 0.5:
		health_bar.modulate = Color.GREEN
	elif health_pct > 0.25:
		health_bar.modulate = Color.YELLOW
	else:
		health_bar.modulate = Color.RED

func _update_ammo() -> void:
	ammo_label.text = "AMMO: " + str(Globals.player_ammo_pistol)

func _update_interact_prompt() -> void:
	# Mostrar prompt si hay un interactable cercano (proximidad, no rayo)
	var player := get_tree().get_first_node_in_group("player")
	if player == null or not player.has_method("get_nearest_interactable"):
		interact_prompt.visible = false
		return

	var target: Node3D = player.get_nearest_interactable()
	if target and target.has_method("get_interact_prompt"):
		var prompt_text: String = target.get_interact_prompt()
		if prompt_text != "":
			interact_prompt.text = "[E] " + prompt_text
			interact_prompt.visible = true
			return

	interact_prompt.visible = false

func _update_message(delta: float) -> void:
	if _showing_message:
		_message_timer -= delta
		if _message_timer <= 0:
			_hide_message()

func _on_dialog_shown(text: String) -> void:
	_show_message(text, 3.0)

func _show_message(text: String, duration: float = 3.0) -> void:
	message_label.text = text
	message_box.visible = true
	_message_timer = duration
	_showing_message = true

func _hide_message() -> void:
	message_box.visible = false
	_showing_message = false

func _on_player_damaged(_amount: int) -> void:
	# Flash rojo de daño
	var flash := ColorRect.new()
	flash.color = Color(1, 0, 0, 0.3)
	flash.anchors_preset = Control.PRESET_FULL_RECT
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)

	var tween := create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.3)
	await tween.finished
	flash.queue_free()

func _on_player_healed(_amount: int) -> void:
	pass  # Podría añadir efecto visual de curación

func _on_game_paused(is_paused: bool) -> void:
	visible = not is_paused  # Ocultar HUD en inventario/pausa
