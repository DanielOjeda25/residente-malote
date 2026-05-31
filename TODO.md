# TODO — Pueblo Muerto (notas de desarrollo)

> Tareas pendientes para retomar. Cada entrada es autocontenida para poder
> continuar sin contexto previo.

---

## 🎥 Sistema de cámaras fijas estilo Resident Evil 1

**Estado:** funcional básico, pendiente de pulido. PRIORIDAD para la próxima sesión.

### Objetivo
Lograr el look de **Resident Evil 1 (PS1)**: cámaras fijas con ángulos
cinematográficos, y transición **bidireccional** entre zonas (al caminar
hacia adelante cambia de Cámara 1 → 2, y al volver hacia atrás de 2 → 1).

### Qué hay montado ahora
- Escena: `res://scenes/levels/test_level.tscn`
- Nodo `CameraSystem` (Node3D) con script `res://scripts/camera/fixed_camera_system.gd`
  - `fade_duration = 0.4`, `initial_camera_index = 0`
- Dos zonas, cada una `Area3D` + `CollisionShape3D` + `Camera3D` hija,
  con script `res://scripts/camera/camera_zone.gd`:

  | Zona | Posición (z) | Cubre |
  |------|--------------|-------|
  | `CameraZone_01` | z = +3.5 | parte cercana (player aparece en z=5) |
  | `CameraZone_02` | z = −3.5 | fondo del pasillo (enemigo en z=−4) |

- El enemigo (`EnemyHuman`) está en z=−4, dentro de la zona 2. Por eso el
  cambio de cámara coincide con "acercarse al enemigo" (NO lo causa el enemigo).

### Cómo funciona el cambio (referencia técnica)
`camera_zone.gd`:
- `Area3D` con `collision_mask = Layer 1` → detecta solo al Player.
- Conecta **solo `body_entered`** → al entrar el player llama
  `_camera_system.switch_to_camera(_camera)` (fade a esa cámara).
- **NO conecta `body_exited`.**
- Tiene `camera_sway` (balanceo cinematográfico sutil) ya activo.

### Tareas concretas
1. **Reposicionar las 2 `Camera3D`** (una por zona) con ángulos tipo RE1:
   - Zona 1 (entrada): cámara alta en picado / esquina superior.
   - Zona 2 (fondo): cámara lateral o en esquina opuesta, claustrofóbica.
   - Que ambas encuadren bien al player Y al enemigo en su zona.
2. **Transición bidireccional sin huecos:**
   - Con solo `body_entered` ya debería volver de cam2 → cam1 al retroceder
     (vuelve a disparar el `entered` de la zona 1).
   - ⚠️ Verificar que los `CollisionShape3D` (BoxShape) de ambas zonas
     **cubren todo el pasillo sin dejar hueco** entre z=+3.5 y z=−3.5.
     Si hay hueco, en el medio no se activa ninguna cámara (la última se queda).
   - Si se quiere control más fino, evaluar añadir `body_exited` o un gestor
     de "última zona activa" en `fixed_camera_system.gd`.
3. Personalizar `zone_name` de cada zona (ahora ambas = `"zona_default"`).
4. (Opcional) Más zonas siguiendo el GDD: Plaza, Callejón, Casa, Patio, Iglesia.

### Datos de partida (al reabrir el editor, verificar en vivo)
- Player inicia en `(0, 1, 5)`. Enemigo en `(0, 1, −4)`.
- Pasillo orientado en el eje Z. Paredes en Layer 2 (Environment).
- Falta confirmar tamaño exacto de los `CollisionShape3D` de las zonas y
  las posiciones/rotaciones actuales de cada `Camera3D` (no leídas aún;
  el editor se desconectó al anotar esto).

---

## ✅ Ya resuelto en sesiones anteriores (no rehacer)
- Input Map (11 acciones) configurado y probado.
- Items `.tres` (pistol, ammo_pistol, herb, knife, key_fragment_a/b, rusty_key).
- HUD (`res://scenes/ui/hud.tscn`) creado e instanciado en el nivel.
- Shader PSX (`res://resources/psx_material.tres`) aplicado SOLO al suelo (demo).
- Escena principal = `test_level.tscn`.
- **Bug colisión resuelto:** Player y Enemy caían al vacío por `collision_mask=1`.
  - Player → `collision_mask = 6` (Environment + Enemies).
  - Enemy → `collision_mask = 3` (Environment + Player).

## ⏳ Otras pendientes (de menor prioridad)
- Look PSX completo: viewport 320×240 + shader en todo el nivel (ahora solo suelo).
- Nombres de Collision Layers en Project Settings (cosmético; los valores ya funcionan).
- Colocar pickups de items en el mapa para probar interacción (tecla E) e inventario.
- Puertas, puzzle de la llave, más enemigos y las 5 zonas del GDD.
- Scripts del GDD que NO venían en el ZIP (no creados): `weapon_manager.gd`,
  `hitbox.gd`, `interactable.gd`, `puzzle_manager.gd`, `psx_dither.gdshader`, `pause_menu`.
