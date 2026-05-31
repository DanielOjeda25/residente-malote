# PUEBLO MUERTO — Game Design Document
## Demo de Survival Horror | Godot 4.x | Estética PS1

---

## 1. Concepto

**Género:** Survival Horror con cámara fija
**Motor:** Godot 4.x
**Referencia principal:** Resident Evil 1/2 (PS1) + RE4 (ambientación rural)
**Estética:** Low-poly PS1 — vertex jitter, texturas pixeladas, niebla densa
**Ambientación:** Pueblo rural abandonado, noche cerrada

### Premisa
El jugador despierta en las afueras de un pueblo rural aislado. Los habitantes se han vuelto hostiles y violentos. Debe atravesar una zona lineal del pueblo (calle principal → iglesia) buscando una salida, resolviendo puzzles y sobreviviendo al combate con recursos limitados.

---

## 2. Estructura de la Demo (Zona Lineal)

```
[INICIO: Calle de entrada]
    │
    ▼
[Zona 1: Plaza del pueblo] ← Cámara fija cenital
    │   - Primer encuentro con enemigo
    │   - Recoger: Cuchillo
    │
    ▼
[Zona 2: Callejón estrecho] ← Cámara fija lateral
    │   - Atmósfera densa, niebla
    │   - Recoger: Munición pistola
    │
    ▼
[Zona 3: Interior casa abandonada] ← Cámara fija esquina
    │   - Puzzle: encontrar llave oxidada
    │   - Recoger: Pistola + Hierba medicinal
    │   - Enemigo emboscada
    │
    ▼
[Zona 4: Patio trasero → Puerta iglesia] ← Cámara fija alta
    │   - Combate: 2 enemigos
    │   - Usar llave oxidada en puerta
    │
    ▼
[FINAL: Interior iglesia] ← Cámara fija altar
    - Cinemática final / Demo End
```

---

## 3. Mecánicas

### 3.1 Movimiento
- **Tipo:** Moderno (WASD relativo a cámara)
- El personaje se mueve en la dirección que el jugador presiona respecto a la vista de la cámara activa
- **Velocidades:** Caminar (2.5 m/s), Correr (5.0 m/s, con Shift)
- **Interacción:** Tecla E para examinar/recoger objetos

### 3.2 Sistema de Cámara Fija
- Cámaras predefinidas en cada zona
- Transición suave (fade to black) al cambiar de zona
- Cada zona tiene un Area3D que activa su cámara correspondiente
- Las cámaras pueden tener leve movimiento cinematográfico (sway)

### 3.3 Combate
- **Apuntar:** Click derecho (el personaje se detiene y apunta)
- **Disparar:** Click izquierdo mientras apunta
- **Cuchillo:** Ataque cuerpo a cuerpo (sin munición)
- **Daño al jugador:** Los enemigos atacan al acercarse
- **Vida:** 100 HP, hierba medicinal restaura 50 HP

### 3.4 Inventario
- Grid de 4x2 slots (8 objetos máximo, estilo RE clásico)
- Tipos de items: Armas, Munición, Curación, Objetos clave
- Abrir con Tab — pausa el juego
- Combinar items (ej: pistola + munición = recargar)
- Examinar items (descripción + rotación 3D)

### 3.5 Puzzles
- **Puzzle 1 (Casa):** Encontrar 2 fragmentos de llave en habitaciones distintas → combinar en inventario → llave completa
- Las puertas bloqueadas muestran mensaje: "Está cerrada con llave..."

### 3.6 Enemigos (Humanos Hostiles)
- **Aldeano básico:** Camina lento, ataca con manos. HP: 50. Daño: 15.
- **Comportamiento:**
  - Patrulla en ruta simple
  - Al detectar al jugador (visión cono + distancia) → persigue
  - Ataca al llegar a rango melee
  - Al morir: ragdoll o animación de caída
- **Spawns fijos** en zonas predefinidas (no respawn)

---

## 4. Controles

