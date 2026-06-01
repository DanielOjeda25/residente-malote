# TODO — Pueblo Muerto (notas de desarrollo)

> Tareas pendientes para retomar. Cada entrada es autocontenida para poder
> continuar sin contexto previo.

---

## ▶️ PRIORIDAD: verificar en runtime el nivel reconstruido

`test_level.tscn` se rehízo como **dos salas + puerta** (ver CHANGELOG 2026-06-01).
Verificar en juego (pendiente del autor, probar en casa):
1. **Puerta**: caminar hasta la puerta marrón (en el muro divisorio, z=0) y pulsar **E**.
   Debería abrirse (no requiere llave). `door.gd` en nodo `Door`. Si NO abre, depurar:
   alcance del `InteractionRay` del player (target z=−2, mask 8) y que el player llegue
   bastante cerca.
2. **Transición de cámara** sala A ↔ sala B al cruzar la puerta (zonas se tocan en z=0).

## Fase 2 — Sistemas (siguiente)
1. **Pickups**: instanciar `pickup.gd` (con un `ItemData`) en las salas y probar **E**.
2. **Inventario en juego**: abrir con **Tab**, usar/combinar (puzzle llave:
   `key_fragment_a` + `key_fragment_b` → `rusty_key`). `inventory_manager.gd` existe;
   falta UI montada (`inventory_ui.gd` está pero sin escena).
3. **Combate**: apuntar (click der.) + disparar (click izq.) + cuchillo (F) vs `EnemyHuman`.
4. **Puerta con llave**: setear `required_key_id` en `Door` para probar el flujo de llave.

### Notas de iluminación / look (pendiente menor)
- Ahora: `ambient_light_energy=0.5` + 2 `OmniLight3D` (energy 3.5) interiores. Se ve algo
  plano/lavado. Para el ambiente nocturno del GDD: bajar ambiente, reforzar sombras y niebla.
- Snapping del entorno calibrado a 0.2 (en superficies grandes deformaba). Si se quiere más
  jitter PS1, subdividir suelo/paredes antes de subirlo.
- Opcional: `psx_dither.gdshader` (sin crear).

---

## 🎞️ Look PSX — ✅ (2026-06-01)

Detalle en `docs/CHANGELOG.md`. Resumen:
- Render 320×240 (`stretch/mode=viewport`, base 320×240, ventana 1280×960). Framebuffer nativo 320×240.
- Shader PSX (`psx_vertex_snap.gdshader`) en todo el entorno + player + enemigo + puerta.
- `vertex_lighting` (no `unshaded`) + transformación de NORMAL en el vertex.
- Materiales: `psx_material.tres` (entorno gris, snap 0.2), `psx_material_player.tres`
  (blanco), `psx_material_enemy.tres` (rojo), `psx_material_door.tres` (marrón).
- Niebla en el `WorldEnvironment` (ambiental, no por-objeto). HUD a 320×240 (`hud.tscn`).

---

## 🎥 Cámaras fijas — ✅ (2026-06-01, nivel de dos salas)

Detalle en `docs/CHANGELOG.md`. `CameraSystem` con 2 zonas (`fixed_camera_system.gd` +
`camera_zone.gd`). **Las Camera3D son hijas de su zona → posiciones LOCALES** (no globales;
sumar el offset de la zona para la posición en mundo). FOV 55.
- Zona A (`sala_a`, Area3D en `(0,1.5,4)`, box 8×3×8): cámara en esquina, apunta al player.
- Zona B (`sala_b`, Area3D en `(0,1.5,-4)`, box 8×3×8): cámara en esquina, apunta al enemigo.
- Las zonas se tocan en z=0 (la puerta) → sin hueco en la transición.

### Geometría del nivel (dos salas + puerta)
- Suelo 8×16 (x∈[−4,4], z∈[−8,8]), cara superior en y=0. Paredes y **techo** cerrados.
- Sala A: z∈[0,8] (player spawn en `(0,1,5)`). Sala B: z∈[−8,0] (enemigo en `(0,1,−4)`).
- Muro divisorio en z=0 con hueco de puerta (x∈[−1,1]); `Door` (door.gd) + `DoorLintel`.

---

## ✅ Ya resuelto en sesiones anteriores (no rehacer)
- Input Map (11 acciones) configurado y probado.
- Items `.tres` (pistol, ammo_pistol, herb, knife, key_fragment_a/b, rusty_key).
- HUD (`res://scenes/ui/hud.tscn`) creado, instanciado y reescalado a 320×240.
- Escena principal = `test_level.tscn` (reconstruida: dos salas + puerta).
- **Bug colisión resuelto:** Player y Enemy caían al vacío por `collision_mask=1`.
  - Player → `collision_mask = 6` (Environment + Enemies).
  - Enemy → `collision_mask = 3` (Environment + Player).

## ⏳ Otras pendientes (de menor prioridad)
- Nombres de Collision Layers en Project Settings (cosmético; los valores ya funcionan).
- Puzzle de la llave, más enemigos y las 5 zonas del GDD.
- Navegación: `NavigationRegion3D` sin bakear (el enemigo persigue por nav; si no se
  mueve al perseguir, hay que bakear la malla).
- `.mcp.json` en local quedó vaciado (`"mcpServers": {}`); NO commitearlo así. Restaurar a
  `http://127.0.0.1:8000/mcp` si hace falta (ver `docs/MCP_SETUP.md`).
- Scripts del GDD que NO venían en el ZIP (no creados): `weapon_manager.gd`,
  `hitbox.gd`, `interactable.gd`, `puzzle_manager.gd`, `psx_dither.gdshader`, `pause_menu`.
