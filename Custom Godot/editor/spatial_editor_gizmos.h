/*************************************************************************/
/*  spatial_editor_gizmos.h                                              */
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

#ifndef SPATIAL_EDITOR_GIZMOS_H
#define SPATIAL_EDITOR_GIZMOS_H

#include "editor/plugins/spatial_editor_plugin.h"
#include "scene/3d/audio_stream_player_3d.h"
#include "scene/3d/baked_lightmap.h"
#include "scene/3d/camera.h"
#include "scene/3d/collision_polygon.h"
#include "scene/3d/collision_shape.h"
#include "scene/3d/gi_probe.h"
#include "scene/3d/light.h"
#include "scene/3d/listener.h"
#include "scene/3d/mesh_instance.h"
#include "scene/3d/navigation_mesh.h"
#include "scene/3d/particles.h"
#include "scene/3d/physics_joint.h"
#include "scene/3d/portal.h"
#include "scene/3d/position_3d.h"
#include "scene/3d/ray_cast.h"
#include "scene/3d/reflection_probe.h"
#include "scene/3d/room_instance.h"
#include "scene/3d/vehicle_body.h"
#include "scene/3d/visibility_notifier.h"

class Camera;

class EditorSpatialGizmo : public SpatialEditorGizmo {

	GDCLASS(EditorSpatialGizmo, SpatialGizmo);

	struct Instance {

		RID instance;
		Ref<ArrayMesh> mesh;
		RID skeleton;
		bool billboard;
		bool unscaled;
		bool can_intersect;
		bool extra_margin;
		Instance() {

			billboard = false;
			unscaled = false;
			can_intersect = false;
			extra_margin = false;
		}

		void create_instance(Spatial *p_base);
	};

	Vector<Vector3> collision_segments;
	Ref<TriangleMesh> collision_mesh;
	AABB collision_mesh_bounds;

	struct Handle {
		Vector3 pos;
		bool billboard;
	};

	Vector<Vector3> handles;
	Vector<Vector3> secondary_handles;
	bool billboard_handle;

	bool valid;
	Spatial *base;
	Vector<Instance> instances;
	Spatial *spatial_node;

	void _set_spatial_node(Node *p_node) { set_spatial_node(Object::cast_to<Spatial>(p_node)); }

protected:
	void add_lines(const Vector<Vector3> &p_lines, const Ref<Material> &p_material, bool p_billboard = false);
	void add_mesh(const Ref<ArrayMesh> &p_mesh, bool p_billboard = false, const RID &p_skeleton = RID());
	void add_collision_segments(const Vector<Vector3> &p_lines);
	void add_collision_triangles(const Ref<TriangleMesh> &p_tmesh, const AABB &p_bounds = AABB());
	void add_unscaled_billboard(const Ref<Material> &p_material, float p_scale = 1);
	void add_handles(const Vector<Vector3> &p_handles, bool p_billboard = false, bool p_secondary = false);
	void add_solid_box(Ref<Material> &p_material, Vector3 p_size);

	void set_spatial_node(Spatial *p_node);
	const Spatial *get_spatial_node() const { return spatial_node; }

	static void _bind_methods();

	Ref<SpatialMaterial> create_material(const String &p_name, const Color &p_color, bool p_billboard = false, bool p_on_top = false, bool p_use_vertex_color = false);
	Ref<SpatialMaterial> create_icon_material(const String &p_name, const Ref<Texture> &p_texture, bool p_on_top = false, const Color &p_albedo = Color(1, 1, 1, 1));

public:
	virtual Vector3 get_handle_pos(int p_idx) const;
	virtual bool intersect_frustum(const Camera *p_camera, const Vector<Plane> &p_frustum);
	virtual bool intersect_ray(const Camera *p_camera, const Point2 &p_point, Vector3 &r_pos, Vector3 &r_normal, int *r_gizmo_handle = NULL, bool p_sec_first = false);

	void clear();
	void create();
	void transform();
	virtual void redraw();
	void free();
	virtual bool is_editable() const;
	virtual bool can_draw() const;

	EditorSpatialGizmo();
	~EditorSpatialGizmo();
};

class LightSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(LightSpatialGizmo, EditorSpatialGizmo);

	Light *light;

