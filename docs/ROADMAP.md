# ROADMAP — Pueblo Muerto

Fases e hitos para medir progreso. Marca los checkboxes al completar y refleja
el cambio en `CHANGELOG.md`.

Leyenda: ✅ hecho · 🟡 en progreso · ⬜ pendiente

---

## Fase 0 — Infraestructura
- [x] Proyecto Godot 4.6 + estructura de carpetas
- [x] Autoload `Globals`
- [x] Conexión MCP (addon Godot AI) + `.mcp.json`
- [x] Repo Git + documentación (`docs/`, `CLAUDE.md`)

## Fase 1 — Core jugable 🟡
- [x] Input Map (11 acciones)
- [x] Player controller con movimiento relativo a cámara
- [x] Sistema de cámara fija con zonas (básico)
- [x] Nivel graybox de prueba (`test_level`)
- [x] Shader PSX básico (aplicado solo al suelo, demo)
- [ ] **Cámaras estilo RE1: reposicionar + transición bidireccional fluida** ← siguiente
- [ ] Look PSX completo (viewport 320×240 + shader en todo el nivel)

## Fase 2 — Sistemas ⬜
- [x] Estructura de inventario (script) + items `.tres`
- [x] HUD (vida, munición, prompts)
- [ ] Sistema de interacción probado en mapa (pickups + puertas colocados)
- [ ] Combate verificado (apuntar + disparar + cuchillo contra enemigo)
- [ ] Inventario funcional en juego (abrir, usar, combinar)

## Fase 3 — Contenido ⬜
- [ ] IA enemiga verificada (patrulla + persecución + ataque)
- [ ] Puzzle de la llave (2 fragmentos → combinar)
- [ ] 5 zonas conectadas (Plaza, Callejón, Casa, Patio, Iglesia)
- [ ] Audio ambiente + SFX

## Fase 4 — Polish ⬜
- [ ] Transiciones entre zonas (fade)
- [ ] Pantalla de título
- [ ] Game Over / Demo End
- [ ] Reemplazar placeholders con modelos low-poly

---

### Hito actual
**Cerrar Fase 1** → dejar el nivel de prueba completamente jugable con cámaras
estilo RE1 y el look PSX a punto.
