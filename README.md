# Pueblo Muerto (residente-malote)

Demo técnica de **survival horror con estética PS1** (estilo Resident Evil 1/2),
hecha en **Godot 4.6**.

- Cámaras fijas con transición entre zonas
- Movimiento moderno relativo a cámara
- Inventario estilo RE clásico, combate (pistola + cuchillo), enemigos con IA
- Shader PSX (vertex snapping, affine mapping, niebla densa)

## Cómo abrir
1. Instala **Godot 4.6+**.
2. Abre `project.godot` con el editor de Godot.
3. Pulsa **F5** para jugar (escena principal: `scenes/levels/test_level.tscn`).

## Documentación
- 📋 [`docs/ROADMAP.md`](docs/ROADMAP.md) — fases, hitos y progreso
- 📝 [`docs/CHANGELOG.md`](docs/CHANGELOG.md) — bitácora de cambios
- 🎮 [`docs/GDD.md`](docs/GDD.md) — diseño del juego
- 🔧 [`docs/SETUP_GUIDE.md`](docs/SETUP_GUIDE.md) — guía de montaje en Godot
- ✅ [`TODO.md`](TODO.md) — tareas inmediatas
- 🤖 [`CLAUDE.md`](CLAUDE.md) — contexto para el agente IA

## Desarrollo asistido por IA
Este proyecto se desarrolla con un agente conectado al editor de Godot vía MCP
(addon `addons/godot_ai`). Ver `CLAUDE.md` para el flujo de trabajo.