public:
	virtual String get_handle_name(int p_idx) const;
	virtual Variant get_handle_value(int p_idx) const;
	virtual void set_handle(int p_idx, Camera *p_camera, const Point2 &p_point);
	virtual void commit_handle(int p_idx, const Variant &p_restore, bool p_cancel = false);

	void redraw();
	LightSpatialGizmo(Light *p_light = NULL);
};

class AudioStreamPlayer3DSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(AudioStreamPlayer3DSpatialGizmo, EditorSpatialGizmo);

	AudioStreamPlayer3D *player;

public:
	virtual String get_handle_name(int p_idx) const;
	virtual Variant get_handle_value(int p_idx) const;
	virtual void set_handle(int p_idx, Camera *p_camera, const Point2 &p_point);
	virtual void commit_handle(int p_idx, const Variant &p_restore, bool p_cancel = false);

	void redraw();
	AudioStreamPlayer3DSpatialGizmo(AudioStreamPlayer3D *p_player = NULL);
};

class CameraSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(CameraSpatialGizmo, EditorSpatialGizmo);

	Camera *camera;

public:
	virtual String get_handle_name(int p_idx) const;
	virtual Variant get_handle_value(int p_idx) const;
	virtual void set_handle(int p_idx, Camera *p_camera, const Point2 &p_point);
	virtual void commit_handle(int p_idx, const Variant &p_restore, bool p_cancel = false);

	void redraw();
	CameraSpatialGizmo(Camera *p_camera = NULL);
};

class MeshInstanceSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(MeshInstanceSpatialGizmo, EditorSpatialGizmo);

	MeshInstance *mesh;

public:
	virtual bool can_draw() const;
	void redraw();
	MeshInstanceSpatialGizmo(MeshInstance *p_mesh = NULL);
};

class Position3DSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(Position3DSpatialGizmo, EditorSpatialGizmo);

	Position3D *p3d;

public:
	void redraw();
	Position3DSpatialGizmo(Position3D *p_p3d = NULL);
};

class SkeletonSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(SkeletonSpatialGizmo, EditorSpatialGizmo);

	Skeleton *skel;

public:
	void redraw();
	SkeletonSpatialGizmo(Skeleton *p_skel = NULL);
};

#if 0
class PortalSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(PortalSpatialGizmo, EditorSpatialGizmo);

	Portal *portal;

public:
	void redraw();
	PortalSpatialGizmo(Portal *p_portal = NULL);
};
#endif

class VisibilityNotifierGizmo : public EditorSpatialGizmo {

	GDCLASS(VisibilityNotifierGizmo, EditorSpatialGizmo);

	VisibilityNotifier *notifier;

public:
	virtual String get_handle_name(int p_idx) const;
	virtual Variant get_handle_value(int p_idx) const;
	virtual void set_handle(int p_idx, Camera *p_camera, const Point2 &p_point);
	virtual void commit_handle(int p_idx, const Variant &p_restore, bool p_cancel = false);

	void redraw();
	VisibilityNotifierGizmo(VisibilityNotifier *p_notifier = NULL);
};

class ParticlesGizmo : public EditorSpatialGizmo {

	GDCLASS(ParticlesGizmo, EditorSpatialGizmo);

	Particles *particles;

public:
	virtual String get_handle_name(int p_idx) const;
	virtual Variant get_handle_value(int p_idx) const;
	virtual void set_handle(int p_idx, Camera *p_camera, const Point2 &p_point);
	virtual void commit_handle(int p_idx, const Variant &p_restore, bool p_cancel = false);

	void redraw();
	ParticlesGizmo(Particles *p_particles = NULL);
};

class ReflectionProbeGizmo : public EditorSpatialGizmo {

	GDCLASS(ReflectionProbeGizmo, EditorSpatialGizmo);

	ReflectionProbe *probe;

public:
	virtual String get_handle_name(int p_idx) const;
	virtual Variant get_handle_value(int p_idx) const;
	virtual void set_handle(int p_idx, Camera *p_camera, const Point2 &p_point);
	virtual void commit_handle(int p_idx, const Variant &p_restore, bool p_cancel = false);

	void redraw();
	ReflectionProbeGizmo(ReflectionProbe *p_probe = NULL);
};

