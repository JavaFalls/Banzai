/*************************************************************************/
/*  camera.cpp                                                           */
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

#include "camera.h"

#include "camera_matrix.h"
#include "scene/resources/material.h"
#include "scene/resources/surface_tool.h"

void Camera::_update_audio_listener_state() {
}

void Camera::_request_camera_update() {

	_update_camera();
}

void Camera::_update_camera_mode() {

	force_change = true;
	switch (mode) {
		case PROJECTION_PERSPECTIVE: {

			set_perspective(fov, near, far);

		} break;
		case PROJECTION_ORTHOGONAL: {
			set_orthogonal(size, near, far);
		} break;
	}
}

void Camera::_validate_property(PropertyInfo &p_property) const {
	if (p_property.name == "fov") {
		if (mode == PROJECTION_ORTHOGONAL) {
			p_property.usage = PROPERTY_USAGE_NOEDITOR;
		}
	} else if (p_property.name == "size") {
		if (mode == PROJECTION_PERSPECTIVE) {
			p_property.usage = PROPERTY_USAGE_NOEDITOR;
		}
	}
}

void Camera::_update_camera() {

	if (!is_inside_tree())
		return;

	Transform tr = get_camera_transform();
	tr.origin += tr.basis.get_axis(1) * v_offset;
	tr.origin += tr.basis.get_axis(0) * h_offset;
	VisualServer::get_singleton()->camera_set_transform(camera, tr);

	// here goes listener stuff
	/*
	if (viewport_ptr && is_inside_scene() && is_current())
		get_viewport()->_camera_transform_changed_notify();
	*/

	if (get_tree()->is_node_being_edited(this) || !is_current())
		return;

	get_viewport()->_camera_transform_changed_notify();

	if (get_world().is_valid()) {
		get_world()->_update_camera(this);
	}
}

void Camera::_notification(int p_what) {

	switch (p_what) {

		case NOTIFICATION_ENTER_WORLD: {

			bool first_camera = get_viewport()->_camera_add(this);
			if (!get_tree()->is_node_being_edited(this) && (current || first_camera))
				make_current();

		} break;
		case NOTIFICATION_TRANSFORM_CHANGED: {

			_request_camera_update();
			if (doppler_tracking != DOPPLER_TRACKING_DISABLED) {
				velocity_tracker->update_position(get_global_transform().origin);
			}
		} break;
		case NOTIFICATION_EXIT_WORLD: {

			if (!get_tree()->is_node_being_edited(this)) {
				if (is_current()) {
					clear_current();
					current = true; //keep it true

				} else {
					current = false;
				}
			}

			get_viewport()->_camera_remove(this);

		} break;
		case NOTIFICATION_BECAME_CURRENT: {
			if (get_world().is_valid()) {
				get_world()->_register_camera(this);
			}
		} break;
		case NOTIFICATION_LOST_CURRENT: {
			if (get_world().is_valid()) {
				get_world()->_remove_camera(this);
			}
		} break;
	}
}

Transform Camera::get_camera_transform() const {

	return get_global_transform().orthonormalized();
}

void Camera::set_perspective(float p_fovy_degrees, float p_z_near, float p_z_far) {

	if (!force_change && fov == p_fovy_degrees && p_z_near == near && p_z_far == far && mode == PROJECTION_PERSPECTIVE)
		return;

	fov = p_fovy_degrees;
	near = p_z_near;
	far = p_z_far;
	mode = PROJECTION_PERSPECTIVE;

	VisualServer::get_singleton()->camera_set_perspective(camera, fov, near, far);
	update_gizmo();
	force_change = false;
}
void Camera::set_orthogonal(float p_size, float p_z_near, float p_z_far) {

	if (!force_change && size == p_size && p_z_near == near && p_z_far == far && mode == PROJECTION_ORTHOGONAL)
		return;

	size = p_size;

	near = p_z_near;
	far = p_z_far;
	mode = PROJECTION_ORTHOGONAL;
	force_change = false;

	VisualServer::get_singleton()->camera_set_orthogonal(camera, size, near, far);
	update_gizmo();
}

void Camera::set_projection(Camera::Projection p_mode) {
	if (p_mode == PROJECTION_PERSPECTIVE || p_mode == PROJECTION_ORTHOGONAL) {
		mode = p_mode;
		_update_camera_mode();
		_change_notify();
	}
}

