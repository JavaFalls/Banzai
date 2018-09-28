/*************************************************************************/
/*  rasterizer_storage_gles2.cpp                                         */
/*************************************************************************/
/*                       This file is part of:                           */
/*                           GODOT ENGINE                                */
/*                      https://godotengine.org                          */
/*************************************************************************/
/* Copyright (c) 2007-2018 Juan Linietsky, Ariel Manzur.                 */
/* Copyright (c) 2014-2018 Godot Engine contributors (cf. AUTHORS.md)    */
/*                                                                       */
/* Permission is hereby granted, free of charge, to any person obtaining */
/* a copy of this software and associated documentation files (the       */
/* "Software"), to deal in the Software without restriction, including   */
/* without limitation the rights to use, copy, modify, merge, publish,   */
/* distribute, sublicense, and/or sell copies of the Software, and to    */
/* permit persons to whom the Software is furnished to do so, subject to */
/* the following conditions:                                             */
/*                                                                       */
/* The above copyright notice and this permission notice shall be        */
/* included in all copies or substantial portions of the Software.       */
/*                                                                       */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.*/
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                */
/*************************************************************************/

#include "rasterizer_storage_gles2.h"

#include "core/math/transform.h"
#include "core/project_settings.h"
#include "rasterizer_canvas_gles2.h"
#include "rasterizer_scene_gles2.h"
#include "servers/visual/shader_language.h"

GLuint RasterizerStorageGLES2::system_fbo = 0;

/* TEXTURE API */

#define _EXT_COMPRESSED_RGBA_S3TC_DXT1_EXT 0x83F1
#define _EXT_COMPRESSED_RGBA_S3TC_DXT3_EXT 0x83F2
#define _EXT_COMPRESSED_RGBA_S3TC_DXT5_EXT 0x83F3

#define _EXT_ETC1_RGB8_OES 0x8D64

#ifdef GLES_OVER_GL
#define _GL_HALF_FLOAT_OES 0x140B
#else
#define _GL_HALF_FLOAT_OES 0x8D61
#endif

#define _EXT_TEXTURE_CUBE_MAP_SEAMLESS 0x884F

void RasterizerStorageGLES2::bind_quad_array() const {
	glBindBuffer(GL_ARRAY_BUFFER, resources.quadie);
	glVertexAttribPointer(VS::ARRAY_VERTEX, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 4, 0);
	glVertexAttribPointer(VS::ARRAY_TEX_UV, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 4, ((uint8_t *)NULL) + 8);

	glEnableVertexAttribArray(VS::ARRAY_VERTEX);
	glEnableVertexAttribArray(VS::ARRAY_TEX_UV);
}

Ref<Image> RasterizerStorageGLES2::_get_gl_image_and_format(const Ref<Image> &p_image, Image::Format p_format, uint32_t p_flags, Image::Format &r_real_format, GLenum &r_gl_format, GLenum &r_gl_internal_format, GLenum &r_gl_type, bool &r_compressed) const {

	r_gl_format = 0;
	Ref<Image> image = p_image;
	r_compressed = false;
	r_real_format = p_format;

	bool need_decompress = false;

	switch (p_format) {

		case Image::FORMAT_L8: {

			r_gl_internal_format = GL_LUMINANCE;
			r_gl_format = GL_LUMINANCE;
			r_gl_type = GL_UNSIGNED_BYTE;
		} break;
		case Image::FORMAT_LA8: {
			r_gl_internal_format = GL_LUMINANCE_ALPHA;
			r_gl_format = GL_LUMINANCE_ALPHA;
			r_gl_type = GL_UNSIGNED_BYTE;
		} break;
		case Image::FORMAT_R8: {

			r_gl_internal_format = GL_ALPHA;
			r_gl_format = GL_ALPHA;
			r_gl_type = GL_UNSIGNED_BYTE;

		} break;
		case Image::FORMAT_RG8: {

			ERR_EXPLAIN("RG texture not supported");
			ERR_FAIL_V(image);

		} break;
		case Image::FORMAT_RGB8: {

			r_gl_internal_format = GL_RGB;
			r_gl_format = GL_RGB;
			r_gl_type = GL_UNSIGNED_BYTE;

		} break;
		case Image::FORMAT_RGBA8: {

			r_gl_format = GL_RGBA;
			r_gl_internal_format = GL_RGBA;
			r_gl_type = GL_UNSIGNED_BYTE;

		} break;
		case Image::FORMAT_RGBA4444: {

			r_gl_internal_format = GL_RGBA;
			r_gl_format = GL_RGBA;
			r_gl_type = GL_UNSIGNED_SHORT_4_4_4_4;

		} break;
		case Image::FORMAT_RGBA5551: {

			r_gl_internal_format = GL_RGB5_A1;
			r_gl_format = GL_RGBA;
			r_gl_type = GL_UNSIGNED_SHORT_5_5_5_1;

		} break;
		case Image::FORMAT_RF: {
			if (!config.float_texture_supported) {
				ERR_EXPLAIN("R float texture not supported");
				ERR_FAIL_V(image);
			}

			r_gl_internal_format = GL_ALPHA;
			r_gl_format = GL_ALPHA;
			r_gl_type = GL_FLOAT;
		} break;
		case Image::FORMAT_RGF: {
			ERR_EXPLAIN("RG float texture not supported");
			ERR_FAIL_V(image);

		} break;
		case Image::FORMAT_RGBF: {
			if (!config.float_texture_supported) {

				ERR_EXPLAIN("RGB float texture not supported");
				ERR_FAIL_V(image);
			}

			r_gl_internal_format = GL_RGB;
			r_gl_format = GL_RGB;
			r_gl_type = GL_FLOAT;

		} break;
		case Image::FORMAT_RGBAF: {
			if (!config.float_texture_supported) {

				ERR_EXPLAIN("RGBA float texture not supported");
				ERR_FAIL_V(image);
			}

			r_gl_internal_format = GL_RGBA;
			r_gl_format = GL_RGBA;
			r_gl_type = GL_FLOAT;

		} break;
		case Image::FORMAT_RH: {
			need_decompress = true;
		} break;
		case Image::FORMAT_RGH: {
			need_decompress = true;
		} break;
		case Image::FORMAT_RGBH: {
			need_decompress = true;
		} break;
		case Image::FORMAT_RGBAH: {
			need_decompress = true;
		} break;
		case Image::FORMAT_RGBE9995: {
			r_gl_internal_format = GL_RGB;
			r_gl_format = GL_RGB;
			r_gl_type = GL_UNSIGNED_BYTE;

			if (image.is_valid())

				image = image->rgbe_to_srgb();

			return image;

		} break;
		case Image::FORMAT_DXT1: {

			r_compressed = true;
			if (config.s3tc_supported) {
				r_gl_internal_format = _EXT_COMPRESSED_RGBA_S3TC_DXT1_EXT;
				r_gl_format = GL_RGBA;
				r_gl_type = GL_UNSIGNED_BYTE;
			} else {
				need_decompress = true;
			}

		} break;
		case Image::FORMAT_DXT3: {

			if (config.s3tc_supported) {
				r_gl_internal_format = _EXT_COMPRESSED_RGBA_S3TC_DXT3_EXT;
				r_gl_format = GL_RGBA;
				r_gl_type = GL_UNSIGNED_BYTE;
				r_compressed = true;
			} else {
				need_decompress = true;
			}

		} break;
		case Image::FORMAT_DXT5: {

			if (config.s3tc_supported) {
				r_gl_internal_format = _EXT_COMPRESSED_RGBA_S3TC_DXT5_EXT;
				r_gl_format = GL_RGBA;
				r_gl_type = GL_UNSIGNED_BYTE;
				r_compressed = true;
			} else {
				need_decompress = true;
			}

		} break;
		case Image::FORMAT_RGTC_R: {

			need_decompress = true;

		} break;
		case Image::FORMAT_RGTC_RG: {

			need_decompress = true;

		} break;
		case Image::FORMAT_BPTC_RGBA: {

			need_decompress = true;
		} break;
		case Image::FORMAT_BPTC_RGBF: {

			need_decompress = true;
		} break;
		case Image::FORMAT_BPTC_RGBFU: {

			need_decompress = true;
		} break;
		case Image::FORMAT_PVRTC2: {

			need_decompress = true;
		} break;
		case Image::FORMAT_PVRTC2A: {

			need_decompress = true;
		} break;
		case Image::FORMAT_PVRTC4: {

			need_decompress = true;
		} break;
		case Image::FORMAT_PVRTC4A: {

			need_decompress = true;
		} break;
		case Image::FORMAT_ETC: {

			if (config.etc1_supported) {
				r_gl_internal_format = _EXT_ETC1_RGB8_OES;
				r_gl_format = GL_RGBA;
				r_gl_type = GL_UNSIGNED_BYTE;
				r_compressed = true;
			} else {
				need_decompress = true;
			}
		} break;
		case Image::FORMAT_ETC2_R11: {

			need_decompress = true;
		} break;
		case Image::FORMAT_ETC2_R11S: {

			need_decompress = true;
		} break;
		case Image::FORMAT_ETC2_RG11: {

			need_decompress = true;
		} break;
		case Image::FORMAT_ETC2_RG11S: {

			need_decompress = true;
		} break;
		case Image::FORMAT_ETC2_RGB8: {

			need_decompress = true;
		} break;
		case Image::FORMAT_ETC2_RGBA8: {

			need_decompress = true;
		} break;
		case Image::FORMAT_ETC2_RGB8A1: {

			need_decompress = true;
		} break;
		default: {

			ERR_FAIL_V(Ref<Image>());
		}
	}

	if (need_decompress) {

		if (!image.is_null()) {
			image = image->duplicate();
			image->decompress();
			ERR_FAIL_COND_V(image->is_compressed(), image);
			image->convert(Image::FORMAT_RGBA8);
		}

		r_gl_format = GL_RGBA;
		r_gl_internal_format = GL_RGBA;
		r_gl_type = GL_UNSIGNED_BYTE;
		r_real_format = Image::FORMAT_RGBA8;

		return image;
	}

	return p_image;
}

static const GLenum _cube_side_enum[6] = {

	GL_TEXTURE_CUBE_MAP_NEGATIVE_X,
	GL_TEXTURE_CUBE_MAP_POSITIVE_X,
	GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,
	GL_TEXTURE_CUBE_MAP_POSITIVE_Y,
	GL_TEXTURE_CUBE_MAP_NEGATIVE_Z,
	GL_TEXTURE_CUBE_MAP_POSITIVE_Z,

};

RID RasterizerStorageGLES2::texture_create() {

	Texture *texture = memnew(Texture);
	ERR_FAIL_COND_V(!texture, RID());
	glGenTextures(1, &texture->tex_id);
	texture->active = false;
	texture->total_data_size = 0;

	return texture_owner.make_rid(texture);
}

void RasterizerStorageGLES2::texture_allocate(RID p_texture, int p_width, int p_height, int p_depth_3d, Image::Format p_format, VisualServer::TextureType p_type, uint32_t p_flags) {
	GLenum format;
	GLenum internal_format;
	GLenum type;

	bool compressed = false;

	if (p_flags & VS::TEXTURE_FLAG_USED_FOR_STREAMING) {
		p_flags &= ~VS::TEXTURE_FLAG_MIPMAPS; // no mipies for video
	}

	Texture *texture = texture_owner.getornull(p_texture);
	ERR_FAIL_COND(!texture);
	texture->width = p_width;
	texture->height = p_height;
	texture->format = p_format;
	texture->flags = p_flags;
	texture->stored_cube_sides = 0;
	texture->type = p_type;

	switch (p_type) {
		case VS::TEXTURE_TYPE_2D: {
			texture->target = GL_TEXTURE_2D;
			texture->images.resize(1);
		} break;
		case VS::TEXTURE_TYPE_CUBEMAP: {
			texture->target = GL_TEXTURE_CUBE_MAP;
			texture->images.resize(6);
		} break;
		case VS::TEXTURE_TYPE_2D_ARRAY: {
			texture->images.resize(p_depth_3d);
		} break;
		case VS::TEXTURE_TYPE_3D: {
			texture->images.resize(p_depth_3d);
		} break;
		default: {
			ERR_PRINT("Unknown texture type!");
			return;
		}
	}

	Image::Format real_format;
	_get_gl_image_and_format(Ref<Image>(), texture->format, texture->flags, real_format, format, internal_format, type, compressed);

	texture->alloc_width = texture->width;
	texture->alloc_height = texture->height;

	texture->gl_format_cache = format;
	texture->gl_type_cache = type;
	texture->gl_internal_format_cache = internal_format;
	texture->data_size = 0;
	texture->mipmaps = 1;

	texture->compressed = compressed;

	glActiveTexture(GL_TEXTURE0);
	glBindTexture(texture->target, texture->tex_id);

	if (p_flags & VS::TEXTURE_FLAG_USED_FOR_STREAMING) {
		//prealloc if video
		glTexImage2D(texture->target, 0, internal_format, p_width, p_height, 0, format, type, NULL);
	}

	texture->active = true;
}

