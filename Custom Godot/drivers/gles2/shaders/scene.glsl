/* clang-format off */
[vertex]

#ifdef USE_GLES_OVER_GL
#define mediump
#define highp
#else
precision highp float;
precision highp int;
#endif

#include "stdlib.glsl"

#define SHADER_IS_SRGB true

#define M_PI 3.14159265359

//
// attributes
//

attribute highp vec4 vertex_attrib; // attrib:0
/* clang-format on */
attribute vec3 normal_attrib; // attrib:1

#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP)
attribute vec4 tangent_attrib; // attrib:2
#endif

#ifdef ENABLE_COLOR_INTERP
attribute vec4 color_attrib; // attrib:3
#endif

#ifdef ENABLE_UV_INTERP
attribute vec2 uv_attrib; // attrib:4
#endif

#ifdef ENABLE_UV2_INTERP
attribute vec2 uv2_attrib; // attrib:5
#endif

#ifdef USE_SKELETON

#ifdef USE_SKELETON_SOFTWARE

attribute highp vec4 bone_transform_row_0; // attrib:8
attribute highp vec4 bone_transform_row_1; // attrib:9
attribute highp vec4 bone_transform_row_2; // attrib:10

#else

attribute vec4 bone_ids; // attrib:6
attribute highp vec4 bone_weights; // attrib:7

uniform highp sampler2D bone_transforms; // texunit:-1
uniform ivec2 skeleton_texture_size;

#endif

#endif

#ifdef USE_INSTANCING

attribute highp vec4 instance_xform_row_0; // attrib:8
attribute highp vec4 instance_xform_row_1; // attrib:9
attribute highp vec4 instance_xform_row_2; // attrib:10

attribute highp vec4 instance_color; // attrib:11
attribute highp vec4 instance_custom_data; // attrib:12

#endif

//
// uniforms
//

uniform mat4 camera_matrix;
uniform mat4 camera_inverse_matrix;
uniform mat4 projection_matrix;
uniform mat4 projection_inverse_matrix;

uniform mat4 world_transform;

uniform highp float time;

uniform float normal_mult;

#ifdef RENDER_DEPTH
uniform float light_bias;
uniform float light_normal_bias;
#endif

//
// varyings
//

varying highp vec3 vertex_interp;
varying vec3 normal_interp;

#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP)
varying vec3 tangent_interp;
varying vec3 binormal_interp;
#endif

#ifdef ENABLE_COLOR_INTERP
varying vec4 color_interp;
#endif

#ifdef ENABLE_UV_INTERP
varying vec2 uv_interp;
#endif

#ifdef ENABLE_UV2_INTERP
varying vec2 uv2_interp;
#endif

/* clang-format off */

VERTEX_SHADER_GLOBALS

/* clang-format on */

#ifdef RENDER_DEPTH_DUAL_PARABOLOID

varying highp float dp_clip;
uniform highp float shadow_dual_paraboloid_render_zfar;
uniform highp float shadow_dual_paraboloid_render_side;

#endif

#if defined(USE_SHADOW) && defined(USE_LIGHTING)

#ifdef LIGHT_MODE_DIRECTIONAL
uniform highp sampler2D light_directional_shadow; // texunit:-3
uniform highp vec4 light_split_offsets;
#endif

uniform highp mat4 light_shadow_matrix;
varying highp vec4 shadow_coord;

#if defined(LIGHT_USE_PSSM2) || defined(LIGHT_USE_PSSM4)
uniform highp mat4 light_shadow_matrix2;
varying highp vec4 shadow_coord2;
#endif

#if defined(LIGHT_USE_PSSM4)

uniform highp mat4 light_shadow_matrix3;
uniform highp mat4 light_shadow_matrix4;
varying highp vec4 shadow_coord3;
varying highp vec4 shadow_coord4;

#endif

#endif

#if defined(USE_VERTEX_LIGHTING) && defined(USE_LIGHTING)

varying highp vec3 diffuse_interp;
varying highp vec3 specular_interp;

// general for all lights
uniform vec4 light_color;
uniform float light_specular;

// directional
uniform vec3 light_direction;

// omni
uniform vec3 light_position;

uniform float light_range;
uniform vec4 light_attenuation;

// spot
uniform float light_spot_attenuation;
uniform float light_spot_range;
uniform float light_spot_angle;

