# CHANGELOG — Pueblo Muerto

Bitácora de cambios por sesión. Lo más reciente arriba. Añade una entrada antes
de cada `push` para que la otra máquina (y el agente) sepa qué cambió.

Formato: `## [fecha] — título` + lista de cambios.

---

## [2026-05-31] — Setup, montaje base y repositorio

### Infraestructura
- Instalado `uv`, addon **Godot AI v2.5.13** y configurado MCP (`.mcp.json`, transporte HTTP).
- Extraído el paquete de scripts del juego; creada la estructura de carpetas.
- Inicializado el repo Git y la documentación (`docs/`, `CLAUDE.md`, `README.md`, `ROADMAP.md`).

### Montaje del nivel de prueba (`test_level`)
- **Input Map**: 11 acciones (movimiento, run, interact, aim, shoot, knife, inventory, pause).
- **Items**: 7 recursos `.tres` (pistol, ammo_pistol, herb, knife, key_fragment_a/b, rusty_key).
- **HUD**: escena `scenes/ui/hud.tscn` creada e instanciada en el nivel.
- **Shader PSX**: material `resources/psx_material.tres` aplicado **solo al suelo** (demo).
- **Escena principal** configurada a `test_level.tscn`.

### Bugs corregidos
- **Player y Enemy caían al vacío** por `collision_mask = 1` (no detectaban el suelo,
  que está en Layer 2 / Environment).
  - Player → `collision_mask = 6` (Environment + Enemies).
  - Enemy → `collision_mask = 3` (Environment + Player).
- Verificado en runtime: ambos se apoyan en el suelo (y ≈ 0.9) y el player camina con WASD.

### Pendiente al cerrar la sesión
- Pulir cámaras estilo RE1 (reposicionar las 2 Camera3D + transición bidireccional).
  Detalle en `TODO.md`.