void RasterizerStorageGLES2::texture_set_data(RID p_texture, const Ref<Image> &p_image, int p_layer) {
	Texture *texture = texture_owner.getornull(p_texture);

	ERR_FAIL_COND(!texture);
	ERR_FAIL_COND(!texture->active);
	ERR_FAIL_COND(texture->render_target);
	ERR_FAIL_COND(texture->format != p_image->get_format());
	ERR_FAIL_COND(p_image.is_null());

	GLenum type;
	GLenum format;
	GLenum internal_format;
	bool compressed = false;

	if (config.keep_original_textures && !(texture->flags & VS::TEXTURE_FLAG_USED_FOR_STREAMING)) {
		texture->images.write[p_layer] = p_image;
	}

	Image::Format real_format;
	Ref<Image> img = _get_gl_image_and_format(p_image, p_image->get_format(), texture->flags, real_format, format, internal_format, type, compressed);

	if (config.shrink_textures_x2 && (p_image->has_mipmaps() || !p_image->is_compressed()) && !(texture->flags & VS::TEXTURE_FLAG_USED_FOR_STREAMING)) {

		texture->alloc_height = MAX(1, texture->alloc_height / 2);
		texture->alloc_width = MAX(1, texture->alloc_width / 2);

		if (texture->alloc_width == img->get_width() / 2 && texture->alloc_height == img->get_height() / 2) {

			img->shrink_x2();
		} else if (img->get_format() <= Image::FORMAT_RGBA8) {

			img->resize(texture->alloc_width, texture->alloc_height, Image::INTERPOLATE_BILINEAR);
		}
	};

	GLenum blit_target = (texture->target == GL_TEXTURE_CUBE_MAP) ? _cube_side_enum[p_layer] : GL_TEXTURE_2D;

	texture->data_size = img->get_data().size();
	PoolVector<uint8_t>::Read read = img->get_data().read();

	glActiveTexture(GL_TEXTURE0);
	glBindTexture(texture->target, texture->tex_id);

	texture->ignore_mipmaps = compressed && !img->has_mipmaps();

	if ((texture->flags & VS::TEXTURE_FLAG_MIPMAPS) && !texture->ignore_mipmaps)
		glTexParameteri(texture->target, GL_TEXTURE_MIN_FILTER, config.use_fast_texture_filter ? GL_LINEAR_MIPMAP_NEAREST : GL_LINEAR_MIPMAP_LINEAR);
	else {
		if (texture->flags & VS::TEXTURE_FLAG_FILTER) {
			glTexParameteri(texture->target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		} else {
			glTexParameteri(texture->target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		}
	}

	if (texture->flags & VS::TEXTURE_FLAG_FILTER) {

		glTexParameteri(texture->target, GL_TEXTURE_MAG_FILTER, GL_LINEAR); // Linear Filtering

	} else {

		glTexParameteri(texture->target, GL_TEXTURE_MAG_FILTER, GL_NEAREST); // raw Filtering
	}

	if (((texture->flags & VS::TEXTURE_FLAG_REPEAT) || (texture->flags & VS::TEXTURE_FLAG_MIRRORED_REPEAT)) && texture->target != GL_TEXTURE_CUBE_MAP) {

		if (texture->flags & VS::TEXTURE_FLAG_MIRRORED_REPEAT) {
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
		} else {
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		}
	} else {

		//glTexParameterf( texture->target, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE );
		glTexParameterf(texture->target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameterf(texture->target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	}

//set swizle for older format compatibility
#ifdef GLES_OVER_GL
	switch (texture->format) {

		case Image::FORMAT_L8: {

		} break;
		case Image::FORMAT_LA8: {

		} break;
		default: {

		} break;
	}
#endif

	int mipmaps = ((texture->flags & VS::TEXTURE_FLAG_MIPMAPS) && img->has_mipmaps()) ? img->get_mipmap_count() + 1 : 1;

	int w = img->get_width();
	int h = img->get_height();

	int tsize = 0;

	for (int i = 0; i < mipmaps; i++) {

		int size, ofs;
		img->get_mipmap_offset_and_size(i, ofs, size);

		if (texture->compressed) {
			glPixelStorei(GL_UNPACK_ALIGNMENT, 4);

			int bw = w;
			int bh = h;

			glCompressedTexImage2D(blit_target, i, internal_format, bw, bh, 0, size, &read[ofs]);
		} else {

			glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
			if (texture->flags & VS::TEXTURE_FLAG_USED_FOR_STREAMING) {
				glTexSubImage2D(blit_target, i, 0, 0, w, h, format, type, &read[ofs]);
			} else {
				glTexImage2D(blit_target, i, internal_format, w, h, 0, format, type, &read[ofs]);
			}
		}

		tsize += size;

		w = MAX(1, w >> 1);
		h = MAX(1, h >> 1);
	}

	info.texture_mem -= texture->total_data_size;
	texture->total_data_size = tsize;
	info.texture_mem += texture->total_data_size;

	// printf("texture: %i x %i - size: %i - total: %i\n", texture->width, texture->height, tsize, info.texture_mem);

	texture->stored_cube_sides |= (1 << p_layer);

	if ((texture->flags & VS::TEXTURE_FLAG_MIPMAPS) && mipmaps == 1 && !texture->ignore_mipmaps && (texture->type != VS::TEXTURE_TYPE_CUBEMAP || texture->stored_cube_sides == (1 << 6) - 1)) {
		//generate mipmaps if they were requested and the image does not contain them
		glGenerateMipmap(texture->target);
	}

	texture->mipmaps = mipmaps;
}

void RasterizerStorageGLES2::texture_set_data_partial(RID p_texture, const Ref<Image> &p_image, int src_x, int src_y, int src_w, int src_h, int dst_x, int dst_y, int p_dst_mip, int p_layer) {
	// TODO
	ERR_PRINT("Not implemented (ask Karroffel to do it :p)");
}

Ref<Image> RasterizerStorageGLES2::texture_get_data(RID p_texture, int p_layer) const {

	Texture *texture = texture_owner.getornull(p_texture);

	ERR_FAIL_COND_V(!texture, Ref<Image>());
	ERR_FAIL_COND_V(!texture->active, Ref<Image>());
	ERR_FAIL_COND_V(texture->data_size == 0 && !texture->render_target, Ref<Image>());

	if (texture->type == VS::TEXTURE_TYPE_CUBEMAP && p_layer < 6 && p_layer >= 0 && !texture->images[p_layer].is_null()) {
		return texture->images[p_layer];
	}

#ifdef GLES_OVER_GL

	Image::Format real_format;
	GLenum gl_format;
	GLenum gl_internal_format;
	GLenum gl_type;
	bool compressed;
	_get_gl_image_and_format(Ref<Image>(), texture->format, texture->flags, real_format, gl_format, gl_internal_format, gl_type, compressed);

	PoolVector<uint8_t> data;

	int data_size = Image::get_image_data_size(texture->alloc_width, texture->alloc_height, real_format, texture->mipmaps > 1 ? -1 : 0);

	data.resize(data_size * 2); //add some memory at the end, just in case for buggy drivers
	PoolVector<uint8_t>::Write wb = data.write();

	glActiveTexture(GL_TEXTURE0);

	glBindTexture(texture->target, texture->tex_id);

	glBindBuffer(GL_PIXEL_PACK_BUFFER, 0);

	for (int i = 0; i < texture->mipmaps; i++) {

		int ofs = 0;
		if (i > 0) {
			ofs = Image::get_image_data_size(texture->alloc_width, texture->alloc_height, real_format, i - 1);
		}

		if (texture->compressed) {
			glPixelStorei(GL_PACK_ALIGNMENT, 4);
			glGetCompressedTexImage(texture->target, i, &wb[ofs]);
		} else {
			glPixelStorei(GL_PACK_ALIGNMENT, 1);
			glGetTexImage(texture->target, i, texture->gl_format_cache, texture->gl_type_cache, &wb[ofs]);
		}
	}

	wb = PoolVector<uint8_t>::Write();

	data.resize(data_size);

	Image *img = memnew(Image(texture->alloc_width, texture->alloc_height, texture->mipmaps > 1 ? true : false, real_format, data));

	return Ref<Image>(img);
#else

	ERR_EXPLAIN("Sorry, It's not possible to obtain images back in OpenGL ES");
	ERR_FAIL_V(Ref<Image>());
#endif
}

void RasterizerStorageGLES2::texture_set_flags(RID p_texture, uint32_t p_flags) {

	Texture *texture = texture_owner.getornull(p_texture);
	ERR_FAIL_COND(!texture);

	bool had_mipmaps = texture->flags & VS::TEXTURE_FLAG_MIPMAPS;

	texture->flags = p_flags;

	glActiveTexture(GL_TEXTURE0);
	glBindTexture(texture->target, texture->tex_id);

	if (((texture->flags & VS::TEXTURE_FLAG_REPEAT) || (texture->flags & VS::TEXTURE_FLAG_MIRRORED_REPEAT)) && texture->target != GL_TEXTURE_CUBE_MAP) {

		if (texture->flags & VS::TEXTURE_FLAG_MIRRORED_REPEAT) {
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
		} else {
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		}
	} else {
		//glTexParameterf( texture->target, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE );
		glTexParameterf(texture->target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameterf(texture->target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	}

	if ((texture->flags & VS::TEXTURE_FLAG_MIPMAPS) && !texture->ignore_mipmaps) {
		if (!had_mipmaps && texture->mipmaps == 1) {
			glGenerateMipmap(texture->target);
		}
		glTexParameteri(texture->target, GL_TEXTURE_MIN_FILTER, config.use_fast_texture_filter ? GL_LINEAR_MIPMAP_NEAREST : GL_LINEAR_MIPMAP_LINEAR);

	} else {
		if (texture->flags & VS::TEXTURE_FLAG_FILTER) {
			glTexParameteri(texture->target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		} else {
			glTexParameteri(texture->target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		}
	}

	if (texture->flags & VS::TEXTURE_FLAG_FILTER) {

		glTexParameteri(texture->target, GL_TEXTURE_MAG_FILTER, GL_LINEAR); // Linear Filtering

	} else {

		glTexParameteri(texture->target, GL_TEXTURE_MAG_FILTER, GL_NEAREST); // raw Filtering
	}
}

uint32_t RasterizerStorageGLES2::texture_get_flags(RID p_texture) const {
	Texture *texture = texture_owner.getornull(p_texture);

	ERR_FAIL_COND_V(!texture, 0);

	return texture->flags;
}

Image::Format RasterizerStorageGLES2::texture_get_format(RID p_texture) const {
	Texture *texture = texture_owner.getornull(p_texture);

	ERR_FAIL_COND_V(!texture, Image::FORMAT_L8);

	return texture->format;
}

VisualServer::TextureType RasterizerStorageGLES2::texture_get_type(RID p_texture) const {
	Texture *texture = texture_owner.getornull(p_texture);

	ERR_FAIL_COND_V(!texture, VS::TEXTURE_TYPE_2D);

	return texture->type;
}

uint32_t RasterizerStorageGLES2::texture_get_texid(RID p_texture) const {
	Texture *texture = texture_owner.getornull(p_texture);

	ERR_FAIL_COND_V(!texture, 0);

	return texture->tex_id;
}

uint32_t RasterizerStorageGLES2::texture_get_width(RID p_texture) const {
	Texture *texture = texture_owner.getornull(p_texture);

	ERR_FAIL_COND_V(!texture, 0);

	return texture->width;
}

uint32_t RasterizerStorageGLES2::texture_get_height(RID p_texture) const {
	Texture *texture = texture_owner.getornull(p_texture);

	ERR_FAIL_COND_V(!texture, 0);

	return texture->height;
}

uint32_t RasterizerStorageGLES2::texture_get_depth(RID p_texture) const {
	Texture *texture = texture_owner.getornull(p_texture);

	ERR_FAIL_COND_V(!texture, 0);

	return texture->depth;
}

void RasterizerStorageGLES2::texture_set_size_override(RID p_texture, int p_width, int p_height, int p_depth) {
	Texture *texture = texture_owner.getornull(p_texture);

	ERR_FAIL_COND(!texture);
	ERR_FAIL_COND(texture->render_target);

	ERR_FAIL_COND(p_width <= 0 || p_width > 16384);
	ERR_FAIL_COND(p_height <= 0 || p_height > 16384);
	//real texture size is in alloc width and height
	texture->width = p_width;
	texture->height = p_height;
}

void RasterizerStorageGLES2::texture_set_path(RID p_texture, const String &p_path) {
	Texture *texture = texture_owner.getornull(p_texture);
	ERR_FAIL_COND(!texture);

	texture->path = p_path;
}

String RasterizerStorageGLES2::texture_get_path(RID p_texture) const {
	Texture *texture = texture_owner.getornull(p_texture);
	ERR_FAIL_COND_V(!texture, "");

	return texture->path;
}

void RasterizerStorageGLES2::texture_debug_usage(List<VS::TextureInfo> *r_info) {
	List<RID> textures;
	texture_owner.get_owned_list(&textures);

	for (List<RID>::Element *E = textures.front(); E; E = E->next()) {

		Texture *t = texture_owner.getornull(E->get());
		if (!t)
			continue;
		VS::TextureInfo tinfo;
		tinfo.path = t->path;
		tinfo.format = t->format;
		tinfo.width = t->alloc_width;
		tinfo.height = t->alloc_height;
		tinfo.depth = 0;
		tinfo.bytes = t->total_data_size;
		r_info->push_back(tinfo);
	}
}

void RasterizerStorageGLES2::texture_set_shrink_all_x2_on_set_data(bool p_enable) {
	config.shrink_textures_x2 = p_enable;
}

void RasterizerStorageGLES2::textures_keep_original(bool p_enable) {
	config.keep_original_textures = p_enable;
}

void RasterizerStorageGLES2::texture_set_proxy(RID p_texture, RID p_proxy) {
	Texture *texture = texture_owner.getornull(p_texture);
	ERR_FAIL_COND(!texture);

	if (texture->proxy) {
		texture->proxy->proxy_owners.erase(texture);
		texture->proxy = NULL;
	}

	if (p_proxy.is_valid()) {
		Texture *proxy = texture_owner.get(p_proxy);
		ERR_FAIL_COND(!proxy);
		ERR_FAIL_COND(proxy == texture);
		proxy->proxy_owners.insert(texture);
		texture->proxy = proxy;
	}
}

void RasterizerStorageGLES2::texture_set_force_redraw_if_visible(RID p_texture, bool p_enable) {

	Texture *texture = texture_owner.getornull(p_texture);
	ERR_FAIL_COND(!texture);

	texture->redraw_if_visible = p_enable;
}

void RasterizerStorageGLES2::texture_set_detect_3d_callback(RID p_texture, VisualServer::TextureDetectCallback p_callback, void *p_userdata) {
	Texture *texture = texture_owner.get(p_texture);
	ERR_FAIL_COND(!texture);

	texture->detect_3d = p_callback;
	texture->detect_3d_ud = p_userdata;
}

void RasterizerStorageGLES2::texture_set_detect_srgb_callback(RID p_texture, VisualServer::TextureDetectCallback p_callback, void *p_userdata) {
	Texture *texture = texture_owner.get(p_texture);
	ERR_FAIL_COND(!texture);

	texture->detect_srgb = p_callback;
	texture->detect_srgb_ud = p_userdata;
}

void RasterizerStorageGLES2::texture_set_detect_normal_callback(RID p_texture, VisualServer::TextureDetectCallback p_callback, void *p_userdata) {
	Texture *texture = texture_owner.get(p_texture);
	ERR_FAIL_COND(!texture);

	texture->detect_normal = p_callback;
	texture->detect_normal_ud = p_userdata;
}

RID RasterizerStorageGLES2::texture_create_radiance_cubemap(RID p_source, int p_resolution) const {

	return RID();
}

RID RasterizerStorageGLES2::sky_create() {
	Sky *sky = memnew(Sky);
	sky->radiance = 0;
	return sky_owner.make_rid(sky);
}

void RasterizerStorageGLES2::sky_set_texture(RID p_sky, RID p_panorama, int p_radiance_size) {
	Sky *sky = sky_owner.getornull(p_sky);
	ERR_FAIL_COND(!sky);

	if (sky->panorama.is_valid()) {
		sky->panorama = RID();
		glDeleteTextures(1, &sky->radiance);
		sky->radiance = 0;
	}

	sky->panorama = p_panorama;
	if (!sky->panorama.is_valid()) {
		return; // the panorama was cleared
	}

	Texture *texture = texture_owner.getornull(sky->panorama);
	if (!texture) {
		sky->panorama = RID();
		ERR_FAIL_COND(!texture);
	}

	// glBindVertexArray(0) and more
	{
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		glDisable(GL_CULL_FACE);
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_SCISSOR_TEST);
		glDisable(GL_BLEND);

		for (int i = 0; i < VS::ARRAY_MAX - 1; i++) {
			glDisableVertexAttribArray(i);
		}
	}

	glActiveTexture(GL_TEXTURE0);
	glBindTexture(texture->target, texture->tex_id);

	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); //need this for proper sampling

	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_2D, resources.radical_inverse_vdc_cache_tex);

	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

	// New cubemap that will hold the mipmaps with different roughness values
	glActiveTexture(GL_TEXTURE2);
	glGenTextures(1, &sky->radiance);
	glBindTexture(GL_TEXTURE_CUBE_MAP, sky->radiance);

	// Now we create a new framebuffer. The new cubemap images will be used as
	// attachements for it, so we can fill them by issuing draw calls.
	GLuint tmp_fb;

	glGenFramebuffers(1, &tmp_fb);
	glBindFramebuffer(GL_FRAMEBUFFER, tmp_fb);

	int size = p_radiance_size;

	int lod = 0;

	shaders.cubemap_filter.set_conditional(CubemapFilterShaderGLES2::USE_SOURCE_PANORAMA, texture->target == GL_TEXTURE_2D);

	shaders.cubemap_filter.bind();

	int mipmaps = 6;

	int mm_level = mipmaps;

	GLenum internal_format = GL_RGBA;
	GLenum format = GL_RGBA;
	GLenum type = GL_UNSIGNED_BYTE; // This is suboptimal... TODO other format for FBO?

	// Set the initial (empty) mipmaps
	while (size >= 1) {

		for (int i = 0; i < 6; i++) {
			glTexImage2D(_cube_side_enum[i], lod, internal_format, size, size, 0, format, type, NULL);
		}

		lod++;

		size >>= 1;
	}

	lod = 0;
	mm_level = mipmaps;

	size = p_radiance_size;

	// now render to the framebuffer, mipmap level for mipmap level
	while (size >= 1) {

		for (int i = 0; i < 6; i++) {
			glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, _cube_side_enum[i], sky->radiance, lod);

			glViewport(0, 0, size, size);

			bind_quad_array();

			shaders.cubemap_filter.set_uniform(CubemapFilterShaderGLES2::FACE_ID, i);

			float roughness = mm_level ? lod / (float)(mipmaps - 1) : 1;
			shaders.cubemap_filter.set_uniform(CubemapFilterShaderGLES2::ROUGHNESS, roughness);

			glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
		}

		size >>= 1;

		mm_level--;

		lod++;
	}

	// restore ranges

	glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	// Framebuffer did its job. thank mr framebuffer
	glBindFramebuffer(GL_FRAMEBUFFER, RasterizerStorageGLES2::system_fbo);
	glDeleteFramebuffers(1, &tmp_fb);
}

/* SHADER API */

RID RasterizerStorageGLES2::shader_create() {

	Shader *shader = memnew(Shader);
	shader->mode = VS::SHADER_SPATIAL;
	shader->shader = &scene->state.scene_shader;
	RID rid = shader_owner.make_rid(shader);
	_shader_make_dirty(shader);
	shader->self = rid;

	return rid;
}

void RasterizerStorageGLES2::_shader_make_dirty(Shader *p_shader) {
	if (p_shader->dirty_list.in_list())
		return;

	_shader_dirty_list.add(&p_shader->dirty_list);
}

void RasterizerStorageGLES2::shader_set_code(RID p_shader, const String &p_code) {

	Shader *shader = shader_owner.getornull(p_shader);
	ERR_FAIL_COND(!shader);

	shader->code = p_code;

	String mode_string = ShaderLanguage::get_shader_type(p_code);
	VS::ShaderMode mode;

	if (mode_string == "canvas_item")
		mode = VS::SHADER_CANVAS_ITEM;
	else if (mode_string == "particles")
		mode = VS::SHADER_PARTICLES;
	else
		mode = VS::SHADER_SPATIAL;

	if (shader->custom_code_id && mode != shader->mode) {
		shader->shader->free_custom_shader(shader->custom_code_id);
		shader->custom_code_id = 0;
	}

	shader->mode = mode;

	// TODO handle all shader types
	if (mode == VS::SHADER_CANVAS_ITEM) {
		shader->shader = &canvas->state.canvas_shader;

	} else if (mode == VS::SHADER_SPATIAL) {
		shader->shader = &scene->state.scene_shader;
	} else {
		return;
	}

	if (shader->custom_code_id == 0) {
		shader->custom_code_id = shader->shader->create_custom_shader();
	}

	_shader_make_dirty(shader);
}

String RasterizerStorageGLES2::shader_get_code(RID p_shader) const {

	const Shader *shader = shader_owner.get(p_shader);
	ERR_FAIL_COND_V(!shader, "");

	return shader->code;
}

void RasterizerStorageGLES2::_update_shader(Shader *p_shader) const {

	_shader_dirty_list.remove(&p_shader->dirty_list);

	p_shader->valid = false;

	p_shader->uniforms.clear();

	ShaderCompilerGLES2::GeneratedCode gen_code;
	ShaderCompilerGLES2::IdentifierActions *actions = NULL;

	switch (p_shader->mode) {

			// TODO

		case VS::SHADER_CANVAS_ITEM: {

			p_shader->canvas_item.blend_mode = Shader::CanvasItem::BLEND_MODE_MIX;

			p_shader->canvas_item.uses_screen_texture = false;
			p_shader->canvas_item.uses_screen_uv = false;
			p_shader->canvas_item.uses_time = false;

			shaders.actions_canvas.render_mode_values["blend_add"] = Pair<int *, int>(&p_shader->canvas_item.blend_mode, Shader::CanvasItem::BLEND_MODE_ADD);
			shaders.actions_canvas.render_mode_values["blend_mix"] = Pair<int *, int>(&p_shader->canvas_item.blend_mode, Shader::CanvasItem::BLEND_MODE_MIX);
			shaders.actions_canvas.render_mode_values["blend_sub"] = Pair<int *, int>(&p_shader->canvas_item.blend_mode, Shader::CanvasItem::BLEND_MODE_SUB);
			shaders.actions_canvas.render_mode_values["blend_mul"] = Pair<int *, int>(&p_shader->canvas_item.blend_mode, Shader::CanvasItem::BLEND_MODE_MUL);
			shaders.actions_canvas.render_mode_values["blend_premul_alpha"] = Pair<int *, int>(&p_shader->canvas_item.blend_mode, Shader::CanvasItem::BLEND_MODE_PMALPHA);

			// shaders.actions_canvas.render_mode_values["unshaded"] = Pair<int *, int>(&p_shader->canvas_item.light_mode, Shader::CanvasItem::LIGHT_MODE_UNSHADED);
			// shaders.actions_canvas.render_mode_values["light_only"] = Pair<int *, int>(&p_shader->canvas_item.light_mode, Shader::CanvasItem::LIGHT_MODE_LIGHT_ONLY);

			shaders.actions_canvas.usage_flag_pointers["SCREEN_UV"] = &p_shader->canvas_item.uses_screen_uv;
			shaders.actions_canvas.usage_flag_pointers["SCREEN_PIXEL_SIZE"] = &p_shader->canvas_item.uses_screen_uv;
			shaders.actions_canvas.usage_flag_pointers["SCREEN_TEXTURE"] = &p_shader->canvas_item.uses_screen_texture;
			shaders.actions_canvas.usage_flag_pointers["TIME"] = &p_shader->canvas_item.uses_time;

			actions = &shaders.actions_canvas;
			actions->uniforms = &p_shader->uniforms;
		} break;

		case VS::SHADER_SPATIAL: {
			p_shader->spatial.blend_mode = Shader::Spatial::BLEND_MODE_MIX;
			p_shader->spatial.depth_draw_mode = Shader::Spatial::DEPTH_DRAW_OPAQUE;
			p_shader->spatial.cull_mode = Shader::Spatial::CULL_MODE_BACK;
			p_shader->spatial.uses_alpha = false;
			p_shader->spatial.uses_alpha_scissor = false;
			p_shader->spatial.uses_discard = false;
			p_shader->spatial.unshaded = false;
			p_shader->spatial.no_depth_test = false;
			p_shader->spatial.uses_sss = false;
			p_shader->spatial.uses_time = false;
			p_shader->spatial.uses_vertex_lighting = false;
			p_shader->spatial.uses_screen_texture = false;
			p_shader->spatial.uses_depth_texture = false;
			p_shader->spatial.uses_vertex = false;
			p_shader->spatial.writes_modelview_or_projection = false;
			p_shader->spatial.uses_world_coordinates = false;

			shaders.actions_scene.render_mode_values["blend_add"] = Pair<int *, int>(&p_shader->spatial.blend_mode, Shader::Spatial::BLEND_MODE_ADD);
			shaders.actions_scene.render_mode_values["blend_mix"] = Pair<int *, int>(&p_shader->spatial.blend_mode, Shader::Spatial::BLEND_MODE_MIX);
			shaders.actions_scene.render_mode_values["blend_sub"] = Pair<int *, int>(&p_shader->spatial.blend_mode, Shader::Spatial::BLEND_MODE_SUB);
			shaders.actions_scene.render_mode_values["blend_mul"] = Pair<int *, int>(&p_shader->spatial.blend_mode, Shader::Spatial::BLEND_MODE_MUL);

			shaders.actions_scene.render_mode_values["depth_draw_opaque"] = Pair<int *, int>(&p_shader->spatial.depth_draw_mode, Shader::Spatial::DEPTH_DRAW_OPAQUE);
			shaders.actions_scene.render_mode_values["depth_draw_always"] = Pair<int *, int>(&p_shader->spatial.depth_draw_mode, Shader::Spatial::DEPTH_DRAW_ALWAYS);
			shaders.actions_scene.render_mode_values["depth_draw_never"] = Pair<int *, int>(&p_shader->spatial.depth_draw_mode, Shader::Spatial::DEPTH_DRAW_NEVER);
			shaders.actions_scene.render_mode_values["depth_draw_alpha_prepass"] = Pair<int *, int>(&p_shader->spatial.depth_draw_mode, Shader::Spatial::DEPTH_DRAW_ALPHA_PREPASS);

			shaders.actions_scene.render_mode_values["cull_front"] = Pair<int *, int>(&p_shader->spatial.cull_mode, Shader::Spatial::CULL_MODE_FRONT);
			shaders.actions_scene.render_mode_values["cull_back"] = Pair<int *, int>(&p_shader->spatial.cull_mode, Shader::Spatial::CULL_MODE_BACK);
			shaders.actions_scene.render_mode_values["cull_disabled"] = Pair<int *, int>(&p_shader->spatial.cull_mode, Shader::Spatial::CULL_MODE_DISABLED);

			shaders.actions_scene.render_mode_flags["unshaded"] = &p_shader->spatial.unshaded;
			shaders.actions_scene.render_mode_flags["depth_test_disable"] = &p_shader->spatial.no_depth_test;

			shaders.actions_scene.render_mode_flags["vertex_lighting"] = &p_shader->spatial.uses_vertex_lighting;

			shaders.actions_scene.render_mode_flags["world_vertex_coords"] = &p_shader->spatial.uses_world_coordinates;

			shaders.actions_scene.usage_flag_pointers["ALPHA"] = &p_shader->spatial.uses_alpha;
			shaders.actions_scene.usage_flag_pointers["ALPHA_SCISSOR"] = &p_shader->spatial.uses_alpha_scissor;

			shaders.actions_scene.usage_flag_pointers["SSS_STRENGTH"] = &p_shader->spatial.uses_sss;
			shaders.actions_scene.usage_flag_pointers["DISCARD"] = &p_shader->spatial.uses_discard;
			shaders.actions_scene.usage_flag_pointers["SCREEN_TEXTURE"] = &p_shader->spatial.uses_screen_texture;
			shaders.actions_scene.usage_flag_pointers["DEPTH_TEXTURE"] = &p_shader->spatial.uses_depth_texture;
			shaders.actions_scene.usage_flag_pointers["TIME"] = &p_shader->spatial.uses_time;

			shaders.actions_scene.write_flag_pointers["MODELVIEW_MATRIX"] = &p_shader->spatial.writes_modelview_or_projection;
			shaders.actions_scene.write_flag_pointers["PROJECTION_MATRIX"] = &p_shader->spatial.writes_modelview_or_projection;
			shaders.actions_scene.write_flag_pointers["VERTEX"] = &p_shader->spatial.uses_vertex;

			actions = &shaders.actions_scene;
			actions->uniforms = &p_shader->uniforms;
		} break;

		default: {
			return;
		} break;
	}

	Error err = shaders.compiler.compile(p_shader->mode, p_shader->code, actions, p_shader->path, gen_code);

	ERR_FAIL_COND(err != OK);

	p_shader->shader->set_custom_shader_code(p_shader->custom_code_id, gen_code.vertex, gen_code.vertex_global, gen_code.fragment, gen_code.light, gen_code.fragment_global, gen_code.uniforms, gen_code.texture_uniforms, gen_code.custom_defines);

	p_shader->texture_count = gen_code.texture_uniforms.size();
	p_shader->texture_hints = gen_code.texture_hints;

	p_shader->uses_vertex_time = gen_code.uses_vertex_time;
	p_shader->uses_fragment_time = gen_code.uses_fragment_time;

	p_shader->shader->set_custom_shader(p_shader->custom_code_id);
	p_shader->shader->bind();

	// cache uniform locations

	for (SelfList<Material> *E = p_shader->materials.first(); E; E = E->next()) {
		_material_make_dirty(E->self());
	}

	p_shader->valid = true;
	p_shader->version++;
}

void RasterizerStorageGLES2::update_dirty_shaders() {
	while (_shader_dirty_list.first()) {
		_update_shader(_shader_dirty_list.first()->self());
	}
}

void RasterizerStorageGLES2::shader_get_param_list(RID p_shader, List<PropertyInfo> *p_param_list) const {

	Shader *shader = shader_owner.get(p_shader);
	ERR_FAIL_COND(!shader);

	if (shader->dirty_list.in_list()) {
		_update_shader(shader);
	}

	Map<int, StringName> order;

	for (Map<StringName, ShaderLanguage::ShaderNode::Uniform>::Element *E = shader->uniforms.front(); E; E = E->next()) {

		if (E->get().texture_order >= 0) {
			order[E->get().texture_order + 100000] = E->key();
		} else {
			order[E->get().order] = E->key();
		}
	}

	for (Map<int, StringName>::Element *E = order.front(); E; E = E->next()) {

		PropertyInfo pi;
		ShaderLanguage::ShaderNode::Uniform &u = shader->uniforms[E->get()];

		pi.name = E->get();

		switch (u.type) {
			case ShaderLanguage::TYPE_VOID: {
				pi.type = Variant::NIL;
			} break;

			case ShaderLanguage::TYPE_BOOL: {
				pi.type = Variant::BOOL;
			} break;

			// bool vectors
			case ShaderLanguage::TYPE_BVEC2: {
				pi.type = Variant::INT;
				pi.hint = PROPERTY_HINT_FLAGS;
				pi.hint_string = "x,y";
			} break;
			case ShaderLanguage::TYPE_BVEC3: {
				pi.type = Variant::INT;
				pi.hint = PROPERTY_HINT_FLAGS;
				pi.hint_string = "x,y,z";
			} break;
			case ShaderLanguage::TYPE_BVEC4: {
				pi.type = Variant::INT;
				pi.hint = PROPERTY_HINT_FLAGS;
				pi.hint_string = "x,y,z,w";
			} break;

				// int stuff
			case ShaderLanguage::TYPE_UINT:
			case ShaderLanguage::TYPE_INT: {
				pi.type = Variant::INT;

				if (u.hint == ShaderLanguage::ShaderNode::Uniform::HINT_RANGE) {
					pi.hint = PROPERTY_HINT_RANGE;
					pi.hint_string = rtos(u.hint_range[0]) + "," + rtos(u.hint_range[1]);
				}
			} break;

			case ShaderLanguage::TYPE_IVEC2:
			case ShaderLanguage::TYPE_UVEC2:
			case ShaderLanguage::TYPE_IVEC3:
			case ShaderLanguage::TYPE_UVEC3:
			case ShaderLanguage::TYPE_IVEC4:
			case ShaderLanguage::TYPE_UVEC4: {
				pi.type = Variant::POOL_INT_ARRAY;
			} break;

			case ShaderLanguage::TYPE_FLOAT: {
				pi.type = Variant::REAL;
			} break;

			case ShaderLanguage::TYPE_VEC2: {
				pi.type = Variant::VECTOR2;
			} break;
			case ShaderLanguage::TYPE_VEC3: {
				pi.type = Variant::VECTOR3;
			} break;

			case ShaderLanguage::TYPE_VEC4: {
				if (u.hint == ShaderLanguage::ShaderNode::Uniform::HINT_COLOR) {
					pi.type = Variant::COLOR;
				} else {
					pi.type = Variant::PLANE;
				}
			} break;

			case ShaderLanguage::TYPE_MAT2: {
				pi.type = Variant::TRANSFORM2D;
			} break;

			case ShaderLanguage::TYPE_MAT3: {
				pi.type = Variant::BASIS;
			} break;

			case ShaderLanguage::TYPE_MAT4: {
				pi.type = Variant::TRANSFORM;
			} break;

			case ShaderLanguage::TYPE_SAMPLER2D:
			case ShaderLanguage::TYPE_ISAMPLER2D:
			case ShaderLanguage::TYPE_USAMPLER2D: {
				pi.type = Variant::OBJECT;
				pi.hint = PROPERTY_HINT_RESOURCE_TYPE;
				pi.hint_string = "Texture";
			} break;

			case ShaderLanguage::TYPE_SAMPLERCUBE: {
				pi.type = Variant::OBJECT;
				pi.hint = PROPERTY_HINT_RESOURCE_TYPE;
				pi.hint_string = "CubeMap";
			} break;

			default: {

			} break;
		}

		p_param_list->push_back(pi);
	}
}

void RasterizerStorageGLES2::shader_set_default_texture_param(RID p_shader, const StringName &p_name, RID p_texture) {

	Shader *shader = shader_owner.get(p_shader);
	ERR_FAIL_COND(!shader);
	ERR_FAIL_COND(p_texture.is_valid() && !texture_owner.owns(p_texture));

	if (p_texture.is_valid()) {
		shader->default_textures[p_name] = p_texture;
	} else {
		shader->default_textures.erase(p_name);
	}

	_shader_make_dirty(shader);
}

RID RasterizerStorageGLES2::shader_get_default_texture_param(RID p_shader, const StringName &p_name) const {

	const Shader *shader = shader_owner.get(p_shader);
	ERR_FAIL_COND_V(!shader, RID());

	const Map<StringName, RID>::Element *E = shader->default_textures.find(p_name);

	if (!E) {
		return RID();
	}

	return E->get();
}

/* COMMON MATERIAL API */

void RasterizerStorageGLES2::_material_make_dirty(Material *p_material) const {

	if (p_material->dirty_list.in_list())
		return;

	_material_dirty_list.add(&p_material->dirty_list);
}

RID RasterizerStorageGLES2::material_create() {

	Material *material = memnew(Material);

	return material_owner.make_rid(material);
}

void RasterizerStorageGLES2::material_set_shader(RID p_material, RID p_shader) {

	Material *material = material_owner.get(p_material);
	ERR_FAIL_COND(!material);

	Shader *shader = shader_owner.getornull(p_shader);

	if (material->shader) {
		// if a shader is present, remove the old shader
		material->shader->materials.remove(&material->list);
	}

	material->shader = shader;

	if (shader) {
		shader->materials.add(&material->list);
	}

	_material_make_dirty(material);
}

RID RasterizerStorageGLES2::material_get_shader(RID p_material) const {

	const Material *material = material_owner.get(p_material);
	ERR_FAIL_COND_V(!material, RID());

	if (material->shader) {
		return material->shader->self;
	}

	return RID();
}

void RasterizerStorageGLES2::material_set_param(RID p_material, const StringName &p_param, const Variant &p_value) {

	Material *material = material_owner.get(p_material);
	ERR_FAIL_COND(!material);

	if (p_value.get_type() == Variant::NIL) {
		material->params.erase(p_param);
	} else {
		material->params[p_param] = p_value;
	}

	_material_make_dirty(material);
}

Variant RasterizerStorageGLES2::material_get_param(RID p_material, const StringName &p_param) const {

	const Material *material = material_owner.get(p_material);
	ERR_FAIL_COND_V(!material, RID());

	if (material->params.has(p_param)) {
		return material->params[p_param];
	}

	return material_get_param_default(p_material, p_param);
}

Variant RasterizerStorageGLES2::material_get_param_default(RID p_material, const StringName &p_param) const {
	const Material *material = material_owner.get(p_material);
	ERR_FAIL_COND_V(!material, Variant());

	if (material->shader) {
		if (material->shader->uniforms.has(p_param)) {
			Vector<ShaderLanguage::ConstantNode::Value> default_value = material->shader->uniforms[p_param].default_value;
			return ShaderLanguage::constant_value_to_variant(default_value, material->shader->uniforms[p_param].type);
		}
	}
	return Variant();
}

void RasterizerStorageGLES2::material_set_line_width(RID p_material, float p_width) {
	Material *material = material_owner.getornull(p_material);
	ERR_FAIL_COND(!material);

	material->line_width = p_width;
}

void RasterizerStorageGLES2::material_set_next_pass(RID p_material, RID p_next_material) {
	Material *material = material_owner.get(p_material);
	ERR_FAIL_COND(!material);

	material->next_pass = p_next_material;
}

bool RasterizerStorageGLES2::material_is_animated(RID p_material) {
	Material *material = material_owner.get(p_material);
	ERR_FAIL_COND_V(!material, false);
	if (material->dirty_list.in_list()) {
		_update_material(material);
	}

	bool animated = material->is_animated_cache;
	if (!animated && material->next_pass.is_valid()) {
		animated = material_is_animated(material->next_pass);
	}
	return animated;
}

bool RasterizerStorageGLES2::material_casts_shadows(RID p_material) {
	Material *material = material_owner.get(p_material);
	ERR_FAIL_COND_V(!material, false);
	if (material->dirty_list.in_list()) {
		_update_material(material);
	}

	bool casts_shadows = material->can_cast_shadow_cache;

	if (!casts_shadows && material->next_pass.is_valid()) {
		casts_shadows = material_casts_shadows(material->next_pass);
	}

	return casts_shadows;
}

void RasterizerStorageGLES2::material_add_instance_owner(RID p_material, RasterizerScene::InstanceBase *p_instance) {

	Material *material = material_owner.getornull(p_material);
	ERR_FAIL_COND(!material);

	Map<RasterizerScene::InstanceBase *, int>::Element *E = material->instance_owners.find(p_instance);
	if (E) {
		E->get()++;
	} else {
		material->instance_owners[p_instance] = 1;
	}
}

void RasterizerStorageGLES2::material_remove_instance_owner(RID p_material, RasterizerScene::InstanceBase *p_instance) {

	Material *material = material_owner.getornull(p_material);
	ERR_FAIL_COND(!material);

	Map<RasterizerScene::InstanceBase *, int>::Element *E = material->instance_owners.find(p_instance);
	ERR_FAIL_COND(!E);

	E->get()--;

	if (E->get() == 0) {
		material->instance_owners.erase(E);
	}
}

void RasterizerStorageGLES2::material_set_render_priority(RID p_material, int priority) {
	ERR_FAIL_COND(priority < VS::MATERIAL_RENDER_PRIORITY_MIN);
	ERR_FAIL_COND(priority > VS::MATERIAL_RENDER_PRIORITY_MAX);

	Material *material = material_owner.get(p_material);
	ERR_FAIL_COND(!material);

	material->render_priority = priority;
}

void RasterizerStorageGLES2::_update_material(Material *p_material) {
	if (p_material->dirty_list.in_list()) {
		_material_dirty_list.remove(&p_material->dirty_list);
	}

	if (p_material->shader && p_material->shader->dirty_list.in_list()) {
		_update_shader(p_material->shader);
	}

	if (p_material->shader && !p_material->shader->valid) {
		return;
	}

	{
		bool can_cast_shadow = false;
		bool is_animated = false;

		if (p_material->shader && p_material->shader->mode == VS::SHADER_SPATIAL) {

			if (p_material->shader->spatial.blend_mode == Shader::Spatial::BLEND_MODE_MIX &&
					(!p_material->shader->spatial.uses_alpha || (p_material->shader->spatial.uses_alpha && p_material->shader->spatial.depth_draw_mode == Shader::Spatial::DEPTH_DRAW_ALPHA_PREPASS))) {
				can_cast_shadow = true;
			}

			if (p_material->shader->spatial.uses_discard && p_material->shader->uses_fragment_time) {
				is_animated = true;
			}

			if (p_material->shader->spatial.uses_vertex && p_material->shader->uses_vertex_time) {
				is_animated = true;
			}

			if (can_cast_shadow != p_material->can_cast_shadow_cache || is_animated != p_material->is_animated_cache) {
				p_material->can_cast_shadow_cache = can_cast_shadow;
				p_material->is_animated_cache = is_animated;

				for (Map<Geometry *, int>::Element *E = p_material->geometry_owners.front(); E; E = E->next()) {
					E->key()->material_changed_notify();
				}

				for (Map<RasterizerScene::InstanceBase *, int>::Element *E = p_material->instance_owners.front(); E; E = E->next()) {
					E->key()->base_material_changed();
				}
			}
		}
	}

	// uniforms and other things will be set in the use_material method in ShaderGLES2

	if (p_material->shader && p_material->shader->texture_count > 0) {

		p_material->textures.resize(p_material->shader->texture_count);

		for (Map<StringName, ShaderLanguage::ShaderNode::Uniform>::Element *E = p_material->shader->uniforms.front(); E; E = E->next()) {
			if (E->get().texture_order < 0)
				continue; // not a texture, does not go here

			RID texture;

			Map<StringName, Variant>::Element *V = p_material->params.find(E->key());

			if (V) {
				texture = V->get();
			}

			if (!texture.is_valid()) {
				Map<StringName, RID>::Element *W = p_material->shader->default_textures.find(E->key());

				if (W) {
					texture = W->get();
				}
			}

			p_material->textures.write[E->get().texture_order] = Pair<StringName, RID>(E->key(), texture);
		}
	} else {
		p_material->textures.clear();
	}
}

void RasterizerStorageGLES2::_material_add_geometry(RID p_material, Geometry *p_geometry) {
	Material *material = material_owner.getornull(p_material);
	ERR_FAIL_COND(!material);

	Map<Geometry *, int>::Element *I = material->geometry_owners.find(p_geometry);

	if (I) {
		I->get()++;
	} else {
		material->geometry_owners[p_geometry] = 1;
	}
}

void RasterizerStorageGLES2::_material_remove_geometry(RID p_material, Geometry *p_geometry) {

	Material *material = material_owner.getornull(p_material);
	ERR_FAIL_COND(!material);

	Map<Geometry *, int>::Element *I = material->geometry_owners.find(p_geometry);
	ERR_FAIL_COND(!I);

	I->get()--;

	if (I->get() == 0) {
		material->geometry_owners.erase(I);
	}
}

void RasterizerStorageGLES2::update_dirty_materials() {
	while (_material_dirty_list.first()) {

		Material *material = _material_dirty_list.first()->self();
		_update_material(material);
	}
}

/* MESH API */

RID RasterizerStorageGLES2::mesh_create() {

	Mesh *mesh = memnew(Mesh);

	return mesh_owner.make_rid(mesh);
}

void RasterizerStorageGLES2::mesh_add_surface(RID p_mesh, uint32_t p_format, VS::PrimitiveType p_primitive, const PoolVector<uint8_t> &p_array, int p_vertex_count, const PoolVector<uint8_t> &p_index_array, int p_index_count, const AABB &p_aabb, const Vector<PoolVector<uint8_t> > &p_blend_shapes, const Vector<AABB> &p_bone_aabbs) {
	PoolVector<uint8_t> array = p_array;

	Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND(!mesh);

	ERR_FAIL_COND(!(p_format & VS::ARRAY_FORMAT_VERTEX));

	//must have index and bones, both.
	{
		uint32_t bones_weight = VS::ARRAY_FORMAT_BONES | VS::ARRAY_FORMAT_WEIGHTS;
		ERR_EXPLAIN("Array must have both bones and weights in format or none.");
		ERR_FAIL_COND((p_format & bones_weight) && (p_format & bones_weight) != bones_weight);
	}

	//bool has_morph = p_blend_shapes.size();

	Surface::Attrib attribs[VS::ARRAY_MAX];

	int stride = 0;

	for (int i = 0; i < VS::ARRAY_MAX; i++) {

		attribs[i].index = i;

		if (!(p_format & (1 << i))) {
			attribs[i].enabled = false;
			attribs[i].integer = false;
			continue;
		}

		attribs[i].enabled = true;
		attribs[i].offset = stride;
		attribs[i].integer = false;

		switch (i) {

			case VS::ARRAY_VERTEX: {

				if (p_format & VS::ARRAY_FLAG_USE_2D_VERTICES) {
					attribs[i].size = 2;
				} else {
					attribs[i].size = (p_format & VS::ARRAY_COMPRESS_VERTEX) ? 4 : 3;
				}

				if (p_format & VS::ARRAY_COMPRESS_VERTEX) {
					attribs[i].type = _GL_HALF_FLOAT_OES;
					stride += attribs[i].size * 2;
				} else {
					attribs[i].type = GL_FLOAT;
					stride += attribs[i].size * 4;
				}

				attribs[i].normalized = GL_FALSE;

			} break;
			case VS::ARRAY_NORMAL: {

				attribs[i].size = 3;

				if (p_format & VS::ARRAY_COMPRESS_NORMAL) {
					attribs[i].type = GL_BYTE;
					stride += 4; //pad extra byte
					attribs[i].normalized = GL_TRUE;
				} else {
					attribs[i].type = GL_FLOAT;
					stride += 12;
					attribs[i].normalized = GL_FALSE;
				}

			} break;
			case VS::ARRAY_TANGENT: {

				attribs[i].size = 4;

				if (p_format & VS::ARRAY_COMPRESS_TANGENT) {
					attribs[i].type = GL_BYTE;
					stride += 4;
					attribs[i].normalized = GL_TRUE;
				} else {
					attribs[i].type = GL_FLOAT;
					stride += 16;
					attribs[i].normalized = GL_FALSE;
				}

			} break;
			case VS::ARRAY_COLOR: {

				attribs[i].size = 4;

				if (p_format & VS::ARRAY_COMPRESS_COLOR) {
					attribs[i].type = GL_UNSIGNED_BYTE;
					stride += 4;
					attribs[i].normalized = GL_TRUE;
				} else {
					attribs[i].type = GL_FLOAT;
					stride += 16;
					attribs[i].normalized = GL_FALSE;
				}

			} break;
			case VS::ARRAY_TEX_UV: {

				attribs[i].size = 2;

				if (p_format & VS::ARRAY_COMPRESS_TEX_UV) {
					attribs[i].type = _GL_HALF_FLOAT_OES;
					stride += 4;
				} else {
					attribs[i].type = GL_FLOAT;
					stride += 8;
				}

				attribs[i].normalized = GL_FALSE;

			} break;
			case VS::ARRAY_TEX_UV2: {

				attribs[i].size = 2;

				if (p_format & VS::ARRAY_COMPRESS_TEX_UV2) {
					attribs[i].type = _GL_HALF_FLOAT_OES;
					stride += 4;
				} else {
					attribs[i].type = GL_FLOAT;
					stride += 8;
				}
				attribs[i].normalized = GL_FALSE;

			} break;
			case VS::ARRAY_BONES: {

				attribs[i].size = 4;

				if (p_format & VS::ARRAY_FLAG_USE_16_BIT_BONES) {
					attribs[i].type = GL_UNSIGNED_SHORT;
					stride += 8;
				} else {
					attribs[i].type = GL_UNSIGNED_BYTE;
					stride += 4;
				}

				attribs[i].normalized = GL_FALSE;
				attribs[i].integer = true;

			} break;
			case VS::ARRAY_WEIGHTS: {

				attribs[i].size = 4;

				if (p_format & VS::ARRAY_COMPRESS_WEIGHTS) {

					attribs[i].type = GL_UNSIGNED_SHORT;
					stride += 8;
					attribs[i].normalized = GL_TRUE;
				} else {
					attribs[i].type = GL_FLOAT;
					stride += 16;
					attribs[i].normalized = GL_FALSE;
				}

			} break;
			case VS::ARRAY_INDEX: {

				attribs[i].size = 1;

				if (p_vertex_count >= (1 << 16)) {
					attribs[i].type = GL_UNSIGNED_INT;
					attribs[i].stride = 4;
				} else {
					attribs[i].type = GL_UNSIGNED_SHORT;
					attribs[i].stride = 2;
				}

				attribs[i].normalized = GL_FALSE;

			} break;
		}
	}

	for (int i = 0; i < VS::ARRAY_MAX - 1; i++) {
		attribs[i].stride = stride;
	}

	//validate sizes

	int array_size = stride * p_vertex_count;
	int index_array_size = 0;
	if (array.size() != array_size && array.size() + p_vertex_count * 2 == array_size) {
		//old format, convert
		array = PoolVector<uint8_t>();

		array.resize(p_array.size() + p_vertex_count * 2);

		PoolVector<uint8_t>::Write w = array.write();
		PoolVector<uint8_t>::Read r = p_array.read();

		uint16_t *w16 = (uint16_t *)w.ptr();
		const uint16_t *r16 = (uint16_t *)r.ptr();

		uint16_t one = Math::make_half_float(1);

		for (int i = 0; i < p_vertex_count; i++) {

			*w16++ = *r16++;
			*w16++ = *r16++;
			*w16++ = *r16++;
			*w16++ = one;
			for (int j = 0; j < (stride / 2) - 4; j++) {
				*w16++ = *r16++;
			}
		}
	}

	ERR_FAIL_COND(array.size() != array_size);

	if (p_format & VS::ARRAY_FORMAT_INDEX) {

		index_array_size = attribs[VS::ARRAY_INDEX].stride * p_index_count;
	}

	ERR_FAIL_COND(p_index_array.size() != index_array_size);

	ERR_FAIL_COND(p_blend_shapes.size() != mesh->blend_shape_count);

	for (int i = 0; i < p_blend_shapes.size(); i++) {
		ERR_FAIL_COND(p_blend_shapes[i].size() != array_size);
	}

	// all valid, create stuff

	Surface *surface = memnew(Surface);

	surface->active = true;
	surface->array_len = p_vertex_count;
	surface->index_array_len = p_index_count;
	surface->array_byte_size = array.size();
	surface->index_array_byte_size = p_index_array.size();
	surface->primitive = p_primitive;
	surface->mesh = mesh;
	surface->format = p_format;
	surface->skeleton_bone_aabb = p_bone_aabbs;
	surface->skeleton_bone_used.resize(surface->skeleton_bone_aabb.size());

	surface->aabb = p_aabb;
	surface->max_bone = p_bone_aabbs.size();

	surface->data = array;
	surface->index_data = p_index_array;

	surface->total_data_size += surface->array_byte_size + surface->index_array_byte_size;

	for (int i = 0; i < surface->skeleton_bone_used.size(); i++) {
		surface->skeleton_bone_used.write[i] = surface->skeleton_bone_aabb[i].size.x < 0 || surface->skeleton_bone_aabb[i].size.y < 0 || surface->skeleton_bone_aabb[i].size.z < 0;
	}

	for (int i = 0; i < VS::ARRAY_MAX; i++) {
		surface->attribs[i] = attribs[i];
	}

	// Okay, now the OpenGL stuff, wheeeeey \o/
	{
		PoolVector<uint8_t>::Read vr = array.read();

		glGenBuffers(1, &surface->vertex_id);
		glBindBuffer(GL_ARRAY_BUFFER, surface->vertex_id);
		glBufferData(GL_ARRAY_BUFFER, array_size, vr.ptr(), (p_format & VS::ARRAY_FLAG_USE_DYNAMIC_UPDATE) ? GL_DYNAMIC_DRAW : GL_STATIC_DRAW);

		glBindBuffer(GL_ARRAY_BUFFER, 0);

		if (p_format & VS::ARRAY_FORMAT_INDEX) {
			PoolVector<uint8_t>::Read ir = p_index_array.read();

			glGenBuffers(1, &surface->index_id);
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, surface->index_id);
			glBufferData(GL_ELEMENT_ARRAY_BUFFER, index_array_size, ir.ptr(), GL_STATIC_DRAW);
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		}

		// TODO generate wireframes
	}

	{
		// blend shapes

		for (int i = 0; i < p_blend_shapes.size(); i++) {

			Surface::BlendShape mt;

			PoolVector<uint8_t>::Read vr = p_blend_shapes[i].read();

			surface->total_data_size += array_size;

			glGenBuffers(1, &mt.vertex_id);
			glBindBuffer(GL_ARRAY_BUFFER, mt.vertex_id);
			glBufferData(GL_ARRAY_BUFFER, array_size, vr.ptr(), GL_STATIC_DRAW);
			glBindBuffer(GL_ARRAY_BUFFER, 0);

			surface->blend_shapes.push_back(mt);
		}
	}

	mesh->surfaces.push_back(surface);
	mesh->instance_change_notify();

	info.vertex_mem += surface->total_data_size;
}

void RasterizerStorageGLES2::mesh_set_blend_shape_count(RID p_mesh, int p_amount) {
	Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND(!mesh);

	ERR_FAIL_COND(mesh->surfaces.size() != 0);
	ERR_FAIL_COND(p_amount < 0);

	mesh->blend_shape_count = p_amount;
}

int RasterizerStorageGLES2::mesh_get_blend_shape_count(RID p_mesh) const {
	const Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND_V(!mesh, 0);

	return mesh->blend_shape_count;
}

void RasterizerStorageGLES2::mesh_set_blend_shape_mode(RID p_mesh, VS::BlendShapeMode p_mode) {
	Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND(!mesh);

	mesh->blend_shape_mode = p_mode;
}

VS::BlendShapeMode RasterizerStorageGLES2::mesh_get_blend_shape_mode(RID p_mesh) const {
	const Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND_V(!mesh, VS::BLEND_SHAPE_MODE_NORMALIZED);

	return mesh->blend_shape_mode;
}

void RasterizerStorageGLES2::mesh_surface_update_region(RID p_mesh, int p_surface, int p_offset, const PoolVector<uint8_t> &p_data) {
	Mesh *mesh = mesh_owner.getornull(p_mesh);

	ERR_FAIL_COND(!mesh);
	ERR_FAIL_INDEX(p_surface, mesh->surfaces.size());

	int total_size = p_data.size();
	ERR_FAIL_COND(p_offset + total_size > mesh->surfaces[p_surface]->array_byte_size);

	PoolVector<uint8_t>::Read r = p_data.read();

	glBindBuffer(GL_ARRAY_BUFFER, mesh->surfaces[p_surface]->vertex_id);
	glBufferSubData(GL_ARRAY_BUFFER, p_offset, total_size, r.ptr());
	glBindBuffer(GL_ARRAY_BUFFER, 0); //unbind
}

void RasterizerStorageGLES2::mesh_surface_set_material(RID p_mesh, int p_surface, RID p_material) {
	Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND(!mesh);
	ERR_FAIL_INDEX(p_surface, mesh->surfaces.size());

	if (mesh->surfaces[p_surface]->material == p_material)
		return;

	if (mesh->surfaces[p_surface]->material.is_valid()) {
		_material_remove_geometry(mesh->surfaces[p_surface]->material, mesh->surfaces[p_surface]);
	}

	mesh->surfaces[p_surface]->material = p_material;

	if (mesh->surfaces[p_surface]->material.is_valid()) {
		_material_add_geometry(mesh->surfaces[p_surface]->material, mesh->surfaces[p_surface]);
	}

	mesh->instance_material_change_notify();
}

RID RasterizerStorageGLES2::mesh_surface_get_material(RID p_mesh, int p_surface) const {
	const Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND_V(!mesh, RID());
	ERR_FAIL_INDEX_V(p_surface, mesh->surfaces.size(), RID());

	return mesh->surfaces[p_surface]->material;
}

int RasterizerStorageGLES2::mesh_surface_get_array_len(RID p_mesh, int p_surface) const {
	const Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND_V(!mesh, 0);
	ERR_FAIL_INDEX_V(p_surface, mesh->surfaces.size(), 0);

	return mesh->surfaces[p_surface]->array_len;
}

int RasterizerStorageGLES2::mesh_surface_get_array_index_len(RID p_mesh, int p_surface) const {
	const Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND_V(!mesh, 0);
	ERR_FAIL_INDEX_V(p_surface, mesh->surfaces.size(), 0);

	return mesh->surfaces[p_surface]->index_array_len;
}

PoolVector<uint8_t> RasterizerStorageGLES2::mesh_surface_get_array(RID p_mesh, int p_surface) const {

	const Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND_V(!mesh, PoolVector<uint8_t>());
	ERR_FAIL_INDEX_V(p_surface, mesh->surfaces.size(), PoolVector<uint8_t>());

	Surface *surface = mesh->surfaces[p_surface];

	return surface->data;
}

PoolVector<uint8_t> RasterizerStorageGLES2::mesh_surface_get_index_array(RID p_mesh, int p_surface) const {
	const Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND_V(!mesh, PoolVector<uint8_t>());
	ERR_FAIL_INDEX_V(p_surface, mesh->surfaces.size(), PoolVector<uint8_t>());

	Surface *surface = mesh->surfaces[p_surface];

	return surface->index_data;
}

uint32_t RasterizerStorageGLES2::mesh_surface_get_format(RID p_mesh, int p_surface) const {
	const Mesh *mesh = mesh_owner.getornull(p_mesh);

	ERR_FAIL_COND_V(!mesh, 0);
	ERR_FAIL_INDEX_V(p_surface, mesh->surfaces.size(), 0);

	return mesh->surfaces[p_surface]->format;
}

VS::PrimitiveType RasterizerStorageGLES2::mesh_surface_get_primitive_type(RID p_mesh, int p_surface) const {
	const Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND_V(!mesh, VS::PRIMITIVE_MAX);
	ERR_FAIL_INDEX_V(p_surface, mesh->surfaces.size(), VS::PRIMITIVE_MAX);

	return mesh->surfaces[p_surface]->primitive;
}

AABB RasterizerStorageGLES2::mesh_surface_get_aabb(RID p_mesh, int p_surface) const {
	const Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND_V(!mesh, AABB());
	ERR_FAIL_INDEX_V(p_surface, mesh->surfaces.size(), AABB());

	return mesh->surfaces[p_surface]->aabb;
}

Vector<PoolVector<uint8_t> > RasterizerStorageGLES2::mesh_surface_get_blend_shapes(RID p_mesh, int p_surface) const {
	WARN_PRINT("GLES2 mesh_surface_get_blend_shapes is not implemented");
	return Vector<PoolVector<uint8_t> >();
}
Vector<AABB> RasterizerStorageGLES2::mesh_surface_get_skeleton_aabb(RID p_mesh, int p_surface) const {
	const Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND_V(!mesh, Vector<AABB>());
	ERR_FAIL_INDEX_V(p_surface, mesh->surfaces.size(), Vector<AABB>());

	return mesh->surfaces[p_surface]->skeleton_bone_aabb;
}

void RasterizerStorageGLES2::mesh_remove_surface(RID p_mesh, int p_surface) {

	Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND(!mesh);
	ERR_FAIL_INDEX(p_surface, mesh->surfaces.size());

	Surface *surface = mesh->surfaces[p_surface];

	if (surface->material.is_valid()) {
		// TODO _material_remove_geometry(surface->material, mesh->surfaces[p_surface]);
	}

	glDeleteBuffers(1, &surface->vertex_id);
	if (surface->index_id) {
		glDeleteBuffers(1, &surface->index_id);
	}

	for (int i = 0; i < surface->blend_shapes.size(); i++) {
		glDeleteBuffers(1, &surface->blend_shapes[i].vertex_id);
	}

	info.vertex_mem -= surface->total_data_size;

	mesh->instance_material_change_notify();

	memdelete(surface);

	mesh->surfaces.remove(p_surface);

	mesh->instance_change_notify();
}

int RasterizerStorageGLES2::mesh_get_surface_count(RID p_mesh) const {
	const Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND_V(!mesh, 0);
	return mesh->surfaces.size();
}

void RasterizerStorageGLES2::mesh_set_custom_aabb(RID p_mesh, const AABB &p_aabb) {
	Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND(!mesh);

	mesh->custom_aabb = p_aabb;
}

AABB RasterizerStorageGLES2::mesh_get_custom_aabb(RID p_mesh) const {
	const Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND_V(!mesh, AABB());

	return mesh->custom_aabb;
}

AABB RasterizerStorageGLES2::mesh_get_aabb(RID p_mesh, RID p_skeleton) const {
	Mesh *mesh = mesh_owner.get(p_mesh);
	ERR_FAIL_COND_V(!mesh, AABB());

	if (mesh->custom_aabb != AABB())
		return mesh->custom_aabb;

	// TODO handle skeletons

	AABB aabb;

	if (mesh->surfaces.size() >= 1) {
		aabb = mesh->surfaces[0]->aabb;
	}

	for (int i = 0; i < mesh->surfaces.size(); i++) {
		aabb.merge_with(mesh->surfaces[i]->aabb);
	}

	return aabb;
}
void RasterizerStorageGLES2::mesh_clear(RID p_mesh) {
	Mesh *mesh = mesh_owner.getornull(p_mesh);
	ERR_FAIL_COND(!mesh);

	while (mesh->surfaces.size()) {
		mesh_remove_surface(p_mesh, 0);
	}
}

/* MULTIMESH API */

RID RasterizerStorageGLES2::multimesh_create() {
	MultiMesh *multimesh = memnew(MultiMesh);
	return multimesh_owner.make_rid(multimesh);
}

void RasterizerStorageGLES2::multimesh_allocate(RID p_multimesh, int p_instances, VS::MultimeshTransformFormat p_transform_format, VS::MultimeshColorFormat p_color_format, VS::MultimeshCustomDataFormat p_data) {
	MultiMesh *multimesh = multimesh_owner.getornull(p_multimesh);
	ERR_FAIL_COND(!multimesh);

	if (multimesh->size == p_instances && multimesh->transform_format == p_transform_format && multimesh->color_format == p_color_format && multimesh->custom_data_format == p_data) {
		return;
	}

	multimesh->size = p_instances;

	multimesh->color_format = p_color_format;
	multimesh->transform_format = p_transform_format;
	multimesh->custom_data_format = p_data;

	if (multimesh->size) {
		multimesh->data.resize(0);
	}

	if (multimesh->transform_format == VS::MULTIMESH_TRANSFORM_2D) {
		multimesh->xform_floats = 8;
	} else {
		multimesh->xform_floats = 12;
	}

	if (multimesh->color_format == VS::MULTIMESH_COLOR_NONE) {
		multimesh->color_floats = 0;
	} else if (multimesh->color_format == VS::MULTIMESH_COLOR_8BIT) {
		multimesh->color_floats = 1;
	} else if (multimesh->color_format == VS::MULTIMESH_COLOR_FLOAT) {
		multimesh->color_floats = 4;
	}

	if (multimesh->custom_data_format == VS::MULTIMESH_CUSTOM_DATA_NONE) {
		multimesh->custom_data_floats = 0;
	} else if (multimesh->custom_data_format == VS::MULTIMESH_CUSTOM_DATA_8BIT) {
		multimesh->custom_data_floats = 1;
	} else if (multimesh->custom_data_format == VS::MULTIMESH_CUSTOM_DATA_FLOAT) {
		multimesh->custom_data_floats = 4;
	}

	int format_floats = multimesh->color_floats + multimesh->xform_floats + multimesh->custom_data_floats;

	multimesh->data.resize(format_floats * p_instances);

	for (int i = 0; i < p_instances * format_floats; i += format_floats) {
		int color_from = 0;
		int custom_data_from = 0;

		if (multimesh->transform_format == VS::MULTIMESH_TRANSFORM_2D) {
			multimesh->data.write[i + 0] = 1.0;
			multimesh->data.write[i + 1] = 0.0;
			multimesh->data.write[i + 2] = 0.0;
			multimesh->data.write[i + 3] = 0.0;
			multimesh->data.write[i + 4] = 0.0;
			multimesh->data.write[i + 5] = 1.0;
			multimesh->data.write[i + 6] = 0.0;
			multimesh->data.write[i + 7] = 0.0;
			color_from = 8;
			custom_data_from = 8;
		} else {
			multimesh->data.write[i + 0] = 1.0;
			multimesh->data.write[i + 1] = 0.0;
			multimesh->data.write[i + 2] = 0.0;
			multimesh->data.write[i + 3] = 0.0;
			multimesh->data.write[i + 4] = 0.0;
			multimesh->data.write[i + 5] = 1.0;
			multimesh->data.write[i + 6] = 0.0;
			multimesh->data.write[i + 7] = 0.0;
			multimesh->data.write[i + 8] = 0.0;
			multimesh->data.write[i + 9] = 0.0;
			multimesh->data.write[i + 10] = 1.0;
			multimesh->data.write[i + 11] = 0.0;
			color_from = 12;
			custom_data_from = 12;
		}

		if (multimesh->color_format == VS::MULTIMESH_COLOR_8BIT) {
			union {
				uint32_t colu;
				float colf;
			} cu;

			cu.colu = 0xFFFFFFFF;
			multimesh->data.write[i + color_from + 0] = cu.colf;
			custom_data_from = color_from + 1;
		} else if (multimesh->color_format == VS::MULTIMESH_COLOR_FLOAT) {
			multimesh->data.write[i + color_from + 0] = 1.0;
			multimesh->data.write[i + color_from + 1] = 1.0;
			multimesh->data.write[i + color_from + 2] = 1.0;
			multimesh->data.write[i + color_from + 3] = 1.0;
			custom_data_from = color_from + 4;
		}

		if (multimesh->custom_data_format == VS::MULTIMESH_CUSTOM_DATA_8BIT) {
			union {
				uint32_t colu;
				float colf;
			} cu;

			cu.colu = 0;
			multimesh->data.write[i + custom_data_from + 0] = cu.colf;
		} else if (multimesh->custom_data_format == VS::MULTIMESH_CUSTOM_DATA_FLOAT) {
			multimesh->data.write[i + custom_data_from + 0] = 0.0;
			multimesh->data.write[i + custom_data_from + 1] = 0.0;
			multimesh->data.write[i + custom_data_from + 2] = 0.0;
			multimesh->data.write[i + custom_data_from + 3] = 0.0;
		}
	}

	multimesh->dirty_aabb = true;
	multimesh->dirty_data = true;

	if (!multimesh->update_list.in_list()) {
		multimesh_update_list.add(&multimesh->update_list);
	}
}

int RasterizerStorageGLES2::multimesh_get_instance_count(RID p_multimesh) const {
	MultiMesh *multimesh = multimesh_owner.getornull(p_multimesh);
	ERR_FAIL_COND_V(!multimesh, 0);

	return multimesh->size;
}

void RasterizerStorageGLES2::multimesh_set_mesh(RID p_multimesh, RID p_mesh) {
	MultiMesh *multimesh = multimesh_owner.getornull(p_multimesh);
	ERR_FAIL_COND(!multimesh);

	if (multimesh->mesh.is_valid()) {
		Mesh *mesh = mesh_owner.getornull(multimesh->mesh);
		if (mesh) {
			mesh->multimeshes.remove(&multimesh->mesh_list);
		}
	}

	multimesh->mesh = p_mesh;

	if (multimesh->mesh.is_valid()) {
		Mesh *mesh = mesh_owner.getornull(multimesh->mesh);
		if (mesh) {
			mesh->multimeshes.add(&multimesh->mesh_list);
		}
	}

	multimesh->dirty_aabb = true;

	if (!multimesh->update_list.in_list()) {
		multimesh_update_list.add(&multimesh->update_list);
	}
}

void RasterizerStorageGLES2::multimesh_instance_set_transform(RID p_multimesh, int p_index, const Transform &p_transform) {
	MultiMesh *multimesh = multimesh_owner.getornull(p_multimesh);
	ERR_FAIL_COND(!multimesh);
	ERR_FAIL_INDEX(p_index, multimesh->size);
	ERR_FAIL_COND(multimesh->transform_format == VS::MULTIMESH_TRANSFORM_2D);

	int stride = multimesh->color_floats + multimesh->custom_data_floats + multimesh->xform_floats;

	float *dataptr = &multimesh->data.write[stride * p_index];

	dataptr[0] = p_transform.basis.elements[0][0];
	dataptr[1] = p_transform.basis.elements[0][1];
	dataptr[2] = p_transform.basis.elements[0][2];
	dataptr[3] = p_transform.origin.x;
	dataptr[4] = p_transform.basis.elements[1][0];
	dataptr[5] = p_transform.basis.elements[1][1];
	dataptr[6] = p_transform.basis.elements[1][2];
	dataptr[7] = p_transform.origin.y;
	dataptr[8] = p_transform.basis.elements[2][0];
	dataptr[9] = p_transform.basis.elements[2][1];
	dataptr[10] = p_transform.basis.elements[2][2];
	dataptr[11] = p_transform.origin.z;

	multimesh->dirty_data = true;
	multimesh->dirty_aabb = true;

	if (!multimesh->update_list.in_list()) {
		multimesh_update_list.add(&multimesh->update_list);
	}
}

void RasterizerStorageGLES2::multimesh_instance_set_transform_2d(RID p_multimesh, int p_index, const Transform2D &p_transform) {
	MultiMesh *multimesh = multimesh_owner.getornull(p_multimesh);
	ERR_FAIL_COND(!multimesh);
	ERR_FAIL_INDEX(p_index, multimesh->size);
	ERR_FAIL_COND(multimesh->transform_format == VS::MULTIMESH_TRANSFORM_3D);

	int stride = multimesh->color_floats + multimesh->xform_floats + multimesh->custom_data_floats;
	float *dataptr = &multimesh->data.write[stride * p_index];

	dataptr[0] = p_transform.elements[0][0];
	dataptr[1] = p_transform.elements[1][0];
	dataptr[2] = 0;
	dataptr[3] = p_transform.elements[2][0];
	dataptr[4] = p_transform.elements[0][1];
	dataptr[5] = p_transform.elements[1][1];
	dataptr[6] = 0;
	dataptr[7] = p_transform.elements[2][1];

	multimesh->dirty_data = true;
	multimesh->dirty_aabb = true;

	if (!multimesh->update_list.in_list()) {
		multimesh_update_list.add(&multimesh->update_list);
	}
}

void RasterizerStorageGLES2::multimesh_instance_set_color(RID p_multimesh, int p_index, const Color &p_color) {
	MultiMesh *multimesh = multimesh_owner.getornull(p_multimesh);
	ERR_FAIL_COND(!multimesh);
	ERR_FAIL_INDEX(p_index, multimesh->size);
	ERR_FAIL_COND(multimesh->color_format == VS::MULTIMESH_COLOR_NONE);

	int stride = multimesh->color_floats + multimesh->xform_floats + multimesh->custom_data_floats;
	float *dataptr = &multimesh->data.write[stride * p_index + multimesh->xform_floats];

	if (multimesh->color_format == VS::MULTIMESH_COLOR_8BIT) {

		uint8_t *data8 = (uint8_t *)dataptr;
		data8[0] = CLAMP(p_color.r * 255.0, 0, 255);
		data8[1] = CLAMP(p_color.g * 255.0, 0, 255);
		data8[2] = CLAMP(p_color.b * 255.0, 0, 255);
		data8[3] = CLAMP(p_color.a * 255.0, 0, 255);

	} else if (multimesh->color_format == VS::MULTIMESH_COLOR_FLOAT) {
		dataptr[0] = p_color.r;
		dataptr[1] = p_color.g;
		dataptr[2] = p_color.b;
		dataptr[3] = p_color.a;
	}

	multimesh->dirty_data = true;
	multimesh->dirty_aabb = true;

	if (!multimesh->update_list.in_list()) {
		multimesh_update_list.add(&multimesh->update_list);
	}
}

void RasterizerStorageGLES2::multimesh_instance_set_custom_data(RID p_multimesh, int p_index, const Color &p_custom_data) {
	MultiMesh *multimesh = multimesh_owner.getornull(p_multimesh);
	ERR_FAIL_COND(!multimesh);
	ERR_FAIL_INDEX(p_index, multimesh->size);
	ERR_FAIL_COND(multimesh->custom_data_format == VS::MULTIMESH_CUSTOM_DATA_NONE);

	int stride = multimesh->color_floats + multimesh->xform_floats + multimesh->custom_data_floats;
	float *dataptr = &multimesh->data.write[stride * p_index + multimesh->xform_floats + multimesh->color_floats];

	if (multimesh->custom_data_format == VS::MULTIMESH_CUSTOM_DATA_8BIT) {

		uint8_t *data8 = (uint8_t *)dataptr;
		data8[0] = CLAMP(p_custom_data.r * 255.0, 0, 255);
		data8[1] = CLAMP(p_custom_data.g * 255.0, 0, 255);
		data8[2] = CLAMP(p_custom_data.b * 255.0, 0, 255);
		data8[3] = CLAMP(p_custom_data.a * 255.0, 0, 255);

	} else if (multimesh->custom_data_format == VS::MULTIMESH_CUSTOM_DATA_FLOAT) {
		dataptr[0] = p_custom_data.r;
		dataptr[1] = p_custom_data.g;
		dataptr[2] = p_custom_data.b;
		dataptr[3] = p_custom_data.a;
	}

	multimesh->dirty_data = true;
	multimesh->dirty_aabb = true;

	if (!multimesh->update_list.in_list()) {
		multimesh_update_list.add(&multimesh->update_list);
	}
}

RID RasterizerStorageGLES2::multimesh_get_mesh(RID p_multimesh) const {
	MultiMesh *multimesh = multimesh_owner.getornull(p_multimesh);
	ERR_FAIL_COND_V(!multimesh, RID());

	return multimesh->mesh;
}

Transform RasterizerStorageGLES2::multimesh_instance_get_transform(RID p_multimesh, int p_index) const {
	MultiMesh *multimesh = multimesh_owner.getornull(p_multimesh);
	ERR_FAIL_COND_V(!multimesh, Transform());
	ERR_FAIL_INDEX_V(p_index, multimesh->size, Transform());
	ERR_FAIL_COND_V(multimesh->transform_format == VS::MULTIMESH_TRANSFORM_2D, Transform());

	int stride = multimesh->color_floats + multimesh->xform_floats + multimesh->custom_data_floats;
	float *dataptr = &multimesh->data.write[stride * p_index];

	Transform xform;

	xform.basis.elements[0][0] = dataptr[0];
	xform.basis.elements[0][1] = dataptr[1];
	xform.basis.elements[0][2] = dataptr[2];
	xform.origin.x = dataptr[3];
	xform.basis.elements[1][0] = dataptr[4];
	xform.basis.elements[1][1] = dataptr[5];
	xform.basis.elements[1][2] = dataptr[6];
	xform.origin.y = dataptr[7];
	xform.basis.elements[2][0] = dataptr[8];
	xform.basis.elements[2][1] = dataptr[9];
	xform.basis.elements[2][2] = dataptr[10];
	xform.origin.z = dataptr[11];

	return xform;
}

Transform2D RasterizerStorageGLES2::multimesh_instance_get_transform_2d(RID p_multimesh, int p_index) const {
	MultiMesh *multimesh = multimesh_owner.getornull(p_multimesh);
	ERR_FAIL_COND_V(!multimesh, Transform2D());
	ERR_FAIL_INDEX_V(p_index, multimesh->size, Transform2D());
	ERR_FAIL_COND_V(multimesh->transform_format == VS::MULTIMESH_TRANSFORM_3D, Transform2D());

	int stride = multimesh->color_floats + multimesh->xform_floats + multimesh->custom_data_floats;
	float *dataptr = &multimesh->data.write[stride * p_index];

	Transform2D xform;

	xform.elements[0][0] = dataptr[0];
	xform.elements[1][0] = dataptr[1];
	xform.elements[2][0] = dataptr[3];
	xform.elements[0][1] = dataptr[4];
	xform.elements[1][1] = dataptr[5];
	xform.elements[2][1] = dataptr[7];

	return xform;
}

Color RasterizerStorageGLES2::multimesh_instance_get_color(RID p_multimesh, int p_index) const {
	MultiMesh *multimesh = multimesh_owner.getornull(p_multimesh);
	ERR_FAIL_COND_V(!multimesh, Color());
	ERR_FAIL_INDEX_V(p_index, multimesh->size, Color());
	ERR_FAIL_COND_V(multimesh->color_format == VS::MULTIMESH_COLOR_NONE, Color());

	int stride = multimesh->color_floats + multimesh->xform_floats + multimesh->custom_data_floats;
	float *dataptr = &multimesh->data.write[stride * p_index + multimesh->xform_floats];

	if (multimesh->color_format == VS::MULTIMESH_COLOR_8BIT) {
		union {
			uint32_t colu;
			float colf;
		} cu;

		cu.colf = dataptr[0];

		return Color::hex(BSWAP32(cu.colu));

	} else if (multimesh->color_format == VS::MULTIMESH_COLOR_FLOAT) {
		Color c;
		c.r = dataptr[0];
		c.g = dataptr[1];
		c.b = dataptr[2];
		c.a = dataptr[3];

		return c;
	}

	return Color();
}

Color RasterizerStorageGLES2::multimesh_instance_get_custom_data(RID p_multimesh, int p_index) const {
	MultiMesh *multimesh = multimesh_owner.getornull(p_multimesh);
	ERR_FAIL_COND_V(!multimesh, Color());
	ERR_FAIL_INDEX_V(p_index, multimesh->size, Color());
	ERR_FAIL_COND_V(multimesh->custom_data_format == VS::MULTIMESH_CUSTOM_DATA_NONE, Color());

	int stride = multimesh->color_floats + multimesh->xform_floats + multimesh->custom_data_floats;
	float *dataptr = &multimesh->data.write[stride * p_index + multimesh->xform_floats + multimesh->color_floats];

	if (multimesh->custom_data_format == VS::MULTIMESH_CUSTOM_DATA_8BIT) {
		union {
			uint32_t colu;
			float colf;
		} cu;

		cu.colf = dataptr[0];

		return Color::hex(BSWAP32(cu.colu));

	} else if (multimesh->custom_data_format == VS::MULTIMESH_CUSTOM_DATA_FLOAT) {
		Color c;
		c.r = dataptr[0];
		c.g = dataptr[1];
		c.b = dataptr[2];
		c.a = dataptr[3];

		return c;
	}

	return Color();
}

void RasterizerStorageGLES2::multimesh_set_as_bulk_array(RID p_multimesh, const PoolVector<float> &p_array) {
	MultiMesh *multimesh = multimesh_owner.getornull(p_multimesh);
	ERR_FAIL_COND(!multimesh);

	int dsize = multimesh->data.size();

	ERR_FAIL_COND(dsize != p_array.size());

	PoolVector<float>::Read r = p_array.read();
	copymem(multimesh->data.ptrw(), r.ptr(), dsize * sizeof(float));

	multimesh->dirty_data = true;
	multimesh->dirty_aabb = true;

	if (!multimesh->update_list.in_list()) {
		multimesh_update_list.add(&multimesh->update_list);
	}
}

void RasterizerStorageGLES2::multimesh_set_visible_instances(RID p_multimesh, int p_visible) {
	MultiMesh *multimesh = multimesh_owner.getornull(p_multimesh);
	ERR_FAIL_COND(!multimesh);

	multimesh->visible_instances = p_visible;
}

int RasterizerStorageGLES2::multimesh_get_visible_instances(RID p_multimesh) const {
	MultiMesh *multimesh = multimesh_owner.getornull(p_multimesh);
	ERR_FAIL_COND_V(!multimesh, -1);

	return multimesh->visible_instances;
}

AABB RasterizerStorageGLES2::multimesh_get_aabb(RID p_multimesh) const {
	MultiMesh *multimesh = multimesh_owner.getornull(p_multimesh);
	ERR_FAIL_COND_V(!multimesh, AABB());

	const_cast<RasterizerStorageGLES2 *>(this)->update_dirty_multimeshes();

	return multimesh->aabb;
}

void RasterizerStorageGLES2::update_dirty_multimeshes() {

	while (multimesh_update_list.first()) {

		MultiMesh *multimesh = multimesh_update_list.first()->self();

		if (multimesh->size && multimesh->dirty_aabb) {

			AABB mesh_aabb;

			if (multimesh->mesh.is_valid()) {
				mesh_aabb = mesh_get_aabb(multimesh->mesh, RID());
			} else {
				mesh_aabb.size += Vector3(0.001, 0.001, 0.001);
			}

			int stride = multimesh->color_floats + multimesh->xform_floats + multimesh->custom_data_floats;
			int count = multimesh->data.size();
			float *data = multimesh->data.ptrw();

			AABB aabb;

			if (multimesh->transform_format == VS::MULTIMESH_TRANSFORM_2D) {

				for (int i = 0; i < count; i += stride) {

					float *dataptr = &data[i];

					Transform xform;
					xform.basis[0][0] = dataptr[0];
					xform.basis[0][1] = dataptr[1];
					xform.origin[0] = dataptr[3];
					xform.basis[1][0] = dataptr[4];
					xform.basis[1][1] = dataptr[5];
					xform.origin[1] = dataptr[7];

					AABB laabb = xform.xform(mesh_aabb);

					if (i == 0) {
						aabb = laabb;
					} else {
						aabb.merge_with(laabb);
					}
				}

			} else {

				for (int i = 0; i < count; i += stride) {

					float *dataptr = &data[i];

					Transform xform;
					xform.basis.elements[0][0] = dataptr[0];
					xform.basis.elements[0][1] = dataptr[1];
					xform.basis.elements[0][2] = dataptr[2];
					xform.origin.x = dataptr[3];
					xform.basis.elements[1][0] = dataptr[4];
					xform.basis.elements[1][1] = dataptr[5];
					xform.basis.elements[1][2] = dataptr[6];
					xform.origin.y = dataptr[7];
					xform.basis.elements[2][0] = dataptr[8];
					xform.basis.elements[2][1] = dataptr[9];
					xform.basis.elements[2][2] = dataptr[10];
					xform.origin.z = dataptr[11];

					AABB laabb = xform.xform(mesh_aabb);

					if (i == 0) {
						aabb = laabb;
					} else {
						aabb.merge_with(laabb);
					}
				}
			}

			multimesh->aabb = aabb;
		}

		multimesh->dirty_aabb = false;
		multimesh->dirty_data = false;

		multimesh->instance_change_notify();

		multimesh_update_list.remove(multimesh_update_list.first());
	}
}

/* IMMEDIATE API */

RID RasterizerStorageGLES2::immediate_create() {
	Immediate *im = memnew(Immediate);
	return immediate_owner.make_rid(im);
}

void RasterizerStorageGLES2::immediate_begin(RID p_immediate, VS::PrimitiveType p_primitive, RID p_texture) {
	Immediate *im = immediate_owner.get(p_immediate);
	ERR_FAIL_COND(!im);
	ERR_FAIL_COND(im->building);

	Immediate::Chunk ic;
	ic.texture = p_texture;
	ic.primitive = p_primitive;
	im->chunks.push_back(ic);
	im->mask = 0;
	im->building = true;
}

void RasterizerStorageGLES2::immediate_vertex(RID p_immediate, const Vector3 &p_vertex) {
	Immediate *im = immediate_owner.get(p_immediate);
	ERR_FAIL_COND(!im);
	ERR_FAIL_COND(!im->building);

	Immediate::Chunk *c = &im->chunks.back()->get();

	if (c->vertices.empty() && im->chunks.size() == 1) {
		im->aabb.position = p_vertex;
		im->aabb.size = Vector3();
	} else {
		im->aabb.expand_to(p_vertex);
	}

	if (im->mask & VS::ARRAY_FORMAT_NORMAL)
		c->normals.push_back(chunk_normal);
	if (im->mask & VS::ARRAY_FORMAT_TANGENT)
		c->tangents.push_back(chunk_tangent);
	if (im->mask & VS::ARRAY_FORMAT_COLOR)
		c->colors.push_back(chunk_color);
	if (im->mask & VS::ARRAY_FORMAT_TEX_UV)
		c->uvs.push_back(chunk_uv);
	if (im->mask & VS::ARRAY_FORMAT_TEX_UV2)
		c->uv2s.push_back(chunk_uv2);
	im->mask |= VS::ARRAY_FORMAT_VERTEX;
	c->vertices.push_back(p_vertex);
}

void RasterizerStorageGLES2::immediate_normal(RID p_immediate, const Vector3 &p_normal) {
	Immediate *im = immediate_owner.get(p_immediate);
	ERR_FAIL_COND(!im);
	ERR_FAIL_COND(!im->building);

	im->mask |= VS::ARRAY_FORMAT_NORMAL;
	chunk_normal = p_normal;
}

void RasterizerStorageGLES2::immediate_tangent(RID p_immediate, const Plane &p_tangent) {
	Immediate *im = immediate_owner.get(p_immediate);
	ERR_FAIL_COND(!im);
	ERR_FAIL_COND(!im->building);

	im->mask |= VS::ARRAY_FORMAT_TANGENT;
	chunk_tangent = p_tangent;
}

void RasterizerStorageGLES2::immediate_color(RID p_immediate, const Color &p_color) {
	Immediate *im = immediate_owner.get(p_immediate);
	ERR_FAIL_COND(!im);
	ERR_FAIL_COND(!im->building);

	im->mask |= VS::ARRAY_FORMAT_COLOR;
	chunk_color = p_color;
}

void RasterizerStorageGLES2::immediate_uv(RID p_immediate, const Vector2 &tex_uv) {
	Immediate *im = immediate_owner.get(p_immediate);
	ERR_FAIL_COND(!im);
	ERR_FAIL_COND(!im->building);

	im->mask |= VS::ARRAY_FORMAT_TEX_UV;
	chunk_uv = tex_uv;
}

void RasterizerStorageGLES2::immediate_uv2(RID p_immediate, const Vector2 &tex_uv) {
	Immediate *im = immediate_owner.get(p_immediate);
	ERR_FAIL_COND(!im);
	ERR_FAIL_COND(!im->building);

	im->mask |= VS::ARRAY_FORMAT_TEX_UV2;
	chunk_uv2 = tex_uv;
}

void RasterizerStorageGLES2::immediate_end(RID p_immediate) {
	Immediate *im = immediate_owner.get(p_immediate);
	ERR_FAIL_COND(!im);
	ERR_FAIL_COND(!im->building);

	im->building = false;
	im->instance_change_notify();
}

void RasterizerStorageGLES2::immediate_clear(RID p_immediate) {
	Immediate *im = immediate_owner.get(p_immediate);
	ERR_FAIL_COND(!im);
	ERR_FAIL_COND(im->building);

	im->chunks.clear();
	im->instance_change_notify();
}

AABB RasterizerStorageGLES2::immediate_get_aabb(RID p_immediate) const {
	Immediate *im = immediate_owner.get(p_immediate);
	ERR_FAIL_COND_V(!im, AABB());
	return im->aabb;
}

void RasterizerStorageGLES2::immediate_set_material(RID p_immediate, RID p_material) {
	Immediate *im = immediate_owner.get(p_immediate);
	ERR_FAIL_COND(!im);

	im->material = p_material;
	im->instance_material_change_notify();
}

RID RasterizerStorageGLES2::immediate_get_material(RID p_immediate) const {
	const Immediate *im = immediate_owner.get(p_immediate);
	ERR_FAIL_COND_V(!im, RID());
	return im->material;
}

/* SKELETON API */

RID RasterizerStorageGLES2::skeleton_create() {

	Skeleton *skeleton = memnew(Skeleton);

	return skeleton_owner.make_rid(skeleton);
}

void RasterizerStorageGLES2::skeleton_allocate(RID p_skeleton, int p_bones, bool p_2d_skeleton) {

	Skeleton *skeleton = skeleton_owner.getornull(p_skeleton);
	ERR_FAIL_COND(!skeleton);
	ERR_FAIL_COND(p_bones < 0);

	if (skeleton->size == p_bones && skeleton->use_2d == p_2d_skeleton) {
		return;
	}

	skeleton->size = p_bones;
	skeleton->use_2d = p_2d_skeleton;

	// TODO use float texture for vertex shader
	if (config.float_texture_supported) {
		glGenTextures(1, &skeleton->tex_id);

		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, skeleton->tex_id);

#ifdef GLES_OVER_GL
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, p_bones * 3, 1, 0, GL_RGBA, GL_FLOAT, NULL);
#else
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, p_bones * 3, 1, 0, GL_RGBA, GL_FLOAT, NULL);
#endif

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

		glBindTexture(GL_TEXTURE_2D, 0);
	}
	if (skeleton->use_2d) {
		skeleton->bone_data.resize(p_bones * 4 * 2);
	} else {
		skeleton->bone_data.resize(p_bones * 4 * 3);
	}
}

