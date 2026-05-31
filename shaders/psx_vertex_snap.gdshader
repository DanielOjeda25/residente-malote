// psx_vertex_snap.gdshader
// Shader de vértice PS1: vertex snapping + affine texture mapping + color depth reduction
// Aplicar como material en un ShaderMaterial a todos los MeshInstance3D del nivel

shader_type spatial;
render_mode unshaded, vertex_lighting, skip_vertex_transform;

// Controles
uniform float snap_intensity : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float resolution : hint_range(32.0, 512.0, 1.0) = 160.0;
uniform float color_depth : hint_range(2.0, 32.0, 1.0) = 16.0;
uniform float affine_intensity : hint_range(0.0, 1.0, 0.01) = 0.8;
uniform sampler2D albedo_texture : source_color;
uniform vec4 albedo_color : source_color = vec4(1.0);

// Fog PS1
uniform bool fog_enabled = true;
uniform vec4 fog_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float fog_start : hint_range(0.0, 50.0) = 5.0;
uniform float fog_end : hint_range(1.0, 100.0) = 20.0;

varying float vertex_distance;
varying vec3 vertex_view_pos;

void vertex() {
	// Transform al view space
	vec4 view_pos = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vertex_view_pos = view_pos.xyz;

	// Proyección
	vec4 clip_pos = PROJECTION_MATRIX * view_pos;

	// === VERTEX SNAPPING (PS1 jitter) ===
	if (snap_intensity > 0.0) {
		// Convertir a coordenadas de pantalla
		vec2 screen_pos = clip_pos.xy / clip_pos.w;
		// Snap a grid de resolución baja
		float grid = resolution * (1.0 - snap_intensity * 0.5);
		screen_pos = floor(screen_pos * grid + 0.5) / grid;
		// Volver a clip space
		clip_pos.xy = screen_pos * clip_pos.w;
	}

	POSITION = clip_pos;

	// Distancia para fog
	vertex_distance = -view_pos.z;

	// === AFFINE TEXTURE MAPPING ===
	// En PS1, las texturas no tenían corrección de perspectiva
	if (affine_intensity > 0.0) {
		float w = mix(1.0, clip_pos.w, affine_intensity);
		UV = UV * w;
	}
}

void fragment() {
	// Recuperar UV con affine mapping
	vec2 uv = UV;
	if (affine_intensity > 0.0) {
		// Nota: en fragment, el UV ya está interpolado "incorrectamente"
		// lo que produce el efecto de affine texture mapping deseado
	}

	// Muestrear textura con filtrado nearest (configurar en el import de la textura)
	vec4 tex_color = texture(albedo_texture, uv) * albedo_color;

	// === REDUCCIÓN DE PROFUNDIDAD DE COLOR ===
	vec3 color = tex_color.rgb;
	color = floor(color * color_depth) / color_depth;

	// === FOG PS1 ===
	if (fog_enabled) {
		float fog_factor = clamp((vertex_distance - fog_start) / (fog_end - fog_start), 0.0, 1.0);
		color = mix(color, fog_color.rgb, fog_factor);
	}

	ALBEDO = color;
	ALPHA = tex_color.a;
}
