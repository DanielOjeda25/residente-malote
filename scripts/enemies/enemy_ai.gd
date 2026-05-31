## enemy_ai.gd
## IA de enemigo humano hostil: patrulla → persecución → ataque.
## Nodo raíz: CharacterBody3D
##
## Estructura:
##   CharacterBody3D (este script)
##   ├── CollisionShape3D (cápsula)
##   ├── MeshInstance3D (placeholder)
##   ├── NavigationAgent3D
##   ├── DetectionArea (Area3D — cono de visión simplificado)
##   │   └── CollisionShape3D (esfera grande)
##   ├── AttackArea (Area3D — rango melee)
##   │   └── CollisionShape3D (esfera pequeña)
##   └── AnimationPlayer (opcional)

extends CharacterBody3D

# === EXPORTABLES ===
@export var enemy_id: String = "enemy_01"

@export_group("Stats")
@export var max_health: int = 50
@export var attack_damage: int = 15
@export var attack_cooldown: float = 1.5

@export_group("Movement")
@export var patrol_speed: float = 1.0
@export var chase_speed: float = 2.5
@export var rotation_speed: float = 5.0
@export var gravity: float = 9.8

@export_group("Detection")
@export var detection_range: float = 8.0
@export var lose_sight_range: float = 12.0
@export var field_of_view: float = 120.0  # Grados

@export_group("Patrol")
@export var patrol_points: Array[Marker3D] = []
@export var patrol_wait_time: float = 2.0

# === ESTADOS ===
enum State { IDLE, PATROL, CHASE, ATTACK, DAMAGED, DEAD }
var current_state: State = State.IDLE

# === VARIABLES INTERNAS ===
var _health: int = 0
var _player: CharacterBody3D = null
var _current_patrol_index: int = 0
var _patrol_wait_timer: float = 0.0
var _attack_timer: float = 0.0
var _can_attack: bool = true
var _is_dead: bool = false

# === REFERENCIAS ===
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $DetectionArea
@onready var attack_area: Area3D = $AttackArea

func _ready() -> void:
	_health = max_health

	# Verificar si este enemigo ya fue eliminado
	if Globals.is_enemy_killed(enemy_id):
		queue_free()
		return

	# Configurar navegación
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 1.0

	# Buscar al jugador
	_player = get_tree().get_first_node_in_group("player")

	# Iniciar patrulla si hay puntos
	if patrol_points.size() > 0:
		_change_state(State.PATROL)
		_set_patrol_target()
	else:
		_change_state(State.IDLE)

	# Conectar áreas
	attack_area.body_entered.connect(_on_attack_range_entered)

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_apply_gravity(delta)
	_handle_attack_cooldown(delta)

	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.PATROL:
			_process_patrol(delta)
		State.CHASE:
			_process_chase(delta)
		State.ATTACK:
			_process_attack(delta)
		State.DAMAGED:
			pass

	move_and_slide()

# === PROCESAMIENTO DE ESTADOS ===

func _process_idle(delta: float) -> void:
	velocity.x = 0
	velocity.z = 0
	if _can_see_player():
		_change_state(State.CHASE)

func _process_patrol(delta: float) -> void:
	if _can_see_player():
		_change_state(State.CHASE)
		return

	if nav_agent.is_navigation_finished():
		# Esperar en punto de patrulla
		_patrol_wait_timer += delta
		velocity.x = 0
		velocity.z = 0
		if _patrol_wait_timer >= patrol_wait_time:
			_patrol_wait_timer = 0.0
			_advance_patrol_point()
		return

	# Moverse hacia el punto de patrulla
	var next_pos := nav_agent.get_next_path_position()
	var direction := (next_pos - global_position).normalized()
	direction.y = 0

	velocity.x = direction.x * patrol_speed
	velocity.z = direction.z * patrol_speed
	_rotate_toward(direction, delta)