int RasterizerStorageGLES2::skeleton_get_bone_count(RID p_skeleton) const {
	Skeleton *skeleton = skeleton_owner.getornull(p_skeleton);
	ERR_FAIL_COND_V(!skeleton, 0);

	return skeleton->size;
}

void RasterizerStorageGLES2::skeleton_bone_set_transform(RID p_skeleton, int p_bone, const Transform &p_transform) {
	Skeleton *skeleton = skeleton_owner.getornull(p_skeleton);
	ERR_FAIL_COND(!skeleton);

	ERR_FAIL_INDEX(p_bone, skeleton->size);
	ERR_FAIL_COND(skeleton->use_2d);

	float *bone_data = skeleton->bone_data.ptrw();

	int base_offset = p_bone * 4 * 3;

	bone_data[base_offset + 0] = p_transform.basis[0].x;
	bone_data[base_offset + 1] = p_transform.basis[0].y;
	bone_data[base_offset + 2] = p_transform.basis[0].z;
	bone_data[base_offset + 3] = p_transform.origin.x;

	bone_data[base_offset + 4] = p_transform.basis[1].x;
	bone_data[base_offset + 5] = p_transform.basis[1].y;
	bone_data[base_offset + 6] = p_transform.basis[1].z;
	bone_data[base_offset + 7] = p_transform.origin.y;

	bone_data[base_offset + 8] = p_transform.basis[2].x;
	bone_data[base_offset + 9] = p_transform.basis[2].y;
	bone_data[base_offset + 10] = p_transform.basis[2].z;
	bone_data[base_offset + 11] = p_transform.origin.z;

	if (!skeleton->update_list.in_list()) {
		skeleton_update_list.add(&skeleton->update_list);
	}
}

