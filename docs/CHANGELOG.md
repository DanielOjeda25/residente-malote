# CHANGELOG — Pueblo Muerto

Bitácora de cambios por sesión. Lo más reciente arriba. Añade una entrada antes
de cada `push` para que la otra máquina (y el agente) sepa qué cambió.

Formato: `## [fecha] — título` + lista de cambios.

---

## [2026-06-01] — Rebuild del nivel: dos salas + puerta (graybox limpio)

Se rehízo `test_level.tscn` desde cero para limpiar parches acumulados.
- **Dos salas 8×8** (sala A spawn / sala B enemigo) unidas por un **muro divisorio
  con puerta** (`door.gd`, se abre con E, sin llave). Suelo, 4 paredes y **techo**
  sólidos y cerrados (sin "ver a través").
- **Puerta** con material propio marrón (`psx_material_door.tres`) para distinguirla.
- Player y enemigo apoyados en el suelo (y=1).
- 2 cámaras fijas RE, **dentro** de cada sala (bug corregido: las cámaras son hijas de
  su zona → sus posiciones son LOCALES; antes quedaban fuera de la sala). FOV 55.
- 2 `OmniLight3D` interiores + niebla ambiental. Snapping del entorno bajado a 0.2
  (menos deformación en superficies grandes).
- ⚠️ Pendiente de verificar en runtime por el autor: apertura de la puerta (E) y la
  transición de cámara entre salas. (Docs detalladas pendientes; commit de respaldo.)

---

## [2026-06-01] — Niebla unificada al entorno (deja de "cortar" al enemigo)

- Problema: había **doble niebla** — la del `WorldEnvironment` (ya existía, color casi
  negro) Y la per-material del shader PSX (mezcla cada objeto a negro por distancia). La
  del shader hacía que el enemigo se viera "cortado" contra el fondo oscuro.
- Quitada la niebla del shader en los 3 materiales (`fog_enabled=false` en
  `psx_material.tres`, `psx_material_player.tres`, `psx_material_enemy.tres`).
- Reemplazado el `Environment` del nivel por uno con niebla ambiental aclarada y sin
  volumétrica: `fog_light_color ≈ (0.3,0.3,0.36)`, `fog_density=0.03`,
  `volumetric_fog_enabled=false` (cielo procedural y ambiente conservados). Ahora la
  niebla es global y uniforme (atmósfera del mapa), no recorta objetos.
- Verificado: el fondo del callejón es bruma gris en vez de vacío negro; el enemigo se
  lee a media distancia.

---

## [2026-06-01] — Cámaras recolocadas estilo RE (investigación + ambas zonas)

Investigado cómo posicionaba RE clásico sus cámaras fijas (fondos 2D pre-renderizados;
cámaras en esquina alta, picado moderado ~15–35°, vista 3/4 diagonal, personaje a
~1/4–1/3 de pantalla, encuadre que oculta/revela para tensión). Aplicado a ambas zonas,
aprovechando los muros de 5 m, y evitando el picado "satelital":
- **Plaza (Zona 1)**: `(1.8, 3.6, 7)`, rot ≈ (−28°, +18°, 0). Esquina alta junto a la
  entrada, mirando en diagonal por el pasillo (−Z): player en primer plano, muros que
  convergen, enemigo al fondo.
- **Callejón (Zona 2)**: `(−1.8, 3.8, 1)`, rot ≈ (−30°, −18°, 0). Esquina opuesta, plano
  3/4 claustrofóbico hacia el callejón sin salida. También mira a −Z → sin inversión de
  control entre zonas.
- Ambas verificadas en runtime a 320×240.

---

## [2026-06-01] — Look PSX: resolución baja 320×240 + shader en el entorno

### Render a baja resolución (lo que de verdad da el look PS1)
- Project Settings → `display/window/stretch/mode = "viewport"`, `aspect = "keep"`.
- Resolución base de render: `viewport_width=320`, `viewport_height=240`.
- Ventana escalada 4×: `window_width_override=1280`, `window_height_override=960`.
- Verificado en runtime: el framebuffer del juego es nativo 320×240 → todo el juego
  (mundo, player, enemigo, HUD) se pixela y escala. Look PS1 activo.