| Acción         | Teclado        | Gamepad          |
|----------------|----------------|------------------|
| Mover          | WASD           | Stick izquierdo  |
| Correr         | Shift          | L2               |
| Interactuar    | E              | A / X            |
| Apuntar        | Click derecho  | L1               |
| Disparar       | Click izquierdo| R1               |
| Cuchillo       | F              | R2               |
| Inventario     | Tab            | Start            |
| Pausa          | Escape         | Select           |

---

## 5. Estética PS1

### Shaders
- **Vertex snapping:** Los vértices se ajustan a una grid baja (simula jitter PS1)
- **Affine texture mapping:** Distorsión de texturas sin corrección de perspectiva
- **Resolución renderizada:** 320x240 escalado a pantalla completa
- **Dithering:** Opcional, para gradientes de sombra
- **Fog:** Niebla densa negra/gris para limitar visibilidad

### Audio
- Ambiente: grillos, viento, madera crujiendo
- Música: drones minimalistas, tensión
- SFX: pasos en tierra/madera, disparos secos, gruñidos enemigos

---

## 6. Estructura del Proyecto Godot

```
pueblo_muerto/
├── project.godot
├── assets/
│   ├── models/          ← Placeholders (primitivas)
│   ├── textures/        ← Texturas pixeladas
│   ├── audio/           ← SFX + Música
│   └── fonts/           ← UI fonts
├── scenes/
│   ├── main.tscn        ← Escena principal
│   ├── player/
│   │   └── player.tscn
│   ├── enemies/
│   │   └── enemy_human.tscn
│   ├── levels/
│   │   ├── zona_1_plaza.tscn
│   │   ├── zona_2_callejon.tscn
│   │   ├── zona_3_casa.tscn
│   │   ├── zona_4_patio.tscn
│   │   └── zona_5_iglesia.tscn
│   ├── cameras/
│   │   └── fixed_camera.tscn
│   ├── ui/
│   │   ├── hud.tscn
│   │   ├── inventory_ui.tscn
│   │   └── pause_menu.tscn
│   └── interactables/
│       ├── pickup_item.tscn
│       └── door.tscn
├── scripts/
│   ├── player/
│   │   └── player_controller.gd
│   ├── camera/
│   │   ├── fixed_camera_system.gd
│   │   └── camera_zone.gd
│   ├── inventory/
│   │   ├── inventory_manager.gd
│   │   └── item_data.gd
│   ├── combat/
│   │   ├── weapon_manager.gd
│   │   └── hitbox.gd
│   ├── enemies/
│   │   └── enemy_ai.gd
│   ├── interaction/
│   │   ├── interactable.gd
│   │   ├── pickup.gd
│   │   └── door.gd
│   ├── puzzle/
│   │   └── puzzle_manager.gd
│   ├── ui/
│   │   ├── hud.gd
│   │   └── inventory_ui.gd
│   ├── managers/
│   │   └── game_manager.gd
│   └── autoload/
│       └── globals.gd
├── shaders/
│   ├── psx_vertex_snap.gdshader
│   └── psx_dither.gdshader
└── resources/
    └── items/
        ├── pistol.tres
        ├── knife.tres
        ├── ammo_pistol.tres
        ├── herb.tres
        └── rusty_key.tres
```

---

## 7. Roadmap de Desarrollo

### Fase 1 — Core (Semana 1-2)
- [ ] Player controller con movimiento moderno
- [ ] Sistema de cámara fija con transiciones
- [ ] Shader PSX básico (vertex snap + resolución baja)
- [ ] Nivel graybox con primitivas

### Fase 2 — Sistemas (Semana 3-4)
- [ ] Sistema de inventario completo
- [ ] Sistema de interacción (recoger items, puertas)
- [ ] HUD (vida, munición)
- [ ] Sistema de combate (apuntar + disparar)

### Fase 3 — Contenido (Semana 5-6)
- [ ] Enemigo IA básica (patrulla + persecución + ataque)
- [ ] Puzzle de la llave
- [ ] 5 zonas conectadas
- [ ] Audio ambiente + SFX

### Fase 4 — Polish (Semana 7-8)
- [ ] Transiciones entre zonas (fade)
- [ ] Pantalla de título
- [ ] Game Over / Demo End
- [ ] Reemplazar placeholders con modelos propios