void light_compute(
		vec3 N,
		vec3 L,
		vec3 V,
		vec3 light_color,
		vec3 attenuation,
		float roughness) {

//this makes lights behave closer to linear, but then addition of lights looks bad
//better left disabled

//#define SRGB_APPROX(m_var) m_var = pow(m_var,0.4545454545);
/*
#define SRGB_APPROX(m_var) {\
	float S1 = sqrt(m_var);\
	float S2 = sqrt(S1);\
	float S3 = sqrt(S2);\
	m_var = 0.662002687 * S1 + 0.684122060 * S2 - 0.323583601 * S3 - 0.0225411470 * m_var;\
	}
*/
#define SRGB_APPROX(m_var)

	float NdotL = dot(N, L);
	float cNdotL = max(NdotL, 0.0); // clamped NdotL
	float NdotV = dot(N, V);
	float cNdotV = max(NdotV, 0.0);

#if defined(DIFFUSE_OREN_NAYAR)
	vec3 diffuse_brdf_NL;
#else
	float diffuse_brdf_NL; // BRDF times N.L for calculating diffuse radiance
#endif

#if defined(DIFFUSE_LAMBERT_WRAP)
	// energy conserving lambert wrap shader
	diffuse_brdf_NL = max(0.0, (NdotL + roughness) / ((1.0 + roughness) * (1.0 + roughness)));

#elif defined(DIFFUSE_OREN_NAYAR)

	{
		// see http://mimosa-pudica.net/improved-oren-nayar.html
		float LdotV = dot(L, V);

		float s = LdotV - NdotL * NdotV;
		float t = mix(1.0, max(NdotL, NdotV), step(0.0, s));

		float sigma2 = roughness * roughness; // TODO: this needs checking
		vec3 A = 1.0 + sigma2 * (-0.5 / (sigma2 + 0.33) + 0.17 * diffuse_color / (sigma2 + 0.13));
		float B = 0.45 * sigma2 / (sigma2 + 0.09);

		diffuse_brdf_NL = cNdotL * (A + vec3(B) * s / t) * (1.0 / M_PI);
	}
#else
	// lambert by default for everything else
	diffuse_brdf_NL = cNdotL * (1.0 / M_PI);
#endif

	SRGB_APPROX(diffuse_brdf_NL)

	diffuse_interp += light_color * diffuse_brdf_NL * attenuation;

	if (roughness > 0.0) {

		// D
		float specular_brdf_NL = 0.0;

#if !defined(SPECULAR_DISABLED)
		//normalized blinn always unless disabled
		vec3 H = normalize(V + L);
		float cNdotH = max(dot(N, H), 0.0);
		float cVdotH = max(dot(V, H), 0.0);
		float cLdotH = max(dot(L, H), 0.0);
		float shininess = exp2(15.0 * (1.0 - roughness) + 1.0) * 0.25;
		float blinn = pow(cNdotH, shininess);
		blinn *= (shininess + 8.0) / (8.0 * 3.141592654);
		specular_brdf_NL = (blinn) / max(4.0 * cNdotV * cNdotL, 0.75);
#endif

		SRGB_APPROX(specular_brdf_NL)
		specular_interp += specular_brdf_NL * light_color * attenuation;
	}
}

#endif

void main() {

	highp vec4 vertex = vertex_attrib;

	mat4 world_matrix = world_transform;

#ifdef USE_INSTANCING
	{
		highp mat4 m = mat4(
				instance_xform_row_0,
				instance_xform_row_1,
				instance_xform_row_2,
				vec4(0.0, 0.0, 0.0, 1.0));
		world_matrix = world_matrix * transpose(m);
	}
#endif

	vec3 normal = normal_attrib * normal_mult;

#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP)
	vec3 tangent = tangent_attrib.xyz;
	tangent *= normal_mult;
	float binormalf = tangent_attrib.a;
	vec3 binormal = normalize(cross(normal, tangent) * binormalf);
#endif

#ifdef ENABLE_COLOR_INTERP
	color_interp = color_attrib;
#ifdef USE_INSTANCING
	color_interp *= instance_color;
#endif
#endif

#ifdef ENABLE_UV_INTERP
	uv_interp = uv_attrib;
#endif

#ifdef ENABLE_UV2_INTERP
	uv2_interp = uv2_attrib;
#endif

#if !defined(SKIP_TRANSFORM_USED) && defined(VERTEX_WORLD_COORDS_USED)
	vertex = world_matrix * vertex;
	normal = normalize((world_matrix * vec4(normal, 0.0)).xyz);
#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP)

	tangent = normalize((world_matrix * vec4(tangent, 0.0)), xyz);
	binormal = normalize((world_matrix * vec4(binormal, 0.0)).xyz);
#endif
#endif

#ifdef USE_SKELETON

	highp mat4 bone_transform = mat4(0.0);

#ifdef USE_SKELETON_SOFTWARE
	// passing the transform as attributes

	bone_transform[0] = vec4(bone_transform_row_0.x, bone_transform_row_1.x, bone_transform_row_2.x, 0.0);
	bone_transform[1] = vec4(bone_transform_row_0.y, bone_transform_row_1.y, bone_transform_row_2.y, 0.0);
	bone_transform[2] = vec4(bone_transform_row_0.z, bone_transform_row_1.z, bone_transform_row_2.z, 0.0);
	bone_transform[3] = vec4(bone_transform_row_0.w, bone_transform_row_1.w, bone_transform_row_2.w, 1.0);

#else
	// look up transform from the "pose texture"
	{

		for (int i = 0; i < 4; i++) {
			ivec2 tex_ofs = ivec2(int(bone_ids[i]) * 3, 0);

			highp mat4 b = mat4(
					texel2DFetch(bone_transforms, skeleton_texture_size, tex_ofs + ivec2(0, 0)),
					texel2DFetch(bone_transforms, skeleton_texture_size, tex_ofs + ivec2(1, 0)),
					texel2DFetch(bone_transforms, skeleton_texture_size, tex_ofs + ivec2(2, 0)),
					vec4(0.0, 0.0, 0.0, 1.0));

			bone_transform += transpose(b) * bone_weights[i];
		}
	}

#endif

	world_matrix = bone_transform * world_matrix;
#endif

#ifdef USE_INSTANCING
	vec4 instance_custom = instance_custom_data;
#else
	vec4 instance_custom = vec4(0.0);

#endif

	mat4 modelview = camera_matrix * world_matrix;
	float roughness = 1.0;

#define world_transform world_matrix

	{
		/* clang-format off */

VERTEX_SHADER_CODE

		/* clang-format on */
	}

	vec4 outvec = vertex;

	// use local coordinates
#if !defined(SKIP_TRANSFORM_USED) && !defined(VERTEX_WORLD_COORDS_USED)
	vertex = modelview * vertex;
	normal = normalize((modelview * vec4(normal, 0.0)).xyz);

#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP)
	tangent = normalize((modelview * vec4(tangent, 0.0)).xyz);
	binormal = normalize((modelview * vec4(binormal, 0.0)).xyz);
#endif
#endif

#if !defined(SKIP_TRANSFORM_USED) && defined(VERTEX_WORLD_COORDS_USED)
	vertex = camera_matrix * vertex;
	normal = normalize((camera_matrix * vec4(normal, 0.0)).xyz);
#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP)
	tangent = normalize((camera_matrix * vec4(tangent, 0.0)).xyz);
	binormal = normalize((camera_matrix * vec4(binormal, 0.0)).xyz);
#endif
#endif

	vertex_interp = vertex.xyz;
	normal_interp = normal;

#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP)
	tangent_interp = tangent;
	binormal_interp = binormal;
#endif

#ifdef RENDER_DEPTH

#ifdef RENDER_DEPTH_DUAL_PARABOLOID

	vertex_interp.z *= shadow_dual_paraboloid_render_side;
	normal_interp.z *= shadow_dual_paraboloid_render_side;

	dp_clip = vertex_interp.z; //this attempts to avoid noise caused by objects sent to the other parabolloid side due to bias

	//for dual paraboloid shadow mapping, this is the fastest but least correct way, as it curves straight edges

	highp vec3 vtx = vertex_interp + normalize(vertex_interp) * light_bias;
	highp float distance = length(vtx);
	vtx = normalize(vtx);
	vtx.xy /= 1.0 - vtx.z;
	vtx.z = (distance / shadow_dual_paraboloid_render_zfar);
	vtx.z = vtx.z * 2.0 - 1.0;

	vertex_interp = vtx;

#else
	float z_ofs = light_bias;
	z_ofs += (1.0 - abs(normal_interp.z)) * light_normal_bias;

	vertex_interp.z -= z_ofs;
#endif //dual parabolloid

#endif //depth

//vertex lighting
#if defined(USE_VERTEX_LIGHTING) && defined(USE_LIGHTING)
	//vertex shaded version of lighting (more limited)
	vec3 L;
	vec3 light_att;

#ifdef LIGHT_MODE_OMNI
	vec3 light_vec = light_position - vertex_interp;
	float light_length = length(light_vec);

	float normalized_distance = light_length / light_range;

	float omni_attenuation = pow(1.0 - normalized_distance, light_attenuation.w);

	vec3 attenuation = vec3(omni_attenuation);
	light_att = vec3(omni_attenuation);

	L = normalize(light_vec);

#endif

#ifdef LIGHT_MODE_SPOT

	vec3 light_rel_vec = light_position - vertex_interp;
	float light_length = length(light_rel_vec);
	float normalized_distance = light_length / light_range;

	float spot_attenuation = pow(1.0 - normalized_distance, light_attenuation.w);
	vec3 spot_dir = light_direction;

	float spot_cutoff = light_spot_angle;

	float scos = max(dot(-normalize(light_rel_vec), spot_dir), spot_cutoff);
	float spot_rim = max(0.0001, (1.0 - scos) / (1.0 - spot_cutoff));

	spot_attenuation *= 1.0 - pow(spot_rim, light_spot_attenuation);

	light_att = vec3(spot_attenuation);
	L = normalize(light_rel_vec);

#endif

#ifdef LIGHT_MODE_DIRECTIONAL
	vec3 light_vec = -light_direction;
	light_att = vec3(1.0); //no base attenuation
	L = normalize(light_vec);
#endif

	diffuse_interp = vec3(0.0);
	specular_interp = vec3(0.0);
	light_compute(normal_interp, L, -normalize(vertex_interp), light_color.rgb, light_att, roughness);

#endif

//shadows (for both vertex and fragment)
#if defined(USE_SHADOW) && defined(USE_LIGHTING)

	vec4 vi4 = vec4(vertex_interp, 1.0);
	shadow_coord = light_shadow_matrix * vi4;

#if defined(LIGHT_USE_PSSM2) || defined(LIGHT_USE_PSSM4)
	shadow_coord2 = light_shadow_matrix2 * vi4;
#endif

#if defined(LIGHT_USE_PSSM4)
	shadow_coord3 = light_shadow_matrix3 * vi4;
	shadow_coord3 = light_shadow_matrix3 * vi4;

#endif

#endif //use shadow and use lighting

	gl_Position = projection_matrix * vec4(vertex_interp, 1.0);
}

