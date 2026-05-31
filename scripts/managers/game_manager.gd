## game_manager.gd
## Gestiona el flujo del juego: inicio, game over, transiciones, demo end.
## Autoload o nodo raíz de la escena principal.

extends Node

@export var starting_level: PackedScene
@export var game_over_scene: PackedScene
@export var demo_end_scene: PackedScene

var _current_level: Node = null

func _ready() -> void:
	Globals.player_died.connect(_on_player_died)
	Globals.puzzle_solved.connect(_on_puzzle_solved)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _toggle_pause() -> void:
	match Globals.current_state:
		Globals.GameState.PLAYING:
			Globals.change_state(Globals.GameState.PAUSED)
		Globals.GameState.PAUSED:
			Globals.change_state(Globals.GameState.PLAYING)

func _on_player_died() -> void:
	Globals.change_state(Globals.GameState.GAME_OVER)
	# Esperar un momento antes de mostrar game over
	await get_tree().create_timer(2.0).timeout
	_show_game_over()

func _on_puzzle_solved(puzzle_id: String) -> void:
	# Lógica específica de puzzles puede ir aquí
	pass

func _show_game_over() -> void:
	# Crear pantalla de game over simple
	var canvas := CanvasLayer.new()
	canvas.layer = 200
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas)

	var bg := ColorRect.new()
	bg.color = Color(0.1, 0, 0, 0.9)
	bg.anchors_preset = Control.PRESET_FULL_RECT
	canvas.add_child(bg)

	var label := Label.new()
	label.text = "YOU DIED"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchors_preset = Control.PRESET_FULL_RECT
	label.add_theme_font_size_override("font_size", 64)
	label.modulate = Color.RED
	canvas.add_child(label)

	var hint := Label.new()
	hint.text = "Presiona R para reiniciar"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.anchors_preset = Control.PRESET_CENTER_BOTTOM
	hint.position.y = -50
	hint.add_theme_font_size_override("font_size", 20)
	canvas.add_child(hint)

func show_demo_end() -> void:
	Globals.change_state(Globals.GameState.DEMO_END)

	var canvas := CanvasLayer.new()
	canvas.layer = 200
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 1)
	bg.anchors_preset = Control.PRESET_FULL_RECT
	canvas.add_child(bg)

	var label := Label.new()
	label.text = "GRACIAS POR JUGAR\n\nPUEBLO MUERTO\nDEMO"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchors_preset = Control.PRESET_FULL_RECT
	label.add_theme_font_size_override("font_size", 36)
	canvas.add_child(label)

	# Fade in
	bg.modulate.a = 0
	label.modulate.a = 0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(bg, "modulate:a", 1.0, 2.0)
	tween.tween_property(label, "modulate:a", 1.0, 3.0)

func restart_game() -> void:
	Globals.reset_game()
	get_tree().reload_current_scene()