RID Camera::get_camera() const {

	return camera;
};

void Camera::make_current() {

	current = true;

	if (!is_inside_tree())
		return;

	get_viewport()->_camera_set(this);

	//get_scene()->call_group(SceneMainLoop::GROUP_CALL_REALTIME,camera_group,"_camera_make_current",this);
}

void Camera::clear_current() {

	current = false;
	if (!is_inside_tree())
		return;

	if (get_viewport()->get_camera() == this) {
		get_viewport()->_camera_set(NULL);
		get_viewport()->_camera_make_next_current(this);
	}
}

void Camera::set_current(bool p_current) {
	if (p_current) {
		make_current();
	} else {
		clear_current();
	}
}

bool Camera::is_current() const {

	if (is_inside_tree() && !get_tree()->is_node_being_edited(this)) {

		return get_viewport()->get_camera() == this;
	} else
		return current;

	return false;
}

bool Camera::_can_gizmo_scale() const {

	return false;
}

Vector3 Camera::project_ray_normal(const Point2 &p_pos) const {

	Vector3 ray = project_local_ray_normal(p_pos);
	return get_camera_transform().basis.xform(ray).normalized();
};

Vector3 Camera::project_local_ray_normal(const Point2 &p_pos) const {

	if (!is_inside_tree()) {
		ERR_EXPLAIN("Camera is not inside scene.");
		ERR_FAIL_COND_V(!is_inside_tree(), Vector3());
	}

	Size2 viewport_size = get_viewport()->get_camera_rect_size();
	Vector2 cpos = get_viewport()->get_camera_coords(p_pos);
	Vector3 ray;

	if (mode == PROJECTION_ORTHOGONAL) {

		ray = Vector3(0, 0, -1);
	} else {
		CameraMatrix cm;
		cm.set_perspective(fov, viewport_size.aspect(), near, far, keep_aspect == KEEP_WIDTH);
		float screen_w, screen_h;
		cm.get_viewport_size(screen_w, screen_h);
		ray = Vector3(((cpos.x / viewport_size.width) * 2.0 - 1.0) * screen_w, ((1.0 - (cpos.y / viewport_size.height)) * 2.0 - 1.0) * screen_h, -near).normalized();
	}

	return ray;
};

Vector3 Camera::project_ray_origin(const Point2 &p_pos) const {

	if (!is_inside_tree()) {
		ERR_EXPLAIN("Camera is not inside scene.");
		ERR_FAIL_COND_V(!is_inside_tree(), Vector3());
	}

	Size2 viewport_size = get_viewport()->get_camera_rect_size();
	Vector2 cpos = get_viewport()->get_camera_coords(p_pos);
	ERR_FAIL_COND_V(viewport_size.y == 0, Vector3());

	if (mode == PROJECTION_PERSPECTIVE) {

		return get_camera_transform().origin;
	} else {

		Vector2 pos = cpos / viewport_size;
		float vsize, hsize;
		if (keep_aspect == KEEP_WIDTH) {
			vsize = size / viewport_size.aspect();
			hsize = size;
		} else {
			hsize = size * viewport_size.aspect();
			vsize = size;
		}

		Vector3 ray;
		ray.x = pos.x * (hsize)-hsize / 2;
		ray.y = (1.0 - pos.y) * (vsize)-vsize / 2;
		ray.z = -near;
		ray = get_camera_transform().xform(ray);
		return ray;
	};
};

bool Camera::is_position_behind(const Vector3 &p_pos) const {

	Transform t = get_global_transform();
	Vector3 eyedir = -get_global_transform().basis.get_axis(2).normalized();
	return eyedir.dot(p_pos) < (eyedir.dot(t.origin) + near);
}