/* clang-format off */
[fragment]
#extension GL_ARB_shader_texture_lod : enable

#ifndef GL_ARB_shader_texture_lod
#define texture2DLod(img, coord, lod) texture2D(img, coord)
#define textureCubeLod(img, coord, lod) textureCube(img, coord)
#endif

#ifdef USE_GLES_OVER_GL
#define mediump
#define highp
#else
precision mediump float;
precision highp int;
#endif

#include "stdlib.glsl"

#define M_PI 3.14159265359
#define SHADER_IS_SRGB true

//
// uniforms
//

uniform mat4 camera_matrix;
/* clang-format on */
uniform mat4 camera_inverse_matrix;
uniform mat4 projection_matrix;
uniform mat4 projection_inverse_matrix;

uniform mat4 world_transform;

uniform highp float time;

#ifdef SCREEN_UV_USED
uniform vec2 screen_pixel_size;
#endif

// I think supporting this in GLES2 is difficult
// uniform highp sampler2D depth_buffer;

#if defined(SCREEN_TEXTURE_USED)
uniform highp sampler2D screen_texture; //texunit:-4
#endif

#ifdef USE_RADIANCE_MAP

#define RADIANCE_MAX_LOD 6.0

uniform samplerCube radiance_map; // texunit:-2

uniform mat4 radiance_inverse_xform;

#endif

uniform float bg_energy;

uniform float ambient_sky_contribution;
uniform vec4 ambient_color;
uniform float ambient_energy;

#ifdef USE_LIGHTING

#ifdef USE_VERTEX_LIGHTING

//get from vertex
varying highp vec3 diffuse_interp;
varying highp vec3 specular_interp;

#else
//done in fragment
// general for all lights
uniform vec4 light_color;
uniform float light_specular;

// directional
uniform vec3 light_direction;
// omni
uniform vec3 light_position;

uniform vec4 light_attenuation;

// spot
uniform float light_spot_attenuation;
uniform float light_spot_range;
uniform float light_spot_angle;
#endif