### Shader PSX en el entorno
- `psx_material.tres` aplicado además a **WallLeft, WallRight, WallBack** (antes solo
  el suelo). Suelo + paredes con vertex-snap + affine + reducción de color + fog.
- Player y enemigo conservan sus materiales propios (blanco/rojo); se pixelan por el
  viewport pero aún NO llevan el shader PSX (ver pendientes).

### HUD reescalado para 320×240
- El HUD estaba dimensionado para ~1152×648 (barra de vida de 200 px = 62% del ancho
  a 320). Rediseñado compacto en `scenes/ui/hud.tscn`: barra de vida 88×10 arriba-izq
  (sin %), `AMMO` arriba-der (font 11), prompt de interacción y caja de mensajes
  centrados abajo con fuentes pequeñas. Verificado a 320×240.

### "Choque invisible" al moverse → muros más altos
- Diagnóstico: el pasillo mide 4 m de ancho (muros con cara interior en x=±2.0); el
  player (cápsula radio 0.3) se detiene en x=±1.7. Como la cámara "plaza" está casi
  pegada al muro derecho, ese muro no entraba en cuadro y el tope parecía "invisible".
  Era geometría real, no un bug.
- Solución elegida (mantener el ancho): **subir los muros de 3 m a 5 m** para que entren
  mejor en cuadro y el límite se lea. Hecho escalando WallLeft/Right/Back en Y (×1.6667)
  y subiendo su `position.y` a 2.5 (base en el suelo). Verificado: el muro lateral ahora
  se ve desde la cámara de la plaza.

### Shader PSX en personajes + sombreado por vértice (cierra el look base)
- Shader `psx_vertex_snap.gdshader`: quitado `unshaded`, ahora `render_mode vertex_lighting,
  skip_vertex_transform`. Añadida la transformación de `NORMAL` a view space en el vertex
  (obligatoria con `skip_vertex_transform` para que la luz por vértice funcione). El entorno
  ya no se ve plano: los muros tienen gradientes de luz.
- Creadas 2 variantes del material: `psx_material_player.tres` (blanco) y
  `psx_material_enemy.tres` (rojo), asignadas como `material_override` en los
  `MeshInstance3D` de `player.tscn` y `enemy_human.tscn`. Player y enemigo ahora tienen
  vertex-jitter + fog coherentes, manteniendo su color.
- Verificado en runtime (320×240): shader compila sin errores (logs game/editor limpios).

### Pendiente opcional (NO bloquea Fase 1)
- `psx_dither.gdshader` (no creado) y ajuste fino de niebla/iluminación nocturna.

---

## [2026-05-31] — Pulido de cámaras fijas estilo RE1

### Cámaras (`test_level`)
- Iteración asistida (descartada): se probó plaza cenital −55° (se veía "satelital") y
  luego esquina baja −18°. Valores finales elegidos manualmente por el autor (abajo).
- **Cámara "plaza" (Zona 1)** — ángulo final del autor: `(1.7, 1.5, 4.85)`,
  rot ≈ (pitch −33°, yaw +32°, roll −1°). Esquina baja mirando por el pasillo hacia el
  fondo (`−Z`). También se corrigió el bug previo: estaba casi cenital.
- **Cámara "callejón" (Zona 2)** — ángulo final del autor: `(−0.64, 2.53, −3.09)`,
  rot ≈ (pitch −48°, yaw −149°, roll +5°). Mira **hacia la entrada (`+Z`)**.
  (Bug previo corregido: antes estaba en `(5, …)`, fuera del muro derecho, con la pared
  tapando la vista.)
- ⚠️ **Nota de control:** plaza mira a `−Z` y callejón a `+Z` (sentidos opuestos). Con
  movimiento relativo a cámara, mantener W al cruzar z=0 puede causar *rebote* entre
  ambas cámaras (clásico RE1 + control moderno). Mitigación futura si molesta: buffer
  de input direccional ~0.3 s al cambiar de cámara.
- `zone_name` personalizados: `"plaza"` y `"callejon"` (antes ambos `"zona_default"`).

### Verificación
- Confirmado en runtime (ejecutando el juego + capturas) el encuadre de cada cámara.
- **Transición bidireccional:** los `BoxShape3D` de ambas zonas (4×3×7) se tocan
  exactamente en z=0 sin hueco (Zona 1: z∈[0,+7]; Zona 2: z∈[−7,0]). No requería arreglo.

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
