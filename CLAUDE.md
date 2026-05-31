# CLAUDE.md — Contexto para el agente

> Léeme al empezar cualquier sesión en este proyecto. Resume el estado, la
> arquitectura y cómo continuar. Para el detalle vivo de tareas, mira
> `docs/ROADMAP.md`, `docs/CHANGELOG.md` y `TODO.md`.

## Qué es esto
**Pueblo Muerto** (repo: `residente-malote`): demo de survival horror estética
PS1 en **Godot 4.6** (Forward+, Jolt Physics). Referencia: Resident Evil 1/2 (PS1).

## Idioma y estilo
- Responde y documenta **en español**.
- No añadas mecánicas/archivos que no estén pedidos explícitamente o en los docs.
- Para cambios grandes, propón un plan corto y espera confirmación.

## Arquitectura del proyecto
- `scripts/autoload/globals.gd` → singleton **`Globals`** (estado, señales). Autoload activo.
- `scripts/player/player_controller.gd` → `CharacterBody3D`, movimiento relativo a cámara.
- `scripts/enemies/enemy_ai.gd` → IA (patrulla/persecución/ataque).
- `scripts/camera/fixed_camera_system.gd` + `camera_zone.gd` → cámaras fijas por zonas.
- `scripts/inventory/` → `inventory_manager.gd`, `item_data.gd` (Resource `ItemData`).
- `scripts/interaction/` → `pickup.gd`, `door.gd`. `scripts/ui/` → `hud.gd`, `inventory_ui.gd`.
- `scenes/` → `player/player.tscn`, `enemies/enemy_human.tscn`, `levels/test_level.tscn`, `ui/hud.tscn`.
- `resources/items/*.tres` → definiciones de items. `resources/psx_material.tres` → shader PSX.
- `shaders/psx_vertex_snap.gdshader` → look PS1.

### Collision layers (convención del proyecto)
| Layer | Uso |
|-------|-----|
| 1 | Player |
| 2 | Environment (suelo, paredes) |
| 3 | Enemies |
| 4 | Interactables |
| 5 | Projectiles |

⚠️ Todo `CharacterBody3D` debe tener el `collision_mask` que incluya **Environment (Layer 2)**
o cae al vacío. Player mask=6 (Env+Enemies); Enemy mask=3 (Env+Player).

## Desarrollo vía MCP (Godot AI)
- El editor expone herramientas MCP mediante el addon `addons/godot_ai` (server en
  `http://127.0.0.1:8000/mcp`, config en `.mcp.json`).
- **Prerequisitos en la máquina:** Godot 4.6+, Claude Code, git y **`uv`**
  (⚠️ el plugin usa `uv` para levantar el server MCP; sin él no arranca).
- **Requisito de arranque:** tener **Godot abierto con el plugin "Godot AI" activo**
  ANTES de lanzar la sesión del agente, o las herramientas de Godot no estarán disponibles.
- Si reinicias Godot a mitad de sesión (o ves *"Unable to connect"*), reinicia también
  la sesión del agente.
- 📄 **Guía completa de puesta en marcha (máquina nueva): [`docs/MCP_SETUP.md`](docs/MCP_SETUP.md)**.

## Flujo multi-máquina (PC ↔ notebook)
1. `git pull` al empezar.
2. Lee `docs/CHANGELOG.md` (qué se hizo) y `TODO.md` (qué sigue).
3. Trabaja. Verifica en runtime cuando sea posible (ejecutar el juego y leer estado).
4. **Antes de terminar:** añade una entrada a `docs/CHANGELOG.md`, actualiza
   checkboxes en `docs/ROADMAP.md` y ajusta `TODO.md`.
5. `git add` + `commit` con mensaje claro + `git push`.
6. Nunca `--force` / `--no-verify` / reescribir historia en `main`.

## Estado actual (resumen)
Setup completo y nivel de prueba jugable: Input Map, items, HUD, shader (en suelo),
player y enemigo funcionando sobre el suelo. Pendiente inmediato: pulir cámaras
estilo RE1. Ver `docs/ROADMAP.md` y `TODO.md`.