//this is needed outside above if because dual paraboloid wants it
uniform float light_range;

#ifdef USE_SHADOW

uniform highp vec2 shadow_pixel_size;

#if defined(LIGHT_MODE_OMNI) || defined(LIGHT_MODE_SPOT)
uniform highp sampler2D light_shadow_atlas; //texunit:-3
#endif

#ifdef LIGHT_MODE_DIRECTIONAL
uniform highp sampler2D light_directional_shadow; // texunit:-3
uniform highp vec4 light_split_offsets;
#endif

varying highp vec4 shadow_coord;

#if defined(LIGHT_USE_PSSM2) || defined(LIGHT_USE_PSSM4)
varying highp vec4 shadow_coord2;
#endif

#if defined(LIGHT_USE_PSSM4)

varying highp vec4 shadow_coord3;
varying highp vec4 shadow_coord4;

#endif

uniform vec4 light_clamp;

#endif // light shadow

// directional shadow

#endif

//
// varyings
//

varying highp vec3 vertex_interp;
varying vec3 normal_interp;

#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP)
varying vec3 tangent_interp;
varying vec3 binormal_interp;
#endif

#ifdef ENABLE_COLOR_INTERP
varying vec4 color_interp;
#endif

#ifdef ENABLE_UV_INTERP
varying vec2 uv_interp;
#endif

#ifdef ENABLE_UV2_INTERP
varying vec2 uv2_interp;
#endif

varying vec3 view_interp;

vec3 metallic_to_specular_color(float metallic, float specular, vec3 albedo) {
	float dielectric = (0.034 * 2.0) * specular;
	// energy conservation
	return mix(vec3(dielectric), albedo, metallic); // TODO: reference?
}

/* clang-format off */

FRAGMENT_SHADER_GLOBALS

/* clang-format on */

#ifdef RENDER_DEPTH_DUAL_PARABOLOID

varying highp float dp_clip;

#endif

#ifdef USE_LIGHTING

// This returns the G_GGX function divided by 2 cos_theta_m, where in practice cos_theta_m is either N.L or N.V.
// We're dividing this factor off because the overall term we'll end up looks like
// (see, for example, the first unnumbered equation in B. Burley, "Physically Based Shading at Disney", SIGGRAPH 2012):
//
//   F(L.V) D(N.H) G(N.L) G(N.V) / (4 N.L N.V)
//
// We're basically regouping this as
//
//   F(L.V) D(N.H) [G(N.L)/(2 N.L)] [G(N.V) / (2 N.V)]
//
// and thus, this function implements the [G(N.m)/(2 N.m)] part with m = L or V.
//
// The contents of the D and G (G1) functions (GGX) are taken from
// E. Heitz, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs", J. Comp. Graph. Tech. 3 (2) (2014).
// Eqns 71-72 and 85-86 (see also Eqns 43 and 80).

float G_GGX_2cos(float cos_theta_m, float alpha) {
	// Schlick's approximation
	// C. Schlick, "An Inexpensive BRDF Model for Physically-based Rendering", Computer Graphics Forum. 13 (3): 233 (1994)
	// Eq. (19), although see Heitz (2014) the about the problems with his derivation.
	// It nevertheless approximates GGX well with k = alpha/2.
	float k = 0.5 * alpha;
	return 0.5 / (cos_theta_m * (1.0 - k) + k);

	// float cos2 = cos_theta_m * cos_theta_m;
	// float sin2 = (1.0 - cos2);
	// return 1.0 / (cos_theta_m + sqrt(cos2 + alpha * alpha * sin2));
}

float D_GGX(float cos_theta_m, float alpha) {
	float alpha2 = alpha * alpha;
	float d = 1.0 + (alpha2 - 1.0) * cos_theta_m * cos_theta_m;
	return alpha2 / (M_PI * d * d);
}

float G_GGX_anisotropic_2cos(float cos_theta_m, float alpha_x, float alpha_y, float cos_phi, float sin_phi) {
	float cos2 = cos_theta_m * cos_theta_m;
	float sin2 = (1.0 - cos2);
	float s_x = alpha_x * cos_phi;
	float s_y = alpha_y * sin_phi;
	return 1.0 / max(cos_theta_m + sqrt(cos2 + (s_x * s_x + s_y * s_y) * sin2), 0.001);
}

float D_GGX_anisotropic(float cos_theta_m, float alpha_x, float alpha_y, float cos_phi, float sin_phi) {
	float cos2 = cos_theta_m * cos_theta_m;
	float sin2 = (1.0 - cos2);
	float r_x = cos_phi / alpha_x;
	float r_y = sin_phi / alpha_y;
	float d = cos2 + sin2 * (r_x * r_x + r_y * r_y);
	return 1.0 / max(M_PI * alpha_x * alpha_y * d * d, 0.001);
}

float SchlickFresnel(float u) {
	float m = 1.0 - u;
	float m2 = m * m;
	return m2 * m2 * m; // pow(m,5)
}

float GTR1(float NdotH, float a) {
	if (a >= 1.0) return 1.0 / M_PI;
	float a2 = a * a;
	float t = 1.0 + (a2 - 1.0) * NdotH * NdotH;
	return (a2 - 1.0) / (M_PI * log(a2) * t);
}

