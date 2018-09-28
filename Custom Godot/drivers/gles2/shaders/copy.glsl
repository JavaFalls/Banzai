/* clang-format off */
[vertex]

#ifdef USE_GLES_OVER_GL
#define mediump
#define highp
#else
precision mediump float;
precision mediump int;
#endif

attribute highp vec4 vertex_attrib; // attrib:0
/* clang-format on */

#if defined(USE_CUBEMAP) || defined(USE_PANORAMA)
attribute vec3 cube_in; // attrib:4
#else
attribute vec2 uv_in; // attrib:4
#endif

attribute vec2 uv2_in; // attrib:5

#if defined(USE_CUBEMAP) || defined(USE_PANORAMA)
varying vec3 cube_interp;
#else
varying vec2 uv_interp;
#endif
varying vec2 uv2_interp;

#ifdef USE_COPY_SECTION
uniform vec4 copy_section;
#endif

void main() {

#if defined(USE_CUBEMAP) || defined(USE_PANORAMA)
	cube_interp = cube_in;
#else
	uv_interp = uv_in;
#endif

	uv2_interp = uv2_in;
	gl_Position = vertex_attrib;

#ifdef USE_COPY_SECTION
	uv_interp = copy_section.xy + uv_interp * copy_section.zw;
	gl_Position.xy = (copy_section.xy + (gl_Position.xy * 0.5 + 0.5) * copy_section.zw) * 2.0 - 1.0;
#endif
}

/* clang-format off */
[fragment]

#define M_PI 3.14159265359

#ifdef USE_GLES_OVER_GL
#define mediump
#define highp
#else
precision mediump float;
precision mediump int;
#endif

#if defined(USE_CUBEMAP) || defined(USE_PANORAMA)
varying vec3 cube_interp;
#else
varying vec2 uv_interp;
#endif
/* clang-format on */

#ifdef USE_CUBEMAP
uniform samplerCube source_cube; // texunit:0
#else
uniform sampler2D source; // texunit:0
#endif

varying vec2 uv2_interp;

#ifdef USE_MULTIPLIER
uniform float multiplier;
#endif

#ifdef USE_CUSTOM_ALPHA
uniform float custom_alpha;
#endif

#if defined(USE_PANORAMA) || defined(USE_ASYM_PANO)

vec4 texturePanorama(sampler2D pano, vec3 normal) {

	vec2 st = vec2(
			atan(normal.x, normal.z),
			acos(normal.y));

	if (st.x < 0.0)
		st.x += M_PI * 2.0;

	st /= vec2(M_PI * 2.0, M_PI);

	return texture2D(pano, st);
}

#endif

void main() {

#ifdef USE_PANORAMA

	vec4 color = texturePanorama(source, normalize(cube_interp));

#elif defined(USE_CUBEMAP)
	vec4 color = textureCube(source_cube, normalize(cube_interp));
#else
	vec4 color = texture2D(source, uv_interp);
#endif

#ifdef USE_NO_ALPHA
	color.a = 1.0;
#endif

#ifdef USE_CUSTOM_ALPHA
	color.a = custom_alpha;
#endif

#ifdef USE_MULTIPLIER
	color.rgb *= multiplier;
#endif

	gl_FragColor = color;
}