Transform RasterizerStorageGLES2::skeleton_bone_get_transform(RID p_skeleton, int p_bone) const {
	Skeleton *skeleton = skeleton_owner.getornull(p_skeleton);
	ERR_FAIL_COND_V(!skeleton, Transform());

	ERR_FAIL_INDEX_V(p_bone, skeleton->size, Transform());
	ERR_FAIL_COND_V(skeleton->use_2d, Transform());

	const float *bone_data = skeleton->bone_data.ptr();

	Transform ret;

	int base_offset = p_bone * 4 * 3;

	ret.basis[0].x = bone_data[base_offset + 0];
	ret.basis[0].y = bone_data[base_offset + 1];
	ret.basis[0].z = bone_data[base_offset + 2];
	ret.origin.x = bone_data[base_offset + 3];

	ret.basis[1].x = bone_data[base_offset + 4];
	ret.basis[1].y = bone_data[base_offset + 5];
	ret.basis[1].z = bone_data[base_offset + 6];
	ret.origin.y = bone_data[base_offset + 7];

	ret.basis[2].x = bone_data[base_offset + 8];
	ret.basis[2].y = bone_data[base_offset + 9];
	ret.basis[2].z = bone_data[base_offset + 10];
	ret.origin.z = bone_data[base_offset + 11];

	return ret;
}
void RasterizerStorageGLES2::skeleton_bone_set_transform_2d(RID p_skeleton, int p_bone, const Transform2D &p_transform) {
	Skeleton *skeleton = skeleton_owner.getornull(p_skeleton);
	ERR_FAIL_COND(!skeleton);

	ERR_FAIL_INDEX(p_bone, skeleton->size);
	ERR_FAIL_COND(!skeleton->use_2d);

	float *bone_data = skeleton->bone_data.ptrw();

	int base_offset = p_bone * 4 * 2;

	bone_data[base_offset + 0] = p_transform[0][0];
	bone_data[base_offset + 1] = p_transform[1][0];
	bone_data[base_offset + 2] = 0;
	bone_data[base_offset + 3] = p_transform[2][0];
	bone_data[base_offset + 4] = p_transform[0][1];
	bone_data[base_offset + 5] = p_transform[1][1];
	bone_data[base_offset + 6] = 0;
	bone_data[base_offset + 7] = p_transform[2][1];

	if (!skeleton->update_list.in_list()) {
		skeleton_update_list.add(&skeleton->update_list);
	}
}