class GIProbeGizmo : public EditorSpatialGizmo {

	GDCLASS(GIProbeGizmo, EditorSpatialGizmo);

	GIProbe *probe;

public:
	virtual String get_handle_name(int p_idx) const;
	virtual Variant get_handle_value(int p_idx) const;
	virtual void set_handle(int p_idx, Camera *p_camera, const Point2 &p_point);
	virtual void commit_handle(int p_idx, const Variant &p_restore, bool p_cancel = false);

	void redraw();
	GIProbeGizmo(GIProbe *p_probe = NULL);
};

class BakedIndirectLightGizmo : public EditorSpatialGizmo {

	GDCLASS(BakedIndirectLightGizmo, EditorSpatialGizmo);

	BakedLightmap *baker;

public:
	virtual String get_handle_name(int p_idx) const;
	virtual Variant get_handle_value(int p_idx) const;
	virtual void set_handle(int p_idx, Camera *p_camera, const Point2 &p_point);
	virtual void commit_handle(int p_idx, const Variant &p_restore, bool p_cancel = false);

	void redraw();
	BakedIndirectLightGizmo(BakedLightmap *p_baker = NULL);
};

class CollisionShapeSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(CollisionShapeSpatialGizmo, EditorSpatialGizmo);

	CollisionShape *cs;

public:
	virtual String get_handle_name(int p_idx) const;
	virtual Variant get_handle_value(int p_idx) const;
	virtual void set_handle(int p_idx, Camera *p_camera, const Point2 &p_point);
	virtual void commit_handle(int p_idx, const Variant &p_restore, bool p_cancel = false);
	void redraw();
	CollisionShapeSpatialGizmo(CollisionShape *p_cs = NULL);
};

class CollisionPolygonSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(CollisionPolygonSpatialGizmo, EditorSpatialGizmo);

	CollisionPolygon *polygon;

public:
	void redraw();
	CollisionPolygonSpatialGizmo(CollisionPolygon *p_polygon = NULL);
};

class RayCastSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(RayCastSpatialGizmo, EditorSpatialGizmo);

	RayCast *raycast;

public:
	void redraw();
	RayCastSpatialGizmo(RayCast *p_raycast = NULL);
};

class VehicleWheelSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(VehicleWheelSpatialGizmo, EditorSpatialGizmo);

	VehicleWheel *car_wheel;

public:
	void redraw();
	VehicleWheelSpatialGizmo(VehicleWheel *p_car_wheel = NULL);
};

class NavigationMeshSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(NavigationMeshSpatialGizmo, EditorSpatialGizmo);

	struct _EdgeKey {

		Vector3 from;
		Vector3 to;

		bool operator<(const _EdgeKey &p_with) const { return from == p_with.from ? to < p_with.to : from < p_with.from; }
	};

	NavigationMeshInstance *navmesh;

public:
	void redraw();
	NavigationMeshSpatialGizmo(NavigationMeshInstance *p_navmesh = NULL);
};

class JointGizmosDrawer {
public:
	static Basis look_body(const Transform &p_joint_transform, const Transform &p_body_transform);
	static Basis look_body_toward(Vector3::Axis p_axis, const Transform &joint_transform, const Transform &body_transform);
	static Basis look_body_toward_x(const Transform &p_joint_transform, const Transform &p_body_transform);
	static Basis look_body_toward_y(const Transform &p_joint_transform, const Transform &p_body_transform);
	/// Special function just used for physics joints, it that returns a basis constrained toward Joint Z axis
	/// with axis X and Y that are looking toward the body and oriented toward up
	static Basis look_body_toward_z(const Transform &p_joint_transform, const Transform &p_body_transform);

	// Draw circle around p_axis
	static void draw_circle(Vector3::Axis p_axis, real_t p_radius, const Transform &p_offset, const Basis &p_base, real_t p_limit_lower, real_t p_limit_upper, Vector<Vector3> &r_points, bool p_inverse = false);
	static void draw_cone(const Transform &p_offset, const Basis &p_base, real_t p_swing, real_t p_twist, Vector<Vector3> &r_points);
};

class PinJointSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(PinJointSpatialGizmo, EditorSpatialGizmo);

	PinJoint *p3d;

