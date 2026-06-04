## player_controller.gd
## Controlador del jugador con movimiento moderno relativo a cámara fija.
## Nodo raíz: CharacterBody3D
##
## Estructura de nodos esperada:
##   CharacterBody3D (este script)
##   ├── CollisionShape3D (cápsula)
##   ├── MeshInstance3D (placeholder: cápsula o modelo importado)
##   ├── AnimationPlayer (opcional, para animaciones)
##   ├── InteractionRay (RayCast3D, apunta hacia adelante)
##   ├── WeaponPivot (Node3D, punto de disparo)
##   │   └── MuzzlePoint (Marker3D)
##   └── HurtBox (Area3D + CollisionShape3D)

extends CharacterBody3D

# === SEÑALES ===
signal state_changed(new_state: StringName)
signal aiming_changed(is_aiming: bool)

# === EXPORTABLES ===
@export_group("Movement")
@export var walk_speed: float = 2.5
@export var run_speed: float = 5.0
@export var rotation_speed: float = 10.0
@export var gravity: float = 9.8

@export_group("Combat")
@export var max_health: int = 100
@export var knife_damage: int = 25
@export var knife_range: float = 1.5
@export var knife_cooldown: float = 0.6

@export_group("Interaction")
@export var interact_distance: float = 2.5

# === ESTADOS ===
enum State { IDLE, WALKING, RUNNING, AIMING, ATTACKING, DAMAGED, DEAD }
var current_state: State = State.IDLE

# === VARIABLES INTERNAS ===
var _current_camera: Camera3D = null
var _input_direction: Vector2 = Vector2.ZERO
var _is_aiming: bool = false
var _can_attack: bool = true
var _attack_timer: float = 0.0
var _nearest_interactable: Node3D = null

# === REFERENCIAS ===
@onready var interaction_ray: RayCast3D = $InteractionRay
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var weapon_pivot: Node3D = $WeaponPivot
@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null

func _ready() -> void:
	Globals.camera_changed.connect(_on_camera_changed)
	Globals.player_died.connect(_on_player_died)

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return
	if not Globals.is_playing():
		return

	_apply_gravity(delta)
	_handle_attack_cooldown(delta)

	match current_state:
		State.IDLE, State.WALKING, State.RUNNING:
			_process_movement(delta)
		State.AIMING:
			_process_aiming(delta)
		State.ATTACKING:
			pass  # Esperar fin de animación
		State.DAMAGED:
			pass  # Esperar fin de animación

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if not Globals.is_playing():
		return
	if current_state == State.DEAD:
		return

	# Inventario
	if event.is_action_pressed("inventory_toggle"):
		Globals.change_state(Globals.GameState.INVENTORY)
		Globals.inventory_toggled.emit(true)
		get_viewport().set_input_as_handled()
		return

	# Interacción
	if event.is_action_pressed("interact"):
		_try_interact()

	# Apuntar
	if event.is_action_pressed("aim"):
		_start_aiming()
	elif event.is_action_released("aim"):
		_stop_aiming()

	# Disparar (mientras apunta)
	if event.is_action_pressed("shoot") and _is_aiming:
		_shoot()

	# Cuchillo
	if event.is_action_pressed("knife") and _can_attack:
		_knife_attack()

# === MOVIMIENTO ===

func _process_movement(delta: float) -> void:
	_input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	if _input_direction.length() < 0.1:
		_change_state(State.IDLE)
		velocity.x = move_toward(velocity.x, 0, walk_speed * delta * 10.0)
		velocity.z = move_toward(velocity.z, 0, walk_speed * delta * 10.0)
		return

	# Movimiento relativo a la cámara activa
	var move_dir := _get_camera_relative_direction(_input_direction)
	var is_running := Input.is_action_pressed("run")
	var speed := run_speed if is_running else walk_speed

	velocity.x = move_dir.x * speed
	velocity.z = move_dir.z * speed

	# Rotar el personaje hacia la dirección de movimiento
	if move_dir.length() > 0.01:
		var target_angle := atan2(move_dir.x, move_dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)

	_change_state(State.RUNNING if is_running else State.WALKING)