void light_compute(
		vec3 N,
		vec3 L,
		vec3 V,
		vec3 B,
		vec3 T,
		vec3 light_color,
		vec3 attenuation,
		vec3 diffuse_color,
		vec3 transmission,
		float specular_blob_intensity,
		float roughness,
		float metallic,
		float rim,
		float rim_tint,
		float clearcoat,
		float clearcoat_gloss,
		float anisotropy,
		inout vec3 diffuse_light,
		inout vec3 specular_light) {

//this makes lights behave closer to linear, but then addition of lights looks bad
//better left disabled

//#define SRGB_APPROX(m_var) m_var = pow(m_var,0.4545454545);
/*
#define SRGB_APPROX(m_var) {\
	float S1 = sqrt(m_var);\
	float S2 = sqrt(S1);\
	float S3 = sqrt(S2);\
	m_var = 0.662002687 * S1 + 0.684122060 * S2 - 0.323583601 * S3 - 0.0225411470 * m_var;\
	}
*/
#define SRGB_APPROX(m_var)

#if defined(USE_LIGHT_SHADER_CODE)
	// light is written by the light shader

	vec3 normal = N;
	vec3 albedo = diffuse_color;
	vec3 light = L;
	vec3 view = V;

	/* clang-format off */

LIGHT_SHADER_CODE

	/* clang-format on */

#else
	float NdotL = dot(N, L);
	float cNdotL = max(NdotL, 0.0); // clamped NdotL
	float NdotV = dot(N, V);
	float cNdotV = max(NdotV, 0.0);

	if (metallic < 1.0) {
#if defined(DIFFUSE_OREN_NAYAR)
		vec3 diffuse_brdf_NL;
#else
		float diffuse_brdf_NL; // BRDF times N.L for calculating diffuse radiance
#endif

#if defined(DIFFUSE_LAMBERT_WRAP)
		// energy conserving lambert wrap shader
		diffuse_brdf_NL = max(0.0, (NdotL + roughness) / ((1.0 + roughness) * (1.0 + roughness)));

#elif defined(DIFFUSE_OREN_NAYAR)

		{
			// see http://mimosa-pudica.net/improved-oren-nayar.html
			float LdotV = dot(L, V);

			float s = LdotV - NdotL * NdotV;
			float t = mix(1.0, max(NdotL, NdotV), step(0.0, s));

			float sigma2 = roughness * roughness; // TODO: this needs checking
			vec3 A = 1.0 + sigma2 * (-0.5 / (sigma2 + 0.33) + 0.17 * diffuse_color / (sigma2 + 0.13));
			float B = 0.45 * sigma2 / (sigma2 + 0.09);

			diffuse_brdf_NL = cNdotL * (A + vec3(B) * s / t) * (1.0 / M_PI);
		}

#elif defined(DIFFUSE_TOON)

		diffuse_brdf_NL = smoothstep(-roughness, max(roughness, 0.01), NdotL);

#elif defined(DIFFUSE_BURLEY)

		{

			vec3 H = normalize(V + L);
			float cLdotH = max(0.0, dot(L, H));

			float FD90 = 0.5 + 2.0 * cLdotH * cLdotH * roughness;
			float FdV = 1.0 + (FD90 - 1.0) * SchlickFresnel(cNdotV);
			float FdL = 1.0 + (FD90 - 1.0) * SchlickFresnel(cNdotL);
			diffuse_brdf_NL = (1.0 / M_PI) * FdV * FdL * cNdotL;
			/*
			float energyBias = mix(roughness, 0.0, 0.5);
			float energyFactor = mix(roughness, 1.0, 1.0 / 1.51);
			float fd90 = energyBias + 2.0 * VoH * VoH * roughness;
			float f0 = 1.0;
			float lightScatter = f0 + (fd90 - f0) * pow(1.0 - cNdotL, 5.0);
			float viewScatter = f0 + (fd90 - f0) * pow(1.0 - cNdotV, 5.0);

			diffuse_brdf_NL = lightScatter * viewScatter * energyFactor;
			*/
		}
#else
		// lambert
		diffuse_brdf_NL = cNdotL * (1.0 / M_PI);
#endif

		SRGB_APPROX(diffuse_brdf_NL)

		diffuse_light += light_color * diffuse_color * diffuse_brdf_NL * attenuation;

#if defined(TRANSMISSION_USED)
		diffuse_light += light_color * diffuse_color * (vec3(1.0 / M_PI) - diffuse_brdf_NL) * transmission * attenuation;
#endif

#if defined(LIGHT_USE_RIM)
		float rim_light = pow(max(0.0, 1.0 - cNdotV), max(0.0, (1.0 - roughness) * 16.0));
		diffuse_light += rim_light * rim * mix(vec3(1.0), diffuse_color, rim_tint) * light_color;
#endif
	}

	if (roughness > 0.0) {

		// D

		float specular_brdf_NL;

#if defined(SPECULAR_BLINN)

		//normalized blinn
		vec3 H = normalize(V + L);
		float cNdotH = max(dot(N, H), 0.0);
		float cVdotH = max(dot(V, H), 0.0);
		float cLdotH = max(dot(L, H), 0.0);
		float shininess = exp2(15.0 * (1.0 - roughness) + 1.0) * 0.25;
		float blinn = pow(cNdotH, shininess);
		blinn *= (shininess + 8.0) / (8.0 * 3.141592654);
		specular_brdf_NL = (blinn) / max(4.0 * cNdotV * cNdotL, 0.75);

#elif defined(SPECULAR_PHONG)

		vec3 R = normalize(-reflect(L, N));
		float cRdotV = max(0.0, dot(R, V));
		float shininess = exp2(15.0 * (1.0 - roughness) + 1.0) * 0.25;
		float phong = pow(cRdotV, shininess);
		phong *= (shininess + 8.0) / (8.0 * 3.141592654);
		specular_brdf_NL = (phong) / max(4.0 * cNdotV * cNdotL, 0.75);

#elif defined(SPECULAR_TOON)

		vec3 R = normalize(-reflect(L, N));
		float RdotV = dot(R, V);
		float mid = 1.0 - roughness;
		mid *= mid;
		specular_brdf_NL = smoothstep(mid - roughness * 0.5, mid + roughness * 0.5, RdotV) * mid;

#elif defined(SPECULAR_DISABLED)
		// none..
		specular_brdf_NL = 0.0;
#elif defined(SPECULAR_SCHLICK_GGX)
		// shlick+ggx as default

		vec3 H = normalize(V + L);

		float cNdotH = max(dot(N, H), 0.0);
		float cLdotH = max(dot(L, H), 0.0);

#if defined(LIGHT_USE_ANISOTROPY)

		float aspect = sqrt(1.0 - anisotropy * 0.9);
		float rx = roughness / aspect;
		float ry = roughness * aspect;
		float ax = rx * rx;
		float ay = ry * ry;
		float XdotH = dot(T, H);
		float YdotH = dot(B, H);
		float D = D_GGX_anisotropic(cNdotH, ax, ay, XdotH, YdotH);
		float G = G_GGX_anisotropic_2cos(cNdotL, ax, ay, XdotH, YdotH) * G_GGX_anisotropic_2cos(cNdotV, ax, ay, XdotH, YdotH);

#else
		float alpha = roughness * roughness;
		float D = D_GGX(cNdotH, alpha);
		float G = G_GGX_2cos(cNdotL, alpha) * G_GGX_2cos(cNdotV, alpha);
#endif
		// F
		//float F0 = 1.0;
		//float cLdotH5 = SchlickFresnel(cLdotH);
		//float F = mix(cLdotH5, 1.0, F0);

		specular_brdf_NL = cNdotL * D /* F */ * G;

#endif

		SRGB_APPROX(specular_brdf_NL)
		specular_light += specular_brdf_NL * light_color * specular_blob_intensity * attenuation;

#if defined(LIGHT_USE_CLEARCOAT)
		if (clearcoat_gloss > 0.0) {
#if !defined(SPECULAR_SCHLICK_GGX) && !defined(SPECULAR_BLINN)
			vec3 H = normalize(V + L);
#endif
#if !defined(SPECULAR_SCHLICK_GGX)
			float cNdotH = max(dot(N, H), 0.0);
			float cLdotH = max(dot(L, H), 0.0);
			float cLdotH5 = SchlickFresnel(cLdotH);
#endif
			float Dr = GTR1(cNdotH, mix(.1, .001, clearcoat_gloss));
			float Fr = mix(.04, 1.0, cLdotH5);
			float Gr = G_GGX_2cos(cNdotL, .25) * G_GGX_2cos(cNdotV, .25);

			float specular_brdf_NL = 0.25 * clearcoat * Gr * Fr * Dr * cNdotL;

			specular_light += specular_brdf_NL * light_color * specular_blob_intensity * attenuation;
		}
#endif
	}

#endif //defined(USE_LIGHT_SHADER_CODE)
}