Transform2D RasterizerStorageGLES2::skeleton_bone_get_transform_2d(RID p_skeleton, int p_bone) const {
	Skeleton *skeleton = skeleton_owner.getornull(p_skeleton);
	ERR_FAIL_COND_V(!skeleton, Transform2D());

	ERR_FAIL_INDEX_V(p_bone, skeleton->size, Transform2D());
	ERR_FAIL_COND_V(!skeleton->use_2d, Transform2D());

	const float *bone_data = skeleton->bone_data.ptr();

	Transform2D ret;

	int base_offset = p_bone * 4 * 2;

	ret[0][0] = bone_data[base_offset + 0];
	ret[1][0] = bone_data[base_offset + 1];
	ret[2][0] = bone_data[base_offset + 3];
	ret[0][1] = bone_data[base_offset + 4];
	ret[1][1] = bone_data[base_offset + 5];
	ret[2][1] = bone_data[base_offset + 7];

	return ret;
}

void RasterizerStorageGLES2::skeleton_set_base_transform_2d(RID p_skeleton, const Transform2D &p_base_transform) {
}

void RasterizerStorageGLES2::_update_skeleton_transform_buffer(const PoolVector<float> &p_data, size_t p_size) {

	glBindBuffer(GL_ARRAY_BUFFER, resources.skeleton_transform_buffer);

	if (p_size > resources.skeleton_transform_buffer_size) {
		// new requested buffer is bigger, so resizing the GPU buffer

		resources.skeleton_transform_buffer_size = p_size;

		glBufferData(GL_ARRAY_BUFFER, p_size * sizeof(float), p_data.read().ptr(), GL_DYNAMIC_DRAW);
	} else {
		glBufferSubData(GL_ARRAY_BUFFER, 0, p_size * sizeof(float), p_data.read().ptr());
	}

	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

void RasterizerStorageGLES2::update_dirty_skeletons() {

	if (!config.float_texture_supported)
		return;

	glActiveTexture(GL_TEXTURE0);

	while (skeleton_update_list.first()) {
		Skeleton *skeleton = skeleton_update_list.first()->self();

		if (skeleton->size) {
			glBindTexture(GL_TEXTURE_2D, skeleton->tex_id);

			glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, skeleton->size * 3, 1, GL_RGBA, GL_FLOAT, skeleton->bone_data.ptr());
		}

		for (Set<RasterizerScene::InstanceBase *>::Element *E = skeleton->instances.front(); E; E = E->next()) {
			E->get()->base_changed();
		}

		skeleton_update_list.remove(skeleton_update_list.first());
	}
}

