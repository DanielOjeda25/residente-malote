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

## Fase 1 — Core jugable ✅
- [x] Input Map (11 acciones)
- [x] Player controller con movimiento relativo a cámara
- [x] Sistema de cámara fija con zonas (básico)
- [x] Nivel graybox de prueba (`test_level`)
- [x] Shader PSX básico (aplicado solo al suelo, demo)
- [x] **Cámaras estilo RE1: reposicionar + transición bidireccional fluida**
- [x] Look PSX completo (viewport 320×240 + shader en suelo, paredes, player y enemigo)

## Fase 2 — Sistemas 🟡
- [x] Estructura de inventario (script) + items `.tres`
- [x] HUD (vida, munición, prompts)
- [x] Nivel reconstruido: dos salas + **puerta** colocada (`door.gd`)
- [ ] Apertura de puerta (E) y transición de cámara entre salas — verificar en runtime
- [ ] Pickups colocados + interacción (E) probada
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
**Fase 1 cerrada** ✅ y **Fase 2 en marcha** 🟡. El nivel `test_level` se reconstruyó
como **dos salas + puerta** (graybox limpio) con cámaras fijas dentro de cada sala y
look PSX (320×240). Pendiente inmediato (verificar en runtime): que la puerta abra con
**E** y que la cámara cambie bien al cruzar de sala. Luego: pickups, inventario en juego
y combate contra el enemigo.