Point2 Camera::unproject_position(const Vector3 &p_pos) const {

	if (!is_inside_tree()) {
		ERR_EXPLAIN("Camera is not inside scene.");
		ERR_FAIL_COND_V(!is_inside_tree(), Vector2());
	}

	Size2 viewport_size = get_viewport()->get_visible_rect().size;

	CameraMatrix cm;

	if (mode == PROJECTION_ORTHOGONAL)
		cm.set_orthogonal(size, viewport_size.aspect(), near, far, keep_aspect == KEEP_WIDTH);
	else
		cm.set_perspective(fov, viewport_size.aspect(), near, far, keep_aspect == KEEP_WIDTH);

	Plane p(get_camera_transform().xform_inv(p_pos), 1.0);

	p = cm.xform4(p);
	p.normal /= p.d;

	Point2 res;
	res.x = (p.normal.x * 0.5 + 0.5) * viewport_size.x;
	res.y = (-p.normal.y * 0.5 + 0.5) * viewport_size.y;

	return res;
}

Vector3 Camera::project_position(const Point2 &p_point) const {

	if (!is_inside_tree()) {
		ERR_EXPLAIN("Camera is not inside scene.");
		ERR_FAIL_COND_V(!is_inside_tree(), Vector3());
	}

	Size2 viewport_size = get_viewport()->get_visible_rect().size;

	CameraMatrix cm;

	if (mode == PROJECTION_ORTHOGONAL)
		cm.set_orthogonal(size, viewport_size.aspect(), near, far, keep_aspect == KEEP_WIDTH);
	else
		cm.set_perspective(fov, viewport_size.aspect(), near, far, keep_aspect == KEEP_WIDTH);

	Size2 vp_size;
	cm.get_viewport_size(vp_size.x, vp_size.y);

	Vector2 point;
	point.x = (p_point.x / viewport_size.x) * 2.0 - 1.0;
	point.y = (1.0 - (p_point.y / viewport_size.y)) * 2.0 - 1.0;
	point *= vp_size;

	Vector3 p(point.x, point.y, -near);

	return get_camera_transform().xform(p);
}

/*
void Camera::_camera_make_current(Node *p_camera) {


	if (p_camera==this) {
		VisualServer::get_singleton()->viewport_attach_camera(viewport_id,camera);
		active=true;
	} else {
		if (active && p_camera==NULL) {
			//detech camera because no one else will claim it
			VisualServer::get_singleton()->viewport_attach_camera(viewport_id,RID());
		}
		active=false;
	}
}
*/

void Camera::set_environment(const Ref<Environment> &p_environment) {

	environment = p_environment;
	if (environment.is_valid())
		VS::get_singleton()->camera_set_environment(camera, environment->get_rid());
	else
		VS::get_singleton()->camera_set_environment(camera, RID());
	_update_camera_mode();
}

Ref<Environment> Camera::get_environment() const {

	return environment;
}

void Camera::set_keep_aspect_mode(KeepAspect p_aspect) {
	keep_aspect = p_aspect;
	VisualServer::get_singleton()->camera_set_use_vertical_aspect(camera, p_aspect == KEEP_WIDTH);
	_update_camera_mode();
	_change_notify();
}

Camera::KeepAspect Camera::get_keep_aspect_mode() const {

	return keep_aspect;
}

void Camera::set_doppler_tracking(DopplerTracking p_tracking) {

	if (doppler_tracking == p_tracking)
		return;

	doppler_tracking = p_tracking;
	if (p_tracking != DOPPLER_TRACKING_DISABLED) {
		velocity_tracker->set_track_physics_step(doppler_tracking == DOPPLER_TRACKING_PHYSICS_STEP);
		velocity_tracker->reset(get_global_transform().origin);
	}
	_update_camera_mode();
}

Camera::DopplerTracking Camera::get_doppler_tracking() const {
	return doppler_tracking;
}