/* Light API */

RID RasterizerStorageGLES2::light_create(VS::LightType p_type) {

	Light *light = memnew(Light);

	light->type = p_type;

	light->param[VS::LIGHT_PARAM_ENERGY] = 1.0;
	light->param[VS::LIGHT_PARAM_INDIRECT_ENERGY] = 1.0;
	light->param[VS::LIGHT_PARAM_SPECULAR] = 0.5;
	light->param[VS::LIGHT_PARAM_RANGE] = 1.0;
	light->param[VS::LIGHT_PARAM_SPOT_ANGLE] = 45;
	light->param[VS::LIGHT_PARAM_CONTACT_SHADOW_SIZE] = 45;
	light->param[VS::LIGHT_PARAM_SHADOW_MAX_DISTANCE] = 0;
	light->param[VS::LIGHT_PARAM_SHADOW_SPLIT_1_OFFSET] = 0.1;
	light->param[VS::LIGHT_PARAM_SHADOW_SPLIT_2_OFFSET] = 0.3;
	light->param[VS::LIGHT_PARAM_SHADOW_SPLIT_3_OFFSET] = 0.6;
	light->param[VS::LIGHT_PARAM_SHADOW_NORMAL_BIAS] = 0.1;
	light->param[VS::LIGHT_PARAM_SHADOW_BIAS_SPLIT_SCALE] = 0.1;

	light->color = Color(1, 1, 1, 1);
	light->shadow = false;
	light->negative = false;
	light->cull_mask = 0xFFFFFFFF;
	light->directional_shadow_mode = VS::LIGHT_DIRECTIONAL_SHADOW_ORTHOGONAL;
	light->omni_shadow_mode = VS::LIGHT_OMNI_SHADOW_DUAL_PARABOLOID;
	light->omni_shadow_detail = VS::LIGHT_OMNI_SHADOW_DETAIL_VERTICAL;
	light->directional_blend_splits = false;
	light->directional_range_mode = VS::LIGHT_DIRECTIONAL_SHADOW_DEPTH_RANGE_STABLE;
	light->reverse_cull = false;
	light->version = 0;

	return light_owner.make_rid(light);
}