public:
	static void CreateGizmo(const Transform &p_offset, Vector<Vector3> &r_cursor_points);

	void redraw();
	PinJointSpatialGizmo(PinJoint *p_p3d = NULL);
};

class HingeJointSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(HingeJointSpatialGizmo, EditorSpatialGizmo);

	HingeJoint *p3d;

public:
	static void CreateGizmo(const Transform &p_offset, const Transform &p_trs_joint, const Transform &p_trs_body_a, const Transform &p_trs_body_b, real_t p_limit_lower, real_t p_limit_upper, bool p_use_limit, Vector<Vector3> &r_common_points, Vector<Vector3> *r_body_a_points, Vector<Vector3> *r_body_b_points);

	void redraw();
	HingeJointSpatialGizmo(HingeJoint *p_p3d = NULL);
};

class SliderJointSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(SliderJointSpatialGizmo, EditorSpatialGizmo);

	SliderJoint *p3d;

public:
	static void CreateGizmo(const Transform &p_offset, const Transform &p_trs_joint, const Transform &p_trs_body_a, const Transform &p_trs_body_b, real_t p_angular_limit_lower, real_t p_angular_limit_upper, real_t p_linear_limit_lower, real_t p_linear_limit_upper, Vector<Vector3> &r_points, Vector<Vector3> *r_body_a_points, Vector<Vector3> *r_body_b_points);

	void redraw();
	SliderJointSpatialGizmo(SliderJoint *p_p3d = NULL);
};

class ConeTwistJointSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(ConeTwistJointSpatialGizmo, EditorSpatialGizmo);

	ConeTwistJoint *p3d;

public:
	static void CreateGizmo(const Transform &p_offset, const Transform &p_trs_joint, const Transform &p_trs_body_a, const Transform &p_trs_body_b, real_t p_swing, real_t p_twist, Vector<Vector3> &r_points, Vector<Vector3> *r_body_a_points, Vector<Vector3> *r_body_b_points);

	void redraw();
	ConeTwistJointSpatialGizmo(ConeTwistJoint *p_p3d = NULL);
};

class Generic6DOFJointSpatialGizmo : public EditorSpatialGizmo {

	GDCLASS(Generic6DOFJointSpatialGizmo, EditorSpatialGizmo);

	Generic6DOFJoint *p3d;

public:
	static void CreateGizmo(
			const Transform &p_offset,
			const Transform &p_trs_joint,
			const Transform &p_trs_body_a,
			const Transform &p_trs_body_b,
			real_t p_angular_limit_lower_x,
			real_t p_angular_limit_upper_x,
			real_t p_linear_limit_lower_x,
			real_t p_linear_limit_upper_x,
			bool p_enable_angular_limit_x,
			bool p_enable_linear_limit_x,
			real_t p_angular_limit_lower_y,
			real_t p_angular_limit_upper_y,
			real_t p_linear_limit_lower_y,
			real_t p_linear_limit_upper_y,
			bool p_enable_angular_limit_y,
			bool p_enable_linear_limit_y,
			real_t p_angular_limit_lower_z,
			real_t p_angular_limit_upper_z,
			real_t p_linear_limit_lower_z,
			real_t p_linear_limit_upper_z,
			bool p_enable_angular_limit_z,
			bool p_enable_linear_limit_z,
			Vector<Vector3> &r_points,
			Vector<Vector3> *r_body_a_points,
			Vector<Vector3> *r_body_b_points);

	void redraw();
	Generic6DOFJointSpatialGizmo(Generic6DOFJoint *p_p3d = NULL);
};

class SpatialEditorGizmos {

public:
	HashMap<String, Ref<SpatialMaterial> > material_cache;

	Ref<SpatialMaterial> handle2_material;
	Ref<SpatialMaterial> handle2_material_billboard;
	Ref<SpatialMaterial> handle_material;
	Ref<SpatialMaterial> handle_material_billboard;
	Ref<Texture> handle_t;
	Ref<ArrayMesh> pos3d_mesh;
	Ref<ArrayMesh> listener_line_mesh;
	static SpatialEditorGizmos *singleton;

	Ref<SpatialEditorGizmo> get_gizmo(Spatial *p_spatial);

	SpatialEditorGizmos();
};
#endif // SPATIAL_EDITOR_GIZMOS_H
