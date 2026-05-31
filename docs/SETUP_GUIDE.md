# PUEBLO MUERTO — Guía de Montaje en Godot 4

## Requisitos
- Godot 4.3+ (descargar desde https://godotengine.org)
- Los scripts de este paquete

---

## Paso 1: Crear Proyecto

1. Abre Godot → **New Project**
2. Nombre: `pueblo_muerto`
3. Renderer: **Forward+** (o Mobile para rendimiento)
4. Crear y abrir

---

## Paso 2: Estructura de Carpetas

Crea esta estructura en FileSystem:

```
res://
├── scripts/
│   ├── autoload/
│   ├── player/
│   ├── camera/
│   ├── inventory/
│   ├── enemies/
│   ├── interaction/
│   ├── ui/
│   └── managers/
├── shaders/
├── scenes/
│   ├── player/
│   ├── enemies/
│   ├── levels/
│   ├── cameras/
│   └── ui/
├── resources/
│   └── items/
└── assets/
    ├── models/
    ├── textures/
    └── audio/
```

Copia cada `.gd` y `.gdshader` a su carpeta correspondiente.

---

## Paso 3: Configurar Autoload

1. Ve a **Project → Project Settings → Autoload**
2. Añade `res://scripts/autoload/globals.gd` con nombre `Globals`

---

## Paso 4: Configurar Input Map

Ve a **Project → Project Settings → Input Map** y añade estas acciones:

| Acción            | Tecla           | Descripción               |
|-------------------|-----------------|---------------------------|
| `move_forward`    | W               | Mover adelante             |
| `move_backward`   | S               | Mover atrás               |
| `move_left`       | A               | Mover izquierda            |
| `move_right`      | D               | Mover derecha              |
| `run`             | Shift            | Correr                     |
| `interact`        | E               | Interactuar                |
| `aim`             | Mouse Right      | Apuntar                    |
| `shoot`           | Mouse Left       | Disparar                   |
| `knife`           | F               | Ataque cuchillo            |
| `inventory_toggle`| Tab             | Abrir/cerrar inventario    |
| `pause`           | Escape          | Pausar                     |

---

## Paso 5: Crear la Escena del Jugador

1. **Scene → New Scene**
2. Nodo raíz: `CharacterBody3D` → renombrar a "Player"
3. Añadir hijos:
   - `CollisionShape3D` → Shape: CapsuleShape3D (radius: 0.3, height: 1.8)
   - `MeshInstance3D` → Mesh: CapsuleMesh (mismo tamaño, color azul)
   - `RayCast3D` → renombrar a "InteractionRay"
     - Target Position: (0, 0, -2) — apunta hacia adelante
     - Enabled: true
     - Collision Mask: Layer 4 (Interactables)
   - `Node3D` → renombrar a "WeaponPivot", posición (0.3, 1.0, -0.5)
     - Hijo: `Marker3D` → renombrar a "MuzzlePoint"
   - `Area3D` → renombrar a "HurtBox"
     - Hijo: `CollisionShape3D` → Shape: CapsuleShape3D
4. Adjuntar `player_controller.gd` al nodo raíz
5. Añadir `InventoryManager` como nodo hijo (Node) con `inventory_manager.gd`
6. Añadir Player al grupo "player" (Inspector → Node → Groups)
7. **Collision Layer del Player: Layer 1**
8. Guardar como `res://scenes/player/player.tscn`

---

## Paso 6: Crear Escena de Enemigo

1. **Scene → New Scene**
2. Nodo raíz: `CharacterBody3D` → renombrar a "EnemyHuman"
3. Añadir hijos:
   - `CollisionShape3D` → CapsuleShape3D
   - `MeshInstance3D` → CapsuleMesh (color rojo para distinguir)
   - `NavigationAgent3D`
   - `Area3D` → renombrar a "DetectionArea"
     - Hijo: `CollisionShape3D` → SphereShape3D (radius: 8.0)
     - Collision Mask: Layer 1 (Player)
   - `Area3D` → renombrar a "AttackArea"
     - Hijo: `CollisionShape3D` → SphereShape3D (radius: 1.5)
     - Collision Mask: Layer 1 (Player)
4. Adjuntar `enemy_ai.gd` al nodo raíz
5. **Collision Layer: Layer 3** (Enemies)
6. Guardar como `res://scenes/enemies/enemy_human.tscn`

---

## Paso 7: Crear un Nivel de Prueba

1. **Scene → New Scene**
2. Nodo raíz: `Node3D` → renombrar a "TestLevel"
3. Añadir hijos:
   - **Suelo:** `StaticBody3D` + `CollisionShape3D` (BoxShape3D grande plano) + `MeshInstance3D` (BoxMesh)
   - **Paredes:** Varios `StaticBody3D` con BoxShape3D para crear un pasillo
   - **NavigationRegion3D** → con NavigationMesh baked (cubrir el suelo)
   - **Luces:** `DirectionalLight3D` con intensidad baja + `OmniLight3D` puntuales
   - **WorldEnvironment** → con Environment:
     - Background: Color negro
     - Ambient Light: muy baja
     - Fog: activar, color negro, densidad alta
4. Instanciar `player.tscn`
5. Añadir el sistema de cámaras (ver paso 8)
6. Instanciar `enemy_human.tscn` (colocar más adelante en el pasillo)
7. Guardar como `res://scenes/levels/test_level.tscn`

---

## Paso 8: Configurar Cámaras Fijas

1. En el nivel, crear un nodo `Node3D` → renombrar a "CameraSystem"
2. Adjuntar `fixed_camera_system.gd`
3. Crear hijos `Area3D` para cada zona:
   - Renombrar a "CameraZone_01"
   - Adjuntar `camera_zone.gd`
   - Añadir `CollisionShape3D` con BoxShape3D cubriendo la zona
   - Añadir `Camera3D` como hijo, posicionada en ángulo cinematográfico
   - **Collision Mask: Layer 1** (detectar Player)
   - **Collision Layer: 0** (no colisiona con nada)
4. Repetir para cada zona del nivel

**Tip de posicionamiento de cámaras:**
- Zona 1 (Plaza): Cámara alta, picado cenital
- Zona 2 (Callejón): Cámara lateral, perspectiva claustrofóbica
- Zona 3 (Casa): Cámara en esquina superior
- Zona 4 (Patio): Cámara alta, gran angular

---

## Paso 9: Crear Items (.tres)

Crea archivos Resource en `res://resources/items/`:

### Pistola
```
Nuevo Resource → ItemData
item_id: "pistol"
item_name: "Pistola"
description: "Una pistola semiautomática. Calibre 9mm."
type: WEAPON
damage: 25
ammo_type: "ammo_pistol"
```

### Munición
```
item_id: "ammo_pistol"
item_name: "Munición 9mm"
description: "Un cargador con 15 balas."
type: AMMO
stackable: true
max_stack: 60
```

### Hierba Medicinal
```
item_id: "herb"
item_name: "Hierba Medicinal"
description: "Una hierba con propiedades curativas. Restaura salud."
type: HEALING
heal_amount: 50
```

### Cuchillo
```
item_id: "knife"
item_name: "Cuchillo"
description: "Un cuchillo de caza. Último recurso."
type: WEAPON
damage: 25
```

### Fragmento de Llave A
```
item_id: "key_fragment_a"
item_name: "Fragmento de Llave (A)"
description: "Mitad de una llave oxidada. Podría combinarse con la otra mitad."
type: COMBINABLE
combine_with_id: "key_fragment_b"
combine_result_id: "rusty_key"
```

### Fragmento de Llave B
```
item_id: "key_fragment_b"
item_name: "Fragmento de Llave (B)"
description: "La otra mitad de la llave oxidada."
type: COMBINABLE
combine_with_id: "key_fragment_a"
combine_result_id: "rusty_key"
```

### Llave Oxidada (resultado)
```
item_id: "rusty_key"
item_name: "Llave Oxidada"
description: "Una llave vieja y oxidada. Parece abrir una puerta pesada."
type: KEY_ITEM
```

---

## Paso 10: Configurar HUD

1. Crear escena con `CanvasLayer` → hijo `Control`
2. Adjuntar `hud.gd` al Control
3. Crear los nodos hijos referenciados en el script:
   - `ProgressBar` → renombrar a "HealthBar" (esquina superior izquierda)
   - `Label` → renombrar a "AmmoLabel" (esquina superior derecha)
   - `Label` → renombrar a "InteractPrompt" (centro inferior)
   - `PanelContainer` → renombrar a "MessageBox" (centro)
     - Hijo: `Label` → renombrar a "MessageLabel"
4. Instanciar en el nivel o como escena hija del Player

---

## Paso 11: Configurar el Shader PSX

1. Selecciona cualquier `MeshInstance3D` del nivel
2. En Inspector → Material → New ShaderMaterial
3. En el ShaderMaterial → Shader → Load → `psx_vertex_snap.gdshader`
4. Ajustar parámetros:
   - `snap_intensity`: 0.3-0.5 para efecto sutil
   - `resolution`: 160 (muy PS1) a 320 (sutil)
   - `fog_enabled`: true
   - `fog_end`: 15-20 (niebla cercana = más terror)

**Para resolución renderizada PS1:**
1. Project Settings → Display → Window:
   - Viewport Width: 320
   - Viewport Height: 240
   - Window Width Override: 1280
   - Window Height Override: 960
   - Stretch Mode: viewport
   - Stretch Aspect: keep

---

## Paso 12: Collision Layers

Organiza así en Project Settings → Layer Names → 3D Physics:

| Layer | Nombre        | Uso                          |
|-------|---------------|------------------------------|
| 1     | Player        | CharacterBody3D del jugador  |
| 2     | Environment   | Paredes, suelo, objetos      |
| 3     | Enemies       | Enemigos                     |
| 4     | Interactables | Items, puertas, puzzles      |
| 5     | Projectiles   | Balas, objetos lanzados      |

---

## Siguiente Paso

Con todo montado, ejecuta el proyecto (F5). Deberías poder:
1. Moverte con WASD
2. Ver la cámara cambiar al entrar en zonas
3. Interactuar con items (E)
4. Abrir inventario (Tab)
5. Atacar con cuchillo (F) o disparar (click mientras apuntas con click derecho)

¡Desde aquí, iteramos añadiendo más zonas, puliendo la atmósfera y reemplazando
placeholders con tus modelos low-poly de Blender!