func _get_camera_relative_direction(input: Vector2) -> Vector3:
	if _current_camera == null:
		# Fallback: usar dirección global
		return Vector3(input.x, 0, input.y).normalized()

	# Obtener los vectores forward y right de la cámara (proyectados al plano XZ)
	var cam_transform := _current_camera.global_transform
	var cam_forward := -cam_transform.basis.z
	var cam_right := cam_transform.basis.x

	# Aplanar al plano horizontal
	cam_forward.y = 0
	cam_right.y = 0
	cam_forward = cam_forward.normalized()
	cam_right = cam_right.normalized()

	# Calcular dirección relativa a cámara
	var direction := (cam_right * input.x + cam_forward * -input.y).normalized()
	return direction

# === APUNTAR Y DISPARAR ===

func _start_aiming() -> void:
	_is_aiming = true
	_change_state(State.AIMING)
	velocity.x = 0
	velocity.z = 0
	aiming_changed.emit(true)

func _stop_aiming() -> void:
	_is_aiming = false
	_change_state(State.IDLE)
	aiming_changed.emit(false)

func _process_aiming(_delta: float) -> void:
	# Mientras apunta, el jugador no se mueve pero puede rotar
	velocity.x = 0
	velocity.z = 0

	# Rotar lentamente con input horizontal
	var h_input := Input.get_axis("move_left", "move_right")
	if abs(h_input) > 0.1:
		rotation.y -= h_input * 2.0 * _delta

func _shoot() -> void:
	if Globals.player_ammo_pistol <= 0:
		# Click vacío — SFX de sin munición
		return

	Globals.player_ammo_pistol -= 1

	# Raycast desde el punto de disparo hacia adelante
	var from := weapon_pivot.global_position
	var forward := -weapon_pivot.global_transform.basis.z
	var to := from + forward * 50.0

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	query.collision_mask = 0b0100  # Layer 3: Enemies

	var result := space_state.intersect_ray(query)
	if result:
		var hit_node: Node = result["collider"] as Node
		if hit_node and hit_node.has_method("take_damage"):
			hit_node.take_damage(25, global_position)

func _knife_attack() -> void:
	_can_attack = false
	_attack_timer = knife_cooldown
	_change_state(State.ATTACKING)

	# Detectar enemigos en rango melee
	var space_state := get_world_3d().direct_space_state
	var from := global_position + Vector3.UP * 0.8
	var forward := -global_transform.basis.z
	var to := from + forward * knife_range

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	query.collision_mask = 0b0100  # Layer 3: Enemies

	var result := space_state.intersect_ray(query)
	if result:
		var hit_node: Node = result["collider"] as Node
		if hit_node and hit_node.has_method("take_damage"):
			hit_node.take_damage(knife_damage, global_position)

	# Volver a idle después del ataque
	await get_tree().create_timer(0.4).timeout
	if current_state == State.ATTACKING:
		_change_state(State.IDLE)

# === INTERACCIÓN ===

func _try_interact() -> void:
	var target := get_nearest_interactable()
	if target and target.has_method("interact"):
		target.interact(self)

## Devuelve el interactable más cercano dentro de interact_distance (o null).
## Detección por PROXIMIDAD (grupo "interactable") en vez de rayo estricto:
## no exige encarar con precisión, estilo RE clásico (te acercás y pulsás E).
func get_nearest_interactable() -> Node3D:
	var nearest: Node3D = null
	var nearest_dist := interact_distance
	for node in get_tree().get_nodes_in_group("interactable"):
		if not (node is Node3D):
			continue
		var n3d := node as Node3D
		var d := global_position.distance_to(n3d.global_position)
		if d <= nearest_dist:
			nearest_dist = d
			nearest = n3d
	return nearest

# === DAÑO ===

func take_damage(amount: int, _from_position: Vector3 = Vector3.ZERO) -> void:
	if current_state == State.DEAD:
		return
	Globals.damage_player(amount)
	if Globals.player_health > 0:
		_change_state(State.DAMAGED)
		# Breve invulnerabilidad
		await get_tree().create_timer(0.5).timeout
		if current_state == State.DAMAGED:
			_change_state(State.IDLE)

# === UTILIDADES ===

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

func _handle_attack_cooldown(delta: float) -> void:
	if not _can_attack:
		_attack_timer -= delta
		if _attack_timer <= 0:
			_can_attack = true

func _change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	state_changed.emit(State.keys()[new_state])

func _on_camera_changed(camera: Camera3D) -> void:
	_current_camera = camera

func _on_player_died() -> void:
	_change_state(State.DEAD)
	velocity = Vector3.ZERO