#endif
// shadows

#ifdef USE_SHADOW

#define SAMPLE_SHADOW_TEXEL(p_shadow, p_pos, p_depth) step(p_depth, texture2D(p_shadow, p_pos).r)

float sample_shadow(
		highp sampler2D shadow,
		highp vec2 pos,
		highp float depth) {

#ifdef SHADOW_MODE_PCF_13

	float avg = SAMPLE_SHADOW_TEXEL(shadow, pos, depth);
	avg += SAMPLE_SHADOW_TEXEL(shadow, pos + vec2(shadow_pixel_size.x, 0.0), depth);
	avg += SAMPLE_SHADOW_TEXEL(shadow, pos + vec2(-shadow_pixel_size.x, 0.0), depth);
	avg += SAMPLE_SHADOW_TEXEL(shadow, pos + vec2(0.0, shadow_pixel_size.y), depth);
	avg += SAMPLE_SHADOW_TEXEL(shadow, pos + vec2(0.0, -shadow_pixel_size.y), depth);
	avg += SAMPLE_SHADOW_TEXEL(shadow, pos + vec2(shadow_pixel_size.x, shadow_pixel_size.y), depth);
	avg += SAMPLE_SHADOW_TEXEL(shadow, pos + vec2(-shadow_pixel_size.x, shadow_pixel_size.y), depth);
	avg += SAMPLE_SHADOW_TEXEL(shadow, pos + vec2(shadow_pixel_size.x, -shadow_pixel_size.y), depth);
	avg += SAMPLE_SHADOW_TEXEL(shadow, pos + vec2(-shadow_pixel_size.x, -shadow_pixel_size.y), depth);
	avg += SAMPLE_SHADOW_TEXEL(shadow, pos + vec2(shadow_pixel_size.x * 2.0, 0.0), depth);
	avg += SAMPLE_SHADOW_TEXEL(shadow, pos + vec2(-shadow_pixel_size.x * 2.0, 0.0), depth);
	avg += SAMPLE_SHADOW_TEXEL(shadow, pos + vec2(0.0, shadow_pixel_size.y * 2.0), depth);
	avg += SAMPLE_SHADOW_TEXEL(shadow, pos + vec2(0.0, -shadow_pixel_size.y * 2.0), depth);
	return avg * (1.0 / 13.0);
#endif

#ifdef SHADOW_MODE_PCF_5

	float avg = SAMPLE_SHADOW_TEXEL(shadow, pos, depth);
	avg += SAMPLE_SHADOW_TEXEL(shadow, pos + vec2(shadow_pixel_size.x, 0.0), depth);
	avg += SAMPLE_SHADOW_TEXEL(shadow, pos + vec2(-shadow_pixel_size.x, 0.0), depth);
	avg += SAMPLE_SHADOW_TEXEL(shadow, pos + vec2(0.0, shadow_pixel_size.y), depth);
	avg += SAMPLE_SHADOW_TEXEL(shadow, pos + vec2(0.0, -shadow_pixel_size.y), depth);
	return avg * (1.0 / 5.0);

#endif

#if !defined(SHADOW_MODE_PCF_5) || !defined(SHADOW_MODE_PCF_13)

	return SAMPLE_SHADOW_TEXEL(shadow, pos, depth);
#endif
}

#endif

