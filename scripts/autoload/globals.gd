## globals.gd — Autoload singleton
## Gestiona estado global, señales y datos persistentes del juego.
## Añadir como Autoload en Project Settings → Autoload con nombre "Globals"

extends Node

# === SEÑALES GLOBALES ===
signal item_picked_up(item_data: ItemData)
signal item_used(item_data: ItemData)
signal player_damaged(amount: int)
signal player_healed(amount: int)
signal player_died
signal enemy_killed(enemy: Node3D)
signal camera_changed(camera: Camera3D)
signal zone_entered(zone_name: String)
signal puzzle_solved(puzzle_id: String)
signal game_paused(is_paused: bool)
signal inventory_toggled(is_open: bool)
signal dialog_shown(text: String)

# === ESTADO DEL JUEGO ===
enum GameState { PLAYING, PAUSED, INVENTORY, CUTSCENE, GAME_OVER, DEMO_END }
var current_state: GameState = GameState.PLAYING

# === DATOS DEL JUGADOR ===
var player_health: int = 100
var player_max_health: int = 100
var player_ammo_pistol: int = 0

# === PUZZLES RESUELTOS ===
var solved_puzzles: Array[String] = []

# === ITEMS RECOGIDOS (para no respawnear) ===
var collected_item_ids: Array[String] = []

# === ENEMIGOS ELIMINADOS ===
var killed_enemy_ids: Array[String] = []

# === CONFIGURACIÓN PSX ===
var psx_resolution := Vector2i(320, 240)
var psx_vertex_snap_intensity: float = 0.5

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func change_state(new_state: GameState) -> void:
	current_state = new_state
	match new_state:
		GameState.PLAYING:
			get_tree().paused = false
			game_paused.emit(false)
		GameState.PAUSED, GameState.INVENTORY:
			get_tree().paused = true
			game_paused.emit(true)
		GameState.CUTSCENE:
			get_tree().paused = false
		GameState.GAME_OVER, GameState.DEMO_END:
			get_tree().paused = true

func is_playing() -> bool:
	return current_state == GameState.PLAYING

func damage_player(amount: int) -> void:
	player_health = clampi(player_health - amount, 0, player_max_health)
	player_damaged.emit(amount)
	if player_health <= 0:
		player_died.emit()
		change_state(GameState.GAME_OVER)

func heal_player(amount: int) -> void:
	player_health = clampi(player_health + amount, 0, player_max_health)
	player_healed.emit(amount)

func mark_item_collected(item_id: String) -> void:
	if item_id not in collected_item_ids:
		collected_item_ids.append(item_id)

func is_item_collected(item_id: String) -> bool:
	return item_id in collected_item_ids

func mark_puzzle_solved(puzzle_id: String) -> void:
	if puzzle_id not in solved_puzzles:
		solved_puzzles.append(puzzle_id)
		puzzle_solved.emit(puzzle_id)

func is_puzzle_solved(puzzle_id: String) -> bool:
	return puzzle_id in solved_puzzles

func mark_enemy_killed(enemy_id: String) -> void:
	if enemy_id not in killed_enemy_ids:
		killed_enemy_ids.append(enemy_id)

func is_enemy_killed(enemy_id: String) -> bool:
	return enemy_id in killed_enemy_ids

func reset_game() -> void:
	player_health = player_max_health
	player_ammo_pistol = 0
	solved_puzzles.clear()
	collected_item_ids.clear()
	killed_enemy_ids.clear()
	change_state(GameState.PLAYING)