void RasterizerStorageGLES2::light_set_color(RID p_light, const Color &p_color) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND(!light);

	light->color = p_color;
}

void RasterizerStorageGLES2::light_set_param(RID p_light, VS::LightParam p_param, float p_value) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND(!light);
	ERR_FAIL_INDEX(p_param, VS::LIGHT_PARAM_MAX);

	switch (p_param) {
		case VS::LIGHT_PARAM_RANGE:
		case VS::LIGHT_PARAM_SPOT_ANGLE:
		case VS::LIGHT_PARAM_SHADOW_MAX_DISTANCE:
		case VS::LIGHT_PARAM_SHADOW_SPLIT_1_OFFSET:
		case VS::LIGHT_PARAM_SHADOW_SPLIT_2_OFFSET:
		case VS::LIGHT_PARAM_SHADOW_SPLIT_3_OFFSET:
		case VS::LIGHT_PARAM_SHADOW_NORMAL_BIAS:
		case VS::LIGHT_PARAM_SHADOW_BIAS: {
			light->version++;
			light->instance_change_notify();
		} break;
	}

	light->param[p_param] = p_value;
}

void RasterizerStorageGLES2::light_set_shadow(RID p_light, bool p_enabled) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND(!light);

	light->shadow = p_enabled;

	light->version++;
	light->instance_change_notify();
}

void RasterizerStorageGLES2::light_set_shadow_color(RID p_light, const Color &p_color) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND(!light);

	light->shadow_color = p_color;
}

void RasterizerStorageGLES2::light_set_projector(RID p_light, RID p_texture) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND(!light);

	light->projector = p_texture;
}

void RasterizerStorageGLES2::light_set_negative(RID p_light, bool p_enable) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND(!light);

	light->negative = p_enable;
}

void RasterizerStorageGLES2::light_set_cull_mask(RID p_light, uint32_t p_mask) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND(!light);

	light->cull_mask = p_mask;

	light->version++;
	light->instance_change_notify();
}

void RasterizerStorageGLES2::light_set_reverse_cull_face_mode(RID p_light, bool p_enabled) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND(!light);

	light->reverse_cull = p_enabled;
}

void RasterizerStorageGLES2::light_omni_set_shadow_mode(RID p_light, VS::LightOmniShadowMode p_mode) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND(!light);

	light->omni_shadow_mode = p_mode;

	light->version++;
	light->instance_change_notify();
}

VS::LightOmniShadowMode RasterizerStorageGLES2::light_omni_get_shadow_mode(RID p_light) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND_V(!light, VS::LIGHT_OMNI_SHADOW_CUBE);

	return light->omni_shadow_mode;
}

void RasterizerStorageGLES2::light_omni_set_shadow_detail(RID p_light, VS::LightOmniShadowDetail p_detail) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND(!light);

	light->omni_shadow_detail = p_detail;

	light->version++;
	light->instance_change_notify();
}

void RasterizerStorageGLES2::light_directional_set_shadow_mode(RID p_light, VS::LightDirectionalShadowMode p_mode) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND(!light);

	light->directional_shadow_mode = p_mode;

	light->version++;
	light->instance_change_notify();
}

void RasterizerStorageGLES2::light_directional_set_blend_splits(RID p_light, bool p_enable) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND(!light);

	light->directional_blend_splits = p_enable;

	light->version++;
	light->instance_change_notify();
}

bool RasterizerStorageGLES2::light_directional_get_blend_splits(RID p_light) const {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND_V(!light, false);
	return light->directional_blend_splits;
}

VS::LightDirectionalShadowMode RasterizerStorageGLES2::light_directional_get_shadow_mode(RID p_light) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND_V(!light, VS::LIGHT_DIRECTIONAL_SHADOW_ORTHOGONAL);
	return light->directional_shadow_mode;
}

void RasterizerStorageGLES2::light_directional_set_shadow_depth_range_mode(RID p_light, VS::LightDirectionalShadowDepthRangeMode p_range_mode) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND(!light);

	light->directional_range_mode = p_range_mode;
}

VS::LightDirectionalShadowDepthRangeMode RasterizerStorageGLES2::light_directional_get_shadow_depth_range_mode(RID p_light) const {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND_V(!light, VS::LIGHT_DIRECTIONAL_SHADOW_DEPTH_RANGE_STABLE);

	return light->directional_range_mode;
}

VS::LightType RasterizerStorageGLES2::light_get_type(RID p_light) const {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND_V(!light, VS::LIGHT_DIRECTIONAL);

	return light->type;
}

float RasterizerStorageGLES2::light_get_param(RID p_light, VS::LightParam p_param) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND_V(!light, 0.0);
	ERR_FAIL_INDEX_V(p_param, VS::LIGHT_PARAM_MAX, 0.0);

	return light->param[p_param];
}

Color RasterizerStorageGLES2::light_get_color(RID p_light) {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND_V(!light, Color());

	return light->color;
}

bool RasterizerStorageGLES2::light_has_shadow(RID p_light) const {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND_V(!light, false);

	return light->shadow;
}

uint64_t RasterizerStorageGLES2::light_get_version(RID p_light) const {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND_V(!light, 0);

	return light->version;
}

AABB RasterizerStorageGLES2::light_get_aabb(RID p_light) const {
	Light *light = light_owner.getornull(p_light);
	ERR_FAIL_COND_V(!light, AABB());

	switch (light->type) {

		case VS::LIGHT_SPOT: {
			float len = light->param[VS::LIGHT_PARAM_RANGE];
			float size = Math::tan(Math::deg2rad(light->param[VS::LIGHT_PARAM_SPOT_ANGLE])) * len;
			return AABB(Vector3(-size, -size, -len), Vector3(size * 2, size * 2, len));
		} break;

		case VS::LIGHT_OMNI: {
			float r = light->param[VS::LIGHT_PARAM_RANGE];
			return AABB(-Vector3(r, r, r), Vector3(r, r, r) * 2);
		} break;

		case VS::LIGHT_DIRECTIONAL: {
			return AABB();
		} break;
	}

	ERR_FAIL_V(AABB());
	return AABB();
}

/* PROBE API */

RID RasterizerStorageGLES2::reflection_probe_create() {
	return RID();
}

void RasterizerStorageGLES2::reflection_probe_set_update_mode(RID p_probe, VS::ReflectionProbeUpdateMode p_mode) {
}

void RasterizerStorageGLES2::reflection_probe_set_intensity(RID p_probe, float p_intensity) {
}

void RasterizerStorageGLES2::reflection_probe_set_interior_ambient(RID p_probe, const Color &p_ambient) {
}

void RasterizerStorageGLES2::reflection_probe_set_interior_ambient_energy(RID p_probe, float p_energy) {
}

void RasterizerStorageGLES2::reflection_probe_set_interior_ambient_probe_contribution(RID p_probe, float p_contrib) {
}

void RasterizerStorageGLES2::reflection_probe_set_max_distance(RID p_probe, float p_distance) {
}

void RasterizerStorageGLES2::reflection_probe_set_extents(RID p_probe, const Vector3 &p_extents) {
}

void RasterizerStorageGLES2::reflection_probe_set_origin_offset(RID p_probe, const Vector3 &p_offset) {
}

void RasterizerStorageGLES2::reflection_probe_set_as_interior(RID p_probe, bool p_enable) {
}

void RasterizerStorageGLES2::reflection_probe_set_enable_box_projection(RID p_probe, bool p_enable) {
}

void RasterizerStorageGLES2::reflection_probe_set_enable_shadows(RID p_probe, bool p_enable) {
}

void RasterizerStorageGLES2::reflection_probe_set_cull_mask(RID p_probe, uint32_t p_layers) {
}

AABB RasterizerStorageGLES2::reflection_probe_get_aabb(RID p_probe) const {
	return AABB();
}
VS::ReflectionProbeUpdateMode RasterizerStorageGLES2::reflection_probe_get_update_mode(RID p_probe) const {
	return VS::REFLECTION_PROBE_UPDATE_ALWAYS;
}

uint32_t RasterizerStorageGLES2::reflection_probe_get_cull_mask(RID p_probe) const {
	return 0;
}

Vector3 RasterizerStorageGLES2::reflection_probe_get_extents(RID p_probe) const {
	return Vector3();
}
Vector3 RasterizerStorageGLES2::reflection_probe_get_origin_offset(RID p_probe) const {
	return Vector3();
}

bool RasterizerStorageGLES2::reflection_probe_renders_shadows(RID p_probe) const {
	return false;
}

float RasterizerStorageGLES2::reflection_probe_get_origin_max_distance(RID p_probe) const {
	return 0;
}

RID RasterizerStorageGLES2::gi_probe_create() {
	return RID();
}

void RasterizerStorageGLES2::gi_probe_set_bounds(RID p_probe, const AABB &p_bounds) {
}

AABB RasterizerStorageGLES2::gi_probe_get_bounds(RID p_probe) const {
	return AABB();
}

void RasterizerStorageGLES2::gi_probe_set_cell_size(RID p_probe, float p_size) {
}

float RasterizerStorageGLES2::gi_probe_get_cell_size(RID p_probe) const {
	return 0.0;
}

void RasterizerStorageGLES2::gi_probe_set_to_cell_xform(RID p_probe, const Transform &p_xform) {
}

Transform RasterizerStorageGLES2::gi_probe_get_to_cell_xform(RID p_probe) const {
	return Transform();
}

void RasterizerStorageGLES2::gi_probe_set_dynamic_data(RID p_probe, const PoolVector<int> &p_data) {
}

PoolVector<int> RasterizerStorageGLES2::gi_probe_get_dynamic_data(RID p_probe) const {
	return PoolVector<int>();
}

void RasterizerStorageGLES2::gi_probe_set_dynamic_range(RID p_probe, int p_range) {
}

int RasterizerStorageGLES2::gi_probe_get_dynamic_range(RID p_probe) const {
	return 0;
}

void RasterizerStorageGLES2::gi_probe_set_energy(RID p_probe, float p_range) {
}

void RasterizerStorageGLES2::gi_probe_set_bias(RID p_probe, float p_range) {
}

void RasterizerStorageGLES2::gi_probe_set_normal_bias(RID p_probe, float p_range) {
}

void RasterizerStorageGLES2::gi_probe_set_propagation(RID p_probe, float p_range) {
}

void RasterizerStorageGLES2::gi_probe_set_interior(RID p_probe, bool p_enable) {
}

bool RasterizerStorageGLES2::gi_probe_is_interior(RID p_probe) const {
	return false;
}

void RasterizerStorageGLES2::gi_probe_set_compress(RID p_probe, bool p_enable) {
}

bool RasterizerStorageGLES2::gi_probe_is_compressed(RID p_probe) const {
	return false;
}
float RasterizerStorageGLES2::gi_probe_get_energy(RID p_probe) const {
	return 0;
}

float RasterizerStorageGLES2::gi_probe_get_bias(RID p_probe) const {
	return 0;
}

float RasterizerStorageGLES2::gi_probe_get_normal_bias(RID p_probe) const {
	return 0;
}

float RasterizerStorageGLES2::gi_probe_get_propagation(RID p_probe) const {
	return 0;
}

uint32_t RasterizerStorageGLES2::gi_probe_get_version(RID p_probe) {
	return 0;
}

RasterizerStorage::GIProbeCompression RasterizerStorageGLES2::gi_probe_get_dynamic_data_get_preferred_compression() const {
	return GI_PROBE_UNCOMPRESSED;
}

RID RasterizerStorageGLES2::gi_probe_dynamic_data_create(int p_width, int p_height, int p_depth, GIProbeCompression p_compression) {
	return RID();
}

void RasterizerStorageGLES2::gi_probe_dynamic_data_update(RID p_gi_probe_data, int p_depth_slice, int p_slice_count, int p_mipmap, const void *p_data) {
}

///////

RID RasterizerStorageGLES2::lightmap_capture_create() {
	return RID();
}

void RasterizerStorageGLES2::lightmap_capture_set_bounds(RID p_capture, const AABB &p_bounds) {
}

AABB RasterizerStorageGLES2::lightmap_capture_get_bounds(RID p_capture) const {
	return AABB();
}

void RasterizerStorageGLES2::lightmap_capture_set_octree(RID p_capture, const PoolVector<uint8_t> &p_octree) {
}

PoolVector<uint8_t> RasterizerStorageGLES2::lightmap_capture_get_octree(RID p_capture) const {
	return PoolVector<uint8_t>();
}

void RasterizerStorageGLES2::lightmap_capture_set_octree_cell_transform(RID p_capture, const Transform &p_xform) {
}

Transform RasterizerStorageGLES2::lightmap_capture_get_octree_cell_transform(RID p_capture) const {
	return Transform();
}

void RasterizerStorageGLES2::lightmap_capture_set_octree_cell_subdiv(RID p_capture, int p_subdiv) {
}

int RasterizerStorageGLES2::lightmap_capture_get_octree_cell_subdiv(RID p_capture) const {
	return 0;
}

void RasterizerStorageGLES2::lightmap_capture_set_energy(RID p_capture, float p_energy) {
}

float RasterizerStorageGLES2::lightmap_capture_get_energy(RID p_capture) const {
	return 0.0;
}

const PoolVector<RasterizerStorage::LightmapCaptureOctree> *RasterizerStorageGLES2::lightmap_capture_get_octree_ptr(RID p_capture) const {
	return NULL;
}

///////

RID RasterizerStorageGLES2::particles_create() {
	return RID();
}

void RasterizerStorageGLES2::particles_set_emitting(RID p_particles, bool p_emitting) {
}

bool RasterizerStorageGLES2::particles_get_emitting(RID p_particles) {
	return false;
}

void RasterizerStorageGLES2::particles_set_amount(RID p_particles, int p_amount) {
}

void RasterizerStorageGLES2::particles_set_lifetime(RID p_particles, float p_lifetime) {
}

void RasterizerStorageGLES2::particles_set_one_shot(RID p_particles, bool p_one_shot) {
}

void RasterizerStorageGLES2::particles_set_pre_process_time(RID p_particles, float p_time) {
}

void RasterizerStorageGLES2::particles_set_explosiveness_ratio(RID p_particles, float p_ratio) {
}

void RasterizerStorageGLES2::particles_set_randomness_ratio(RID p_particles, float p_ratio) {
}

void RasterizerStorageGLES2::particles_set_custom_aabb(RID p_particles, const AABB &p_aabb) {
}

void RasterizerStorageGLES2::particles_set_speed_scale(RID p_particles, float p_scale) {
}

void RasterizerStorageGLES2::particles_set_use_local_coordinates(RID p_particles, bool p_enable) {
}

void RasterizerStorageGLES2::particles_set_fixed_fps(RID p_particles, int p_fps) {
}

void RasterizerStorageGLES2::particles_set_fractional_delta(RID p_particles, bool p_enable) {
}

void RasterizerStorageGLES2::particles_set_process_material(RID p_particles, RID p_material) {
}

void RasterizerStorageGLES2::particles_set_draw_order(RID p_particles, VS::ParticlesDrawOrder p_order) {
}

void RasterizerStorageGLES2::particles_set_draw_passes(RID p_particles, int p_passes) {
}

void RasterizerStorageGLES2::particles_set_draw_pass_mesh(RID p_particles, int p_pass, RID p_mesh) {
}

void RasterizerStorageGLES2::particles_restart(RID p_particles) {
}

void RasterizerStorageGLES2::particles_request_process(RID p_particles) {
}

AABB RasterizerStorageGLES2::particles_get_current_aabb(RID p_particles) {
	return AABB();
}

AABB RasterizerStorageGLES2::particles_get_aabb(RID p_particles) const {
	return AABB();
}

void RasterizerStorageGLES2::particles_set_emission_transform(RID p_particles, const Transform &p_transform) {
}

int RasterizerStorageGLES2::particles_get_draw_passes(RID p_particles) const {
	return 0;
}

RID RasterizerStorageGLES2::particles_get_draw_pass_mesh(RID p_particles, int p_pass) const {
	return RID();
}

void RasterizerStorageGLES2::update_particles() {
}

////////

void RasterizerStorageGLES2::instance_add_skeleton(RID p_skeleton, RasterizerScene::InstanceBase *p_instance) {
}

void RasterizerStorageGLES2::instance_remove_skeleton(RID p_skeleton, RasterizerScene::InstanceBase *p_instance) {
}

void RasterizerStorageGLES2::instance_add_dependency(RID p_base, RasterizerScene::InstanceBase *p_instance) {
}

void RasterizerStorageGLES2::instance_remove_dependency(RID p_base, RasterizerScene::InstanceBase *p_instance) {
}

/* RENDER TARGET */