void main() {

#ifdef RENDER_DEPTH_DUAL_PARABOLOID

	if (dp_clip > 0.0)
		discard;
#endif
	highp vec3 vertex = vertex_interp;
	vec3 albedo = vec3(1.0);
	vec3 transmission = vec3(0.0);
	float metallic = 0.0;
	float specular = 0.5;
	vec3 emission = vec3(0.0);
	float roughness = 1.0;
	float rim = 0.0;
	float rim_tint = 0.0;
	float clearcoat = 0.0;
	float clearcoat_gloss = 0.0;
	float anisotropy = 0.0;
	vec2 anisotropy_flow = vec2(1.0, 0.0);

	float alpha = 1.0;
	float side = 1.0;

#if defined(ENABLE_AO)
	float ao = 1.0;
	float ao_light_affect = 0.0;
#endif

#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP)
	vec3 binormal = normalize(binormal_interp) * side;
	vec3 tangent = normalize(tangent_interp) * side;
#else
	vec3 binormal = vec3(0.0);
	vec3 tangent = vec3(0.0);
#endif
	vec3 normal = normalize(normal_interp) * side;

#if defined(ENABLE_NORMALMAP)
	vec3 normalmap = vec3(0.5);
#endif
	float normaldepth = 1.0;

#ifdef ALPHA_SCISSOR_USED
	float alpha_scissor = 0.5;
#endif

#ifdef SCREEN_UV_USED
	vec2 screen_uv = gl_FragCoord.xy * screen_pixel_size;
#endif

	{
		/* clang-format off */

FRAGMENT_SHADER_CODE

		/* clang-format on */
	}

#if defined(ENABLE_NORMALMAP)
	normalmap.xy = normalmap.xy * 2.0 - 1.0;
	normalmap.z = sqrt(max(0.0, 1.0 - dot(normalmap.xy, normalmap.xy)));

	// normal = normalize(mix(normal_interp, tangent * normalmap.x + binormal * normalmap.y + normal * normalmap.z, normaldepth)) * side;
	normal = normalmap;
#endif

	normal = normalize(normal);

	vec3 N = normal;

	vec3 specular_light = vec3(0.0, 0.0, 0.0);
	vec3 diffuse_light = vec3(0.0, 0.0, 0.0);
	vec3 ambient_light = vec3(0.0, 0.0, 0.0);

	vec3 eye_position = -normalize(vertex_interp);

#ifdef ALPHA_SCISSOR_USED
	if (alpha < alpha_scissor) {
		discard;
	}
#endif

#ifdef BASE_PASS
	//none
#ifdef USE_RADIANCE_MAP

	vec3 ref_vec = reflect(-eye_position, N);
	ref_vec = normalize((radiance_inverse_xform * vec4(ref_vec, 0.0)).xyz);

	ref_vec.z *= -1.0;

	specular_light = textureCubeLod(radiance_map, ref_vec, roughness * RADIANCE_MAX_LOD).xyz * bg_energy;

	{
		vec3 ambient_dir = normalize((radiance_inverse_xform * vec4(normal, 0.0)).xyz);
		vec3 env_ambient = textureCubeLod(radiance_map, ambient_dir, RADIANCE_MAX_LOD).xyz * bg_energy;

		ambient_light = mix(ambient_color.rgb, env_ambient, ambient_sky_contribution);
	}

#else

	ambient_light = ambient_color.rgb;

#endif

	ambient_light *= ambient_energy;

#endif //BASE PASS

//
// Lighting
//
#ifdef USE_LIGHTING

#ifndef USE_VERTEX_LIGHTING
	vec3 L;
#endif
	vec3 light_att = vec3(1.0);

#ifdef LIGHT_MODE_OMNI

#ifndef USE_VERTEX_LIGHTING
	vec3 light_vec = light_position - vertex;
	float light_length = length(light_vec);

	float normalized_distance = light_length / light_range;

	float omni_attenuation = pow(1.0 - normalized_distance, light_attenuation.w);

	light_att = vec3(omni_attenuation);
	L = normalize(light_vec);

#endif

#ifdef USE_SHADOW
	{
		highp vec3 splane = shadow_coord.xyz;
		float shadow_len = length(splane);

		splane = normalize(splane);

		vec4 clamp_rect = light_clamp;

		if (splane.z >= 0.0) {
			splane.z += 1.0;

			clamp_rect.y += clamp_rect.w;
		} else {
			splane.z = 1.0 - splane.z;
		}

		splane.xy /= splane.z;
		splane.xy = splane.xy * 0.5 + 0.5;
		splane.z = shadow_len / light_range;

		splane.xy = clamp_rect.xy + splane.xy * clamp_rect.zw;

		float shadow = sample_shadow(light_shadow_atlas, splane.xy, splane.z);

		light_att *= shadow;
	}
#endif

#endif //type omni

#ifdef LIGHT_MODE_DIRECTIONAL

#ifndef USE_VERTEX_LIGHTING
	vec3 light_vec = -light_direction;
	L = normalize(light_vec);
#endif
	float depth_z = -vertex.z;

#ifdef USE_SHADOW
	{
#ifdef LIGHT_USE_PSSM4
		if (depth_z < light_split_offsets.w) {
#elif defined(LIGHT_USE_PSSM2)
		if (depth_z < light_split_offsets.y) {
#else
		if (depth_z < light_split_offsets.x) {
#endif //pssm2

			vec3 pssm_coord;
			float pssm_fade = 0.0;

#ifdef LIGHT_USE_PSSM_BLEND
			float pssm_blend;
			vec3 pssm_coord2;
			bool use_blend = true;
#endif

#ifdef LIGHT_USE_PSSM4
			if (depth_z < light_split_offsets.y) {
				if (depth_z < light_split_offsets.x) {
					highp vec4 splane = shadow_coord;
					pssm_coord = splane.xyz / splane.w;

#ifdef LIGHT_USE_PSSM_BLEND
					splane = shadow_coord2;
					pssm_coord2 = splane.xyz / splane.w;

					pssm_blend = smoothstep(0.0, light_split_offsets.x, depth_z);
#endif
				} else {
					highp vec4 splane = shadow_coord2;
					pssm_coord = splane.xyz / splane.w;

#ifdef LIGHT_USE_PSSM_BLEND
					splane = shadow_coord3;
					pssm_coord2 = splane.xyz / splane.w;

					pssm_blend = smoothstep(light_split_offsets.x, light_split_offsets.y, depth_z);
#endif
				}
			} else {
				if (depth_z < light_split_offsets.z) {

					highp vec4 splane = shadow_coord3;
					pssm_coord = splane.xyz / splane.w;

#if defined(LIGHT_USE_PSSM_BLEND)
					splane = shadow_coord4;
					pssm_coord2 = splane.xyz / splane.w;
					pssm_blend = smoothstep(light_split_offsets.y, light_split_offsets.z, depth_z);
#endif

				} else {

					highp vec4 splane = shadow_coord4;
					pssm_coord = splane.xyz / splane.w;
					pssm_fade = smoothstep(light_split_offsets.z, light_split_offsets.w, depth_z);

#if defined(LIGHT_USE_PSSM_BLEND)
					use_blend = false;
#endif
				}
			}

#endif // LIGHT_USE_PSSM4

#ifdef LIGHT_USE_PSSM2
			if (depth_z < light_split_offsets.x) {

				highp vec4 splane = shadow_coord;
				pssm_coord = splane.xyz / splane.w;

#ifdef LIGHT_USE_PSSM_BLEND
				splane = shadow_coord2;
				pssm_coord2 = splane.xyz / splane.w;
				pssm_blend = smoothstep(0.0, light_split_offsets.x, depth_z);
#endif
			} else {
				highp vec4 splane = shadow_coord2;
				pssm_coord = splane.xyz / splane.w;
				pssm_fade = smoothstep(light_split_offsets.x, light_split_offsets.y, depth_z);
#ifdef LIGHT_USE_PSSM_BLEND
				use_blend = false;
#endif
			}

#endif // LIGHT_USE_PSSM2

#if !defined(LIGHT_USE_PSSM4) && !defined(LIGHT_USE_PSSM2)
			{
				highp vec4 splane = shadow_coord;
				pssm_coord = splane.xyz / splane.w;
			}
#endif

			float shadow = sample_shadow(light_directional_shadow, pssm_coord.xy, pssm_coord.z);

#ifdef LIGHT_USE_PSSM_BLEND
			if (use_blend) {
				shadow = mix(shadow, sample_shadow(light_directional_shadow, pssm_coord2.xy, pssm_coord2.z), pssm_blend);
			}
#endif

			light_att *= shadow;
		}
	}
#endif //use shadow

#endif

#ifdef LIGHT_MODE_SPOT

	light_att = vec3(1.0);

#ifndef USE_VERTEX_LIGHTING

	vec3 light_rel_vec = light_position - vertex;
	float light_length = length(light_rel_vec);
	float normalized_distance = light_length / light_range;

	float spot_attenuation = pow(1.0 - normalized_distance, light_attenuation.w);
	vec3 spot_dir = light_direction;

	float spot_cutoff = light_spot_angle;

	float scos = max(dot(-normalize(light_rel_vec), spot_dir), spot_cutoff);
	float spot_rim = max(0.0001, (1.0 - scos) / (1.0 - spot_cutoff));

	spot_attenuation *= 1.0 - pow(spot_rim, light_spot_attenuation);

	light_att = vec3(spot_attenuation);

	L = normalize(light_rel_vec);

#endif

#ifdef USE_SHADOW
	{
		highp vec4 splane = shadow_coord;
		splane.xyz /= splane.w;

		float shadow = sample_shadow(light_shadow_atlas, splane.xy, splane.z);
		light_att *= shadow;
	}
#endif

#endif

#ifdef USE_VERTEX_LIGHTING
	//vertex lighting

	specular_light += specular_interp * specular * light_att;
	diffuse_light += diffuse_interp * albedo * light_att;

#else
	//fragment lighting
	light_compute(
			normal,
			L,
			eye_position,
			binormal,
			tangent,
			light_color.xyz,
			light_att,
			albedo,
			transmission,
			specular * light_specular,
			roughness,
			metallic,
			rim,
			rim_tint,
			clearcoat,
			clearcoat_gloss,
			anisotropy,
			diffuse_light,
			specular_light);

#endif //vertex lighting

#endif //USE_LIGHTING
	//compute and merge

#ifndef RENDER_DEPTH

#ifdef SHADELESS

	gl_FragColor = vec4(albedo, alpha);
#else

	ambient_light *= albedo;

#if defined(ENABLE_AO)
	ambient_light *= ao;
	ao_light_affect = mix(1.0, ao, ao_light_affect);
	specular_light *= ao_light_affect;
	diffuse_light *= ao_light_affect;
#endif

	diffuse_light *= 1.0 - metallic;
	ambient_light *= 1.0 - metallic;

	// environment BRDF approximation

	// TODO shadeless
	{
		const vec4 c0 = vec4(-1.0, -0.0275, -0.572, 0.022);
		const vec4 c1 = vec4(1.0, 0.0425, 1.04, -0.04);
		vec4 r = roughness * c0 + c1;
		float ndotv = clamp(dot(normal, eye_position), 0.0, 1.0);
		float a004 = min(r.x * r.x, exp2(-9.28 * ndotv)) * r.x + r.y;
		vec2 AB = vec2(-1.04, 1.04) * a004 + r.zw;

		vec3 specular_color = metallic_to_specular_color(metallic, specular, albedo);
		specular_light *= AB.x * specular_color + AB.y;
	}

	gl_FragColor = vec4(ambient_light + diffuse_light + specular_light, alpha);
	// gl_FragColor = vec4(normal, 1.0);

#endif //unshaded

#endif // not RENDER_DEPTH
}