void Camera::_bind_methods() {

	ClassDB::bind_method(D_METHOD("project_ray_normal", "screen_point"), &Camera::project_ray_normal);
	ClassDB::bind_method(D_METHOD("project_local_ray_normal", "screen_point"), &Camera::project_local_ray_normal);
	ClassDB::bind_method(D_METHOD("project_ray_origin", "screen_point"), &Camera::project_ray_origin);
	ClassDB::bind_method(D_METHOD("unproject_position", "world_point"), &Camera::unproject_position);
	ClassDB::bind_method(D_METHOD("is_position_behind", "world_point"), &Camera::is_position_behind);
	ClassDB::bind_method(D_METHOD("project_position", "screen_point"), &Camera::project_position);
	ClassDB::bind_method(D_METHOD("set_perspective", "fov", "z_near", "z_far"), &Camera::set_perspective);
	ClassDB::bind_method(D_METHOD("set_orthogonal", "size", "z_near", "z_far"), &Camera::set_orthogonal);
	ClassDB::bind_method(D_METHOD("make_current"), &Camera::make_current);
	ClassDB::bind_method(D_METHOD("clear_current"), &Camera::clear_current);
	ClassDB::bind_method(D_METHOD("set_current"), &Camera::set_current);
	ClassDB::bind_method(D_METHOD("is_current"), &Camera::is_current);
	ClassDB::bind_method(D_METHOD("get_camera_transform"), &Camera::get_camera_transform);
	ClassDB::bind_method(D_METHOD("get_fov"), &Camera::get_fov);
	ClassDB::bind_method(D_METHOD("get_size"), &Camera::get_size);
	ClassDB::bind_method(D_METHOD("get_zfar"), &Camera::get_zfar);
	ClassDB::bind_method(D_METHOD("get_znear"), &Camera::get_znear);
	ClassDB::bind_method(D_METHOD("set_fov"), &Camera::set_fov);
	ClassDB::bind_method(D_METHOD("set_size"), &Camera::set_size);
	ClassDB::bind_method(D_METHOD("set_zfar"), &Camera::set_zfar);
	ClassDB::bind_method(D_METHOD("set_znear"), &Camera::set_znear);
	ClassDB::bind_method(D_METHOD("get_projection"), &Camera::get_projection);
	ClassDB::bind_method(D_METHOD("set_projection"), &Camera::set_projection);
	ClassDB::bind_method(D_METHOD("set_h_offset", "ofs"), &Camera::set_h_offset);
	ClassDB::bind_method(D_METHOD("get_h_offset"), &Camera::get_h_offset);
	ClassDB::bind_method(D_METHOD("set_v_offset", "ofs"), &Camera::set_v_offset);
	ClassDB::bind_method(D_METHOD("get_v_offset"), &Camera::get_v_offset);
	ClassDB::bind_method(D_METHOD("set_cull_mask", "mask"), &Camera::set_cull_mask);
	ClassDB::bind_method(D_METHOD("get_cull_mask"), &Camera::get_cull_mask);
	ClassDB::bind_method(D_METHOD("set_environment", "env"), &Camera::set_environment);
	ClassDB::bind_method(D_METHOD("get_environment"), &Camera::get_environment);
	ClassDB::bind_method(D_METHOD("set_keep_aspect_mode", "mode"), &Camera::set_keep_aspect_mode);
	ClassDB::bind_method(D_METHOD("get_keep_aspect_mode"), &Camera::get_keep_aspect_mode);
	ClassDB::bind_method(D_METHOD("set_doppler_tracking", "mode"), &Camera::set_doppler_tracking);
	ClassDB::bind_method(D_METHOD("get_doppler_tracking"), &Camera::get_doppler_tracking);
	//ClassDB::bind_method(D_METHOD("_camera_make_current"),&Camera::_camera_make_current );

	ADD_PROPERTY(PropertyInfo(Variant::INT, "keep_aspect", PROPERTY_HINT_ENUM, "Keep Width,Keep Height"), "set_keep_aspect_mode", "get_keep_aspect_mode");
	ADD_PROPERTY(PropertyInfo(Variant::INT, "cull_mask", PROPERTY_HINT_LAYERS_3D_RENDER), "set_cull_mask", "get_cull_mask");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "environment", PROPERTY_HINT_RESOURCE_TYPE, "Environment"), "set_environment", "get_environment");
	ADD_PROPERTY(PropertyInfo(Variant::REAL, "h_offset"), "set_h_offset", "get_h_offset");
	ADD_PROPERTY(PropertyInfo(Variant::REAL, "v_offset"), "set_v_offset", "get_v_offset");
	ADD_PROPERTY(PropertyInfo(Variant::INT, "doppler_tracking", PROPERTY_HINT_ENUM, "Disabled,Idle,Physics"), "set_doppler_tracking", "get_doppler_tracking");
	ADD_PROPERTY(PropertyInfo(Variant::INT, "projection", PROPERTY_HINT_ENUM, "Perspective,Orthogonal"), "set_projection", "get_projection");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "current"), "set_current", "is_current");
	ADD_PROPERTY(PropertyInfo(Variant::REAL, "fov", PROPERTY_HINT_RANGE, "1,179,0.1"), "set_fov", "get_fov");
	ADD_PROPERTY(PropertyInfo(Variant::REAL, "size", PROPERTY_HINT_RANGE, "0.1,16384,0.01"), "set_size", "get_size");
	ADD_PROPERTY(PropertyInfo(Variant::REAL, "near"), "set_znear", "get_znear");
	ADD_PROPERTY(PropertyInfo(Variant::REAL, "far"), "set_zfar", "get_zfar");

	BIND_ENUM_CONSTANT(PROJECTION_PERSPECTIVE);
	BIND_ENUM_CONSTANT(PROJECTION_ORTHOGONAL);

	BIND_ENUM_CONSTANT(KEEP_WIDTH);
	BIND_ENUM_CONSTANT(KEEP_HEIGHT);

	BIND_ENUM_CONSTANT(DOPPLER_TRACKING_DISABLED)
	BIND_ENUM_CONSTANT(DOPPLER_TRACKING_IDLE_STEP)
	BIND_ENUM_CONSTANT(DOPPLER_TRACKING_PHYSICS_STEP)
}

