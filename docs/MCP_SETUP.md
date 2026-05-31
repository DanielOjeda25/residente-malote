# Puesta en marcha del MCP (Godot AI) en una máquina nueva

Pasos para que el agente IA pueda controlar el editor de Godot vía MCP
(p. ej. al clonar el repo en el notebook).

## 1. Prerequisitos (instalar una vez por máquina)
| Herramienta | Para qué | Instalación (Windows) |
|-------------|----------|------------------------|
| **Godot 4.6+** | el editor / el juego | https://godotengine.org |
| **Node.js LTS** | requerido por Claude Code | https://nodejs.org |
| **Claude Code** | el agente | `npm install -g @anthropic-ai/claude-code` |
| **uv** | ⚠️ el plugin lo usa para **levantar el server MCP** | `irm https://astral.sh/uv/install.ps1 \| iex` |
| **git** | clonar / sincronizar | https://git-scm.com |

> Sin **uv** el plugin no puede arrancar el server MCP y el agente no tendrá
> herramientas de Godot. Es el requisito que más se olvida.

## 2. Clonar y abrir
```powershell
git clone https://github.com/DanielOjeda25/residente-malote.git
cd residente-malote
```
Abre el proyecto en Godot. El plugin **"Godot AI" ya viene habilitado** en
`project.godot` y el `.mcp.json` ya está en el repo.
- Si el plugin NO estuviera activo: `Project → Project Settings → Plugins` → activar **Godot AI**.

## 3. Arrancar el MCP
1. Con Godot abierto, el plugin levanta el server solo en `http://127.0.0.1:8000/mcp`.
   En el dock **"Godot AI"** debe verse **"Conectado"** (verde).
2. (Solo la 1.ª vez en esa máquina) registra el cliente: en el dock, botón
   **"Configure all"** (o la fila "Claude Code"). Alternativa por terminal:
   ```powershell
   claude mcp add --scope user --transport http godot-ai http://127.0.0.1:8000/mcp
   ```
   El repo ya trae `.mcp.json` (scope proyecto), así que normalmente no hace falta.
3. En **otra** terminal, dentro de la carpeta del proyecto:
   ```powershell
   claude
   ```

## 4. Verificar la conexión
- `claude mcp list` → debe mostrar `godot-ai ... ✓ Connected`.
- O pídele al agente: *"¿qué nodos hay en la escena actual?"*. Si lo lee, está conectado.

## 5. Reglas y problemas comunes
- **Orden de arranque:** Godot abierto + plugin activo **antes** de lanzar `claude`.
  Si abres Godot/plugin después, el agente no carga las herramientas → reinicia la sesión de `claude`.
- Si **reinicias Godot**, reinicia también la sesión de `claude`.
- Error **"Unable to connect"** en las herramientas = Godot cerrado o plugin caído → reabre Godot.
- El server **vive dentro del editor**: si cierras Godot, el agente se queda sin "manos".
- El botón "Configure all" registra todos los clientes detectados (Gemini, Cursor…), no solo
  Claude. Es inofensivo; ignora los que no uses (p. ej. *"Kimi Code — not found"*).