void RasterizerStorageGLES2::_render_target_allocate(RenderTarget *rt) {

	if (rt->width <= 0 || rt->height <= 0)
		return;

	Texture *texture = texture_owner.getornull(rt->texture);
	ERR_FAIL_COND(!texture);

	// create fbo

	glGenFramebuffers(1, &rt->fbo);
	glBindFramebuffer(GL_FRAMEBUFFER, rt->fbo);

	// color

	glGenTextures(1, &rt->color);
	glBindTexture(GL_TEXTURE_2D, rt->color);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, rt->width, rt->height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);

	if (texture->flags & VS::TEXTURE_FLAG_FILTER) {

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	} else {

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	}
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, rt->color, 0);

	// depth

	glGenRenderbuffers(1, &rt->depth);
	glBindRenderbuffer(GL_RENDERBUFFER, rt->depth);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, rt->width, rt->height);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rt->depth);

	GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);

	if (status != GL_FRAMEBUFFER_COMPLETE) {

		glDeleteRenderbuffers(1, &rt->fbo);
		glDeleteTextures(1, &rt->depth);
		glDeleteTextures(1, &rt->color);
		rt->fbo = 0;
		rt->width = 0;
		rt->height = 0;
		rt->color = 0;
		rt->depth = 0;
		texture->tex_id = 0;
		texture->active = false;
		WARN_PRINT("Could not create framebuffer!!");
		return;
	}

	texture->format = Image::FORMAT_RGBA8;
	texture->gl_format_cache = GL_RGBA;
	texture->gl_type_cache = GL_UNSIGNED_BYTE;
	texture->gl_internal_format_cache = GL_RGBA;
	texture->tex_id = rt->color;
	texture->width = rt->width;
	texture->alloc_width = rt->width;
	texture->height = rt->height;
	texture->alloc_height = rt->height;
	texture->active = true;

	texture_set_flags(rt->texture, texture->flags);

	glClearColor(0, 0, 0, 0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// copy texscreen buffers
	{
		int w = rt->width;
		int h = rt->height;

		glGenTextures(1, &rt->copy_screen_effect.color);
		glBindTexture(GL_TEXTURE_2D, rt->copy_screen_effect.color);

		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);

		glGenFramebuffers(1, &rt->copy_screen_effect.fbo);
		glBindFramebuffer(GL_FRAMEBUFFER, rt->copy_screen_effect.fbo);
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, rt->color, 0);

		GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
		if (status != GL_FRAMEBUFFER_COMPLETE) {
			_render_target_clear(rt);
			ERR_FAIL_COND(status != GL_FRAMEBUFFER_COMPLETE);
		}
	}

	glBindFramebuffer(GL_FRAMEBUFFER, RasterizerStorageGLES2::system_fbo);
}

void RasterizerStorageGLES2::_render_target_clear(RenderTarget *rt) {

	if (rt->fbo) {
		glDeleteFramebuffers(1, &rt->fbo);
		glDeleteTextures(1, &rt->color);
		rt->fbo = 0;
	}

	if (rt->depth) {
		glDeleteRenderbuffers(1, &rt->depth);
		rt->depth = 0;
	}

	Texture *tex = texture_owner.get(rt->texture);
	tex->alloc_height = 0;
	tex->alloc_width = 0;
	tex->width = 0;
	tex->height = 0;
	tex->active = false;

	// TODO hardcoded texscreen copy effect
	if (rt->copy_screen_effect.color) {
		glDeleteFramebuffers(1, &rt->copy_screen_effect.fbo);
		rt->copy_screen_effect.fbo = 0;

		glDeleteTextures(1, &rt->copy_screen_effect.color);
		rt->copy_screen_effect.color = 0;
	}
}

RID RasterizerStorageGLES2::render_target_create() {

	RenderTarget *rt = memnew(RenderTarget);

	Texture *t = memnew(Texture);

	t->flags = 0;
	t->width = 0;
	t->height = 0;
	t->alloc_height = 0;
	t->alloc_width = 0;
	t->format = Image::FORMAT_R8;
	t->target = GL_TEXTURE_2D;
	t->gl_format_cache = 0;
	t->gl_internal_format_cache = 0;
	t->gl_type_cache = 0;
	t->data_size = 0;
	t->total_data_size = 0;
	t->ignore_mipmaps = false;
	t->compressed = false;
	t->mipmaps = 1;
	t->active = true;
	t->tex_id = 0;
	t->render_target = rt;

	rt->texture = texture_owner.make_rid(t);

	return render_target_owner.make_rid(rt);
}

void RasterizerStorageGLES2::render_target_set_size(RID p_render_target, int p_width, int p_height) {

	RenderTarget *rt = render_target_owner.getornull(p_render_target);
	ERR_FAIL_COND(!rt);

	if (p_width == rt->width && p_height == rt->height)
		return;

	_render_target_clear(rt);

	rt->width = p_width;
	rt->height = p_height;

	_render_target_allocate(rt);
}

RID RasterizerStorageGLES2::render_target_get_texture(RID p_render_target) const {

	RenderTarget *rt = render_target_owner.getornull(p_render_target);
	ERR_FAIL_COND_V(!rt, RID());

	return rt->texture;
}

void RasterizerStorageGLES2::render_target_set_flag(RID p_render_target, RenderTargetFlags p_flag, bool p_value) {
	RenderTarget *rt = render_target_owner.getornull(p_render_target);
	ERR_FAIL_COND(!rt);

	rt->flags[p_flag] = p_value;

	switch (p_flag) {
		case RENDER_TARGET_HDR:
		case RENDER_TARGET_NO_3D:
		case RENDER_TARGET_NO_SAMPLING:
		case RENDER_TARGET_NO_3D_EFFECTS: {
			//must reset for these formats
			_render_target_clear(rt);
			_render_target_allocate(rt);

		} break;
		default: {}
	}
}

bool RasterizerStorageGLES2::render_target_was_used(RID p_render_target) {
	RenderTarget *rt = render_target_owner.getornull(p_render_target);
	ERR_FAIL_COND_V(!rt, false);

	return rt->used_in_frame;
}

void RasterizerStorageGLES2::render_target_clear_used(RID p_render_target) {
	RenderTarget *rt = render_target_owner.getornull(p_render_target);
	ERR_FAIL_COND(!rt);

	rt->used_in_frame = false;
}

void RasterizerStorageGLES2::render_target_set_msaa(RID p_render_target, VS::ViewportMSAA p_msaa) {
	RenderTarget *rt = render_target_owner.getornull(p_render_target);
	ERR_FAIL_COND(!rt);

	if (rt->msaa == p_msaa)
		return;

	_render_target_clear(rt);
	rt->msaa = p_msaa;
	_render_target_allocate(rt);
}

/* CANVAS SHADOW */

RID RasterizerStorageGLES2::canvas_light_shadow_buffer_create(int p_width) {
	return RID();
}

/* LIGHT SHADOW MAPPING */

RID RasterizerStorageGLES2::canvas_light_occluder_create() {
	return RID();
}

void RasterizerStorageGLES2::canvas_light_occluder_set_polylines(RID p_occluder, const PoolVector<Vector2> &p_lines) {
}

VS::InstanceType RasterizerStorageGLES2::get_base_type(RID p_rid) const {

	if (mesh_owner.owns(p_rid)) {
		return VS::INSTANCE_MESH;
	} else if (light_owner.owns(p_rid)) {
		return VS::INSTANCE_LIGHT;
	} else if (multimesh_owner.owns(p_rid)) {
		return VS::INSTANCE_MULTIMESH;
	} else if (immediate_owner.owns(p_rid)) {
		return VS::INSTANCE_IMMEDIATE;
	} else {
		return VS::INSTANCE_NONE;
	}
}

bool RasterizerStorageGLES2::free(RID p_rid) {

	if (render_target_owner.owns(p_rid)) {

		RenderTarget *rt = render_target_owner.getornull(p_rid);
		_render_target_clear(rt);

		Texture *t = texture_owner.get(rt->texture);
		texture_owner.free(rt->texture);
		memdelete(t);
		render_target_owner.free(p_rid);
		memdelete(rt);

		return true;
	} else if (texture_owner.owns(p_rid)) {

		Texture *t = texture_owner.get(p_rid);
		// can't free a render target texture
		ERR_FAIL_COND_V(t->render_target, true);

		info.texture_mem -= t->total_data_size;
		texture_owner.free(p_rid);
		memdelete(t);

		return true;
	} else if (sky_owner.owns(p_rid)) {

		Sky *sky = sky_owner.get(p_rid);
		sky_set_texture(p_rid, RID(), 256);
		sky_owner.free(p_rid);
		memdelete(sky);

		return true;
	} else if (shader_owner.owns(p_rid)) {

		Shader *shader = shader_owner.get(p_rid);

		if (shader->shader) {
			shader->shader->free_custom_shader(shader->custom_code_id);
		}

		if (shader->dirty_list.in_list()) {
			_shader_dirty_list.remove(&shader->dirty_list);
		}

		while (shader->materials.first()) {
			Material *m = shader->materials.first()->self();

			m->shader = NULL;
			_material_make_dirty(m);

			shader->materials.remove(shader->materials.first());
		}

		shader_owner.free(p_rid);
		memdelete(shader);

		return true;
	} else if (material_owner.owns(p_rid)) {

		Material *m = material_owner.get(p_rid);

		if (m->shader) {
			m->shader->materials.remove(&m->list);
		}

		for (Map<Geometry *, int>::Element *E = m->geometry_owners.front(); E; E = E->next()) {
			Geometry *g = E->key();
			g->material = RID();
		}

		for (Map<RasterizerScene::InstanceBase *, int>::Element *E = m->instance_owners.front(); E; E = E->next()) {

			RasterizerScene::InstanceBase *ins = E->key();

			if (ins->material_override == p_rid) {
				ins->material_override = RID();
			}

			for (int i = 0; i < ins->materials.size(); i++) {
				if (ins->materials[i] == p_rid) {
					ins->materials.write[i] = RID();
				}
			}
		}

		material_owner.free(p_rid);
		memdelete(m);

		return true;
	} else if (skeleton_owner.owns(p_rid)) {

		Skeleton *s = skeleton_owner.get(p_rid);

		if (s->update_list.in_list()) {
			skeleton_update_list.remove(&s->update_list);
		}

		for (Set<RasterizerScene::InstanceBase *>::Element *E = s->instances.front(); E; E = E->next()) {
			E->get()->skeleton = RID();
		}

		skeleton_allocate(p_rid, 0, false);

		if (s->tex_id) {
			glDeleteTextures(1, &s->tex_id);
		}

		skeleton_owner.free(p_rid);
		memdelete(s);

		return true;
	} else if (mesh_owner.owns(p_rid)) {

		Mesh *mesh = mesh_owner.get(p_rid);

		mesh->instance_remove_deps();
		mesh_clear(p_rid);

		while (mesh->multimeshes.first()) {
			MultiMesh *multimesh = mesh->multimeshes.first()->self();
			multimesh->mesh = RID();
			multimesh->dirty_aabb = true;

			mesh->multimeshes.remove(mesh->multimeshes.first());

			if (!multimesh->update_list.in_list()) {
				multimesh_update_list.add(&multimesh->update_list);
			}
		}

		mesh_owner.free(p_rid);
		memdelete(mesh);

		return true;
	} else if (multimesh_owner.owns(p_rid)) {

		MultiMesh *multimesh = multimesh_owner.get(p_rid);
		multimesh->instance_remove_deps();

		if (multimesh->mesh.is_valid()) {
			Mesh *mesh = mesh_owner.getornull(multimesh->mesh);
			if (mesh) {
				mesh->multimeshes.remove(&multimesh->mesh_list);
			}
		}

		multimesh_allocate(p_rid, 0, VS::MULTIMESH_TRANSFORM_3D, VS::MULTIMESH_COLOR_NONE);

		update_dirty_multimeshes();

		multimesh_owner.free(p_rid);
		memdelete(multimesh);

		return true;
	} else if (immediate_owner.owns(p_rid)) {
		Immediate *im = immediate_owner.get(p_rid);
		im->instance_remove_deps();

		immediate_owner.free(p_rid);
		memdelete(im);

		return true;
	} else if (light_owner.owns(p_rid)) {

		Light *light = light_owner.get(p_rid);
		light->instance_remove_deps();

		light_owner.free(p_rid);
		memdelete(light);

		return true;
	} else {
		return false;
	}
}

bool RasterizerStorageGLES2::has_os_feature(const String &p_feature) const {

	if (p_feature == "s3tc")
		return config.s3tc_supported;

	if (p_feature == "etc")
		return config.etc1_supported;

	return false;
}

////////////////////////////////////////////

void RasterizerStorageGLES2::set_debug_generate_wireframes(bool p_generate) {
}

void RasterizerStorageGLES2::render_info_begin_capture() {
}

void RasterizerStorageGLES2::render_info_end_capture() {
}

int RasterizerStorageGLES2::get_captured_render_info(VS::RenderInfo p_info) {

	return get_render_info(p_info);
}

int RasterizerStorageGLES2::get_render_info(VS::RenderInfo p_info) {
	return 0;
}

void RasterizerStorageGLES2::initialize() {
	RasterizerStorageGLES2::system_fbo = 0;

	{

		const GLubyte *extension_string = glGetString(GL_EXTENSIONS);

		Vector<String> extensions = String((const char *)extension_string).split(" ");

		for (int i = 0; i < extensions.size(); i++) {
			config.extensions.insert(extensions[i]);
		}
	}

	config.shrink_textures_x2 = false;
	config.float_texture_supported = config.extensions.has("GL_ARB_texture_float") || config.extensions.has("GL_OES_texture_float");
	config.s3tc_supported = config.extensions.has("GL_EXT_texture_compression_s3tc");
	config.etc1_supported = config.extensions.has("GL_OES_compressed_ETC1_RGB8_texture");

	frame.count = 0;
	frame.delta = 0;
	frame.current_rt = NULL;
	frame.clear_request = false;

	glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &config.max_texture_image_units);
	glGetIntegerv(GL_MAX_TEXTURE_SIZE, &config.max_texture_size);

	shaders.copy.init();
	shaders.cubemap_filter.init();

	{
		// quad for copying stuff

		glGenBuffers(1, &resources.quadie);
		glBindBuffer(GL_ARRAY_BUFFER, resources.quadie);
		{
			const float qv[16] = {
				-1,
				-1,
				0,
				0,
				-1,
				1,
				0,
				1,
				1,
				1,
				1,
				1,
				1,
				-1,
				1,
				0,
			};

			glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 16, qv, GL_STATIC_DRAW);
		}

		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}

	{
		//default textures

		glGenTextures(1, &resources.white_tex);
		unsigned char whitetexdata[8 * 8 * 3];
		for (int i = 0; i < 8 * 8 * 3; i++) {
			whitetexdata[i] = 255;
		}

		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, resources.white_tex);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 8, 8, 0, GL_RGB, GL_UNSIGNED_BYTE, whitetexdata);
		glGenerateMipmap(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, 0);

		glGenTextures(1, &resources.black_tex);
		unsigned char blacktexdata[8 * 8 * 3];
		for (int i = 0; i < 8 * 8 * 3; i++) {
			blacktexdata[i] = 0;
		}

		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, resources.black_tex);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 8, 8, 0, GL_RGB, GL_UNSIGNED_BYTE, blacktexdata);
		glGenerateMipmap(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, 0);

		glGenTextures(1, &resources.normal_tex);
		unsigned char normaltexdata[8 * 8 * 3];
		for (int i = 0; i < 8 * 8 * 3; i += 3) {
			normaltexdata[i + 0] = 128;
			normaltexdata[i + 1] = 128;
			normaltexdata[i + 2] = 255;
		}

		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, resources.normal_tex);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 8, 8, 0, GL_RGB, GL_UNSIGNED_BYTE, normaltexdata);
		glGenerateMipmap(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, 0);

		glGenTextures(1, &resources.aniso_tex);
		unsigned char anisotexdata[8 * 8 * 3];
		for (int i = 0; i < 8 * 8 * 3; i += 3) {
			anisotexdata[i + 0] = 255;
			anisotexdata[i + 1] = 128;
			anisotexdata[i + 2] = 0;
		}

		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, resources.aniso_tex);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 8, 8, 0, GL_RGB, GL_UNSIGNED_BYTE, anisotexdata);
		glGenerateMipmap(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, 0);
	}

	// skeleton buffer
	{
		resources.skeleton_transform_buffer_size = 0;
		glGenBuffers(1, &resources.skeleton_transform_buffer);
	}

	// radical inverse vdc cache texture
	// used for cubemap filtering
	if (config.float_texture_supported) {
		glGenTextures(1, &resources.radical_inverse_vdc_cache_tex);

		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, resources.radical_inverse_vdc_cache_tex);

		float radical_inverse[512];

		for (uint32_t i = 0; i < 512; i++) {
			uint32_t bits = i;

			bits = (bits << 16) | (bits >> 16);
			bits = ((bits & 0x55555555) << 1) | ((bits & 0xAAAAAAAA) >> 1);
			bits = ((bits & 0x33333333) << 2) | ((bits & 0xCCCCCCCC) >> 2);
			bits = ((bits & 0x0F0F0F0F) << 4) | ((bits & 0xF0F0F0F0) >> 4);
			bits = ((bits & 0x00FF00FF) << 8) | ((bits & 0xFF00FF00) >> 8);

			float value = float(bits) * 2.3283064365386963e-10;

			radical_inverse[i] = value;
		}

		glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, 512, 1, 0, GL_LUMINANCE, GL_FLOAT, radical_inverse);

		glBindTexture(GL_TEXTURE_2D, 0);
	}

#ifdef GLES_OVER_GL
	//this needs to be enabled manually in OpenGL 2.1

	glEnable(_EXT_TEXTURE_CUBE_MAP_SEAMLESS);
	glEnable(GL_POINT_SPRITE);
	glEnable(GL_VERTEX_PROGRAM_POINT_SIZE);
#endif

	config.force_vertex_shading = GLOBAL_GET("rendering/quality/shading/force_vertex_shading");
}

void RasterizerStorageGLES2::finalize() {
}

void RasterizerStorageGLES2::_copy_screen() {
	bind_quad_array();
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}

void RasterizerStorageGLES2::update_dirty_resources() {
	update_dirty_shaders();
	update_dirty_materials();
	update_dirty_skeletons();
}

RasterizerStorageGLES2::RasterizerStorageGLES2() {
	RasterizerStorageGLES2::system_fbo = 0;
}