float Camera::get_fov() const {

	return fov;
}

float Camera::get_size() const {

	return size;
}

float Camera::get_znear() const {

	return near;
}

float Camera::get_zfar() const {

	return far;
}

Camera::Projection Camera::get_projection() const {

	return mode;
}

void Camera::set_fov(float p_fov) {
	fov = p_fov;
	_update_camera_mode();
}

void Camera::set_size(float p_size) {
	size = p_size;
	_update_camera_mode();
}

void Camera::set_znear(float p_znear) {
	near = p_znear;
	_update_camera_mode();
}

void Camera::set_zfar(float p_zfar) {
	far = p_zfar;
	_update_camera_mode();
}

void Camera::set_cull_mask(uint32_t p_layers) {
	layers = p_layers;
	VisualServer::get_singleton()->camera_set_cull_mask(camera, layers);
	_update_camera_mode();
}

uint32_t Camera::get_cull_mask() const {

	return layers;
}

Vector<Plane> Camera::get_frustum() const {

	ERR_FAIL_COND_V(!is_inside_world(), Vector<Plane>());

	Size2 viewport_size = get_viewport()->get_visible_rect().size;
	CameraMatrix cm;
	if (mode == PROJECTION_PERSPECTIVE)
		cm.set_perspective(fov, viewport_size.aspect(), near, far, keep_aspect == KEEP_WIDTH);
	else
		cm.set_orthogonal(size, viewport_size.aspect(), near, far, keep_aspect == KEEP_WIDTH);

	return cm.get_projection_planes(get_camera_transform());
}

void Camera::set_v_offset(float p_offset) {

	v_offset = p_offset;
	_update_camera();
}

float Camera::get_v_offset() const {

	return v_offset;
}

void Camera::set_h_offset(float p_offset) {
	h_offset = p_offset;
	_update_camera();
}

float Camera::get_h_offset() const {

	return h_offset;
}

Vector3 Camera::get_doppler_tracked_velocity() const {

	if (doppler_tracking != DOPPLER_TRACKING_DISABLED) {
		return velocity_tracker->get_tracked_linear_velocity();
	} else {
		return Vector3();
	}
}
Camera::Camera() {

	camera = VisualServer::get_singleton()->camera_create();
	size = 1;
	fov = 0;
	near = 0;
	far = 0;
	current = false;
	force_change = false;
	mode = PROJECTION_PERSPECTIVE;
	set_perspective(70.0, 0.05, 100.0);
	keep_aspect = KEEP_HEIGHT;
	layers = 0xfffff;
	v_offset = 0;
	h_offset = 0;
	VisualServer::get_singleton()->camera_set_cull_mask(camera, layers);
	//active=false;
	velocity_tracker.instance();
	doppler_tracking = DOPPLER_TRACKING_DISABLED;
	set_notify_transform(true);
}

Camera::~Camera() {

	VisualServer::get_singleton()->free(camera);
}