func _process_chase(delta: float) -> void:
	if _player == null:
		_change_state(State.PATROL)
		return

	# Verificar si perdió de vista al jugador
	var dist_to_player := global_position.distance_to(_player.global_position)
	if dist_to_player > lose_sight_range:
		_change_state(State.PATROL)
		_set_patrol_target()
		return

	# Perseguir al jugador
	nav_agent.target_position = _player.global_position

	if not nav_agent.is_navigation_finished():
		var next_pos := nav_agent.get_next_path_position()
		var direction := (next_pos - global_position).normalized()
		direction.y = 0

		velocity.x = direction.x * chase_speed
		velocity.z = direction.z * chase_speed
		_rotate_toward(direction, delta)
	else:
		velocity.x = 0
		velocity.z = 0

func _process_attack(_delta: float) -> void:
	velocity.x = 0
	velocity.z = 0

	# Mirar al jugador mientras ataca
	if _player:
		var dir_to_player := (_player.global_position - global_position).normalized()
		dir_to_player.y = 0
		_rotate_toward(dir_to_player, _delta)

# === DETECCIÓN ===

func _can_see_player() -> bool:
	if _player == null:
		return false

	var to_player := _player.global_position - global_position
	var distance := to_player.length()

	# Rango de detección
	if distance > detection_range:
		return false

	# Campo de visión
	var forward := -global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	to_player.y = 0
	to_player = to_player.normalized()

	var angle := rad_to_deg(forward.angle_to(to_player))
	if angle > field_of_view * 0.5:
		return false

	# Raycast para verificar línea de visión
	var space_state := get_world_3d().direct_space_state
	var from := global_position + Vector3.UP * 1.0
	var to := _player.global_position + Vector3.UP * 1.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	query.collision_mask = 0b0011  # Layer 1 (Player) + Layer 2 (Environment)

	var result := space_state.intersect_ray(query)
	if result and result["collider"] == _player:
		return true

	return false

# === PATRULLA ===

func _set_patrol_target() -> void:
	if patrol_points.size() == 0:
		return
	nav_agent.target_position = patrol_points[_current_patrol_index].global_position

func _advance_patrol_point() -> void:
	_current_patrol_index = (_current_patrol_index + 1) % patrol_points.size()
	_set_patrol_target()

# === COMBATE ===

func _on_attack_range_entered(body: Node3D) -> void:
	if body == _player and current_state == State.CHASE:
		_change_state(State.ATTACK)
		_try_attack()

func _try_attack() -> void:
	if not _can_attack or _is_dead:
		return

	_can_attack = false
	_attack_timer = attack_cooldown

	# Infligir daño al jugador
	if _player and _player.has_method("take_damage"):
		_player.take_damage(attack_damage, global_position)

	# Esperar y volver a perseguir
	await get_tree().create_timer(0.8).timeout
	if not _is_dead:
		_change_state(State.CHASE)

func take_damage(amount: int, from_position: Vector3 = Vector3.ZERO) -> void:
	if _is_dead:
		return

	_health -= amount

	if _health <= 0:
		_die()
	else:
		_change_state(State.DAMAGED)
		# Reaccionar al daño — breve stagger
		var knockback_dir := (global_position - from_position).normalized()
		knockback_dir.y = 0
		velocity = knockback_dir * 2.0

		await get_tree().create_timer(0.3).timeout
		if not _is_dead:
			_change_state(State.CHASE)

func _die() -> void:
	_is_dead = true
	_change_state(State.DEAD)
	Globals.mark_enemy_killed(enemy_id)
	Globals.enemy_killed.emit(self)

	# Desactivar colisiones
	collision_layer = 0
	collision_mask = 0

	# Animación de muerte simple (caer)
	var tween := create_tween()
	tween.tween_property(self, "rotation:x", deg_to_rad(90), 0.5)
	tween.tween_property(self, "position:y", position.y - 0.5, 0.3)
	await tween.finished

	# Mantener el cadáver visible pero desactivar el proceso
	set_physics_process(false)
	set_process(false)

# === UTILIDADES ===

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

func _handle_attack_cooldown(delta: float) -> void:
	if not _can_attack:
		_attack_timer -= delta
		if _attack_timer <= 0:
			_can_attack = true

func _rotate_toward(direction: Vector3, delta: float) -> void:
	if direction.length() < 0.01:
		return
	var target_angle := atan2(direction.x, direction.z)
	rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)

func _change_state(new_state: State) -> void:
	current_state = new_state
