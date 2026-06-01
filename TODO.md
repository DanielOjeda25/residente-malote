# TODO — Pueblo Muerto (notas de desarrollo)

> Tareas pendientes para retomar. Cada entrada es autocontenida para poder
> continuar sin contexto previo.

---

## ▶️ PRIORIDAD: Fase 2 — Sistemas en el mapa

Fase 1 cerrada (core jugable + cámaras RE1 + look PSX). Siguiente, verificar sistemas
en juego sobre `test_level`:
1. **Pickups + puertas**: instanciar `pickup.gd` (con un `ItemData`) y `door.gd` en el
   mapa y probar interacción con **E** (el HUD ya muestra el prompt `[E] ...`).
2. **Inventario en juego**: abrir con **Tab**, usar/combinar (el puzzle de la llave usa
   `key_fragment_a` + `key_fragment_b` → `rusty_key`). Existe `inventory_manager.gd` pero
   falta una UI de inventario montada (`inventory_ui.gd` está pero sin escena).
3. **Combate**: apuntar (click der.) + disparar (click izq., requiere munición) + cuchillo
   (F) contra `EnemyHuman`. Verificar daño y muerte.

### Notas de iluminación (pendiente menor)
- `DirectionalLight3D` con `light_energy=0.3` + `OmniLight3D` ≈2.2. Para el ambiente
  nocturno del GDD: bajar luz ambiente y reforzar niebla. No urgente.
- Opcional look PSX: `psx_dither.gdshader` (sin crear).

---

## 🎞️ Look PSX — ✅ RESUELTO (2026-06-01)

Detalle en `docs/CHANGELOG.md`. Resumen:
- Render 320×240 (`stretch/mode=viewport`, base 320×240, ventana 1280×960). Framebuffer nativo 320×240.
- Shader PSX (`psx_vertex_snap.gdshader`) en suelo, 3 paredes, player y enemigo.
- Quitado `unshaded` → `vertex_lighting` + transformación de NORMAL en el vertex (entorno ya no plano).
- Materiales: `psx_material.tres` (entorno gris), `psx_material_player.tres` (blanco),
  `psx_material_enemy.tres` (rojo).
- HUD reescalado a 320×240 (`hud.tscn`).
- Muros subidos a 5 m (escala Y ×1.6667) para que el límite lateral se vea desde las cámaras.

---

## 🎥 Cámaras estilo RE1 — ✅ RESUELTO (2026-05-31)

Detalle en `docs/CHANGELOG.md`. Resumen:
- Cam "plaza" (Zona 1) en `(1.8, 3.6, 7)`, rot ≈ (−28°, +18°, 0). Esquina alta, diagonal a −Z.
- Cam "callejón" (Zona 2) en `(−1.8, 3.8, 1)`, rot ≈ (−30°, −18°, 0). Esquina opuesta, a −Z.
  (Recolocadas estilo RE clásico: esquina alta, picado moderado, vista 3/4 diagonal.)
- Zonas renombradas: `"plaza"` / `"callejon"`.
- Transición bidireccional OK: los box de zona (4×3×7) se tocan en z=0 sin hueco.

**Nota:** ambas cámaras miran a −Z → "adelante" (W) lleva al fondo en las dos zonas,
sin inversión ni rebote al cruzar z=0. (Si en el futuro alguna cámara mira a +Z, evaluar
un buffer de input direccional ~0.3 s al cambiar de cámara.)

**Pendiente del autor:** reposicionar el callejón cuando se conecten 2 rooms reales.

### Geometría del pasillo (referencia confirmada en vivo)
- Suelo 20×20, superficie en y=0. Muros: cara interior en x=±2.0; muro de fondo en z=−7.5.
- Interior jugable: X∈[−2,+2], Z desde −7.5 (pared) hasta abierto en +7.5.
- Player inicia en `(0, 1, 5)`. Enemigo en `(0, 1, −4)`.

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
- Nombres de Collision Layers en Project Settings (cosmético; los valores ya funcionan).
- Colocar pickups de items en el mapa para probar interacción (tecla E) e inventario.
- Puertas, puzzle de la llave, más enemigos y las 5 zonas del GDD.
- Scripts del GDD que NO venían en el ZIP (no creados): `weapon_manager.gd`,
  `hitbox.gd`, `interactable.gd`, `puzzle_manager.gd`, `psx_dither.gdshader`, `pause_menu`.
