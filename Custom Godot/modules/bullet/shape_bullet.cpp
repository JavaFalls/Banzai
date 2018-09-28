/*************************************************************************/
/*  shape_bullet.cpp                                                     */
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

#include "shape_bullet.h"

#include "btRayShape.h"
#include "bullet_physics_server.h"
#include "bullet_types_converter.h"
#include "bullet_utilities.h"
#include "shape_owner_bullet.h"

#include <BulletCollision/CollisionDispatch/btInternalEdgeUtility.h>
#include <BulletCollision/CollisionShapes/btConvexPointCloudShape.h>
#include <BulletCollision/CollisionShapes/btHeightfieldTerrainShape.h>
#include <btBulletCollisionCommon.h>

/**
	@author AndreaCatania
*/

ShapeBullet::ShapeBullet() :
		margin(0.04) {}

ShapeBullet::~ShapeBullet() {}

btCollisionShape *ShapeBullet::create_bt_shape(const Vector3 &p_implicit_scale, real_t p_extra_edge) {
	btVector3 s;
	G_TO_B(p_implicit_scale, s);
	return create_bt_shape(s, p_extra_edge);
}

btCollisionShape *ShapeBullet::prepare(btCollisionShape *p_btShape) const {
	p_btShape->setUserPointer(const_cast<ShapeBullet *>(this));
	p_btShape->setMargin(margin);
	return p_btShape;
}

void ShapeBullet::notifyShapeChanged() {
	for (Map<ShapeOwnerBullet *, int>::Element *E = owners.front(); E; E = E->next()) {
		static_cast<ShapeOwnerBullet *>(E->key())->on_shape_changed(this);
	}
}

void ShapeBullet::add_owner(ShapeOwnerBullet *p_owner) {
	Map<ShapeOwnerBullet *, int>::Element *E = owners.find(p_owner);
	if (E) {
		E->get()++;
	} else {
		owners[p_owner] = 1; // add new owner
	}
}

void ShapeBullet::remove_owner(ShapeOwnerBullet *p_owner, bool p_permanentlyFromThisBody) {
	Map<ShapeOwnerBullet *, int>::Element *E = owners.find(p_owner);
	if (!E) return;
	E->get()--;
	if (p_permanentlyFromThisBody || 0 >= E->get()) {
		owners.erase(E);
	}
}

bool ShapeBullet::is_owner(ShapeOwnerBullet *p_owner) const {

	return owners.has(p_owner);
}

const Map<ShapeOwnerBullet *, int> &ShapeBullet::get_owners() const {
	return owners;
}

void ShapeBullet::set_margin(real_t p_margin) {
	margin = p_margin;
	notifyShapeChanged();
}

real_t ShapeBullet::get_margin() const {
	return margin;
}

btEmptyShape *ShapeBullet::create_shape_empty() {
	return bulletnew(btEmptyShape);
}

btStaticPlaneShape *ShapeBullet::create_shape_plane(const btVector3 &planeNormal, btScalar planeConstant) {
	return bulletnew(btStaticPlaneShape(planeNormal, planeConstant));
}

btSphereShape *ShapeBullet::create_shape_sphere(btScalar radius) {
	return bulletnew(btSphereShape(radius));
}

btBoxShape *ShapeBullet::create_shape_box(const btVector3 &boxHalfExtents) {
	return bulletnew(btBoxShape(boxHalfExtents));
}

btCapsuleShapeZ *ShapeBullet::create_shape_capsule(btScalar radius, btScalar height) {
	return bulletnew(btCapsuleShapeZ(radius, height));
}

btCylinderShape *ShapeBullet::create_shape_cylinder(btScalar radius, btScalar height) {
	return bulletnew(btCylinderShape(btVector3(radius, height / 2.0, radius)));
}

btConvexPointCloudShape *ShapeBullet::create_shape_convex(btAlignedObjectArray<btVector3> &p_vertices, const btVector3 &p_local_scaling) {
	return bulletnew(btConvexPointCloudShape(&p_vertices[0], p_vertices.size(), p_local_scaling));
}

btScaledBvhTriangleMeshShape *ShapeBullet::create_shape_concave(btBvhTriangleMeshShape *p_mesh_shape, const btVector3 &p_local_scaling) {
	if (p_mesh_shape) {
		return bulletnew(btScaledBvhTriangleMeshShape(p_mesh_shape, p_local_scaling));
	} else {
		return NULL;
	}
}

btHeightfieldTerrainShape *ShapeBullet::create_shape_height_field(PoolVector<real_t> &p_heights, int p_width, int p_depth, real_t p_min_height, real_t p_max_height) {
	const btScalar ignoredHeightScale(1);
	const int YAxis = 1; // 0=X, 1=Y, 2=Z
	const bool flipQuadEdges = false;
	const void *heightsPtr = p_heights.read().ptr();

	return bulletnew(btHeightfieldTerrainShape(p_width, p_depth, heightsPtr, ignoredHeightScale, p_min_height, p_max_height, YAxis, PHY_FLOAT, flipQuadEdges));
}

btRayShape *ShapeBullet::create_shape_ray(real_t p_length, bool p_slips_on_slope) {
	btRayShape *r(bulletnew(btRayShape(p_length)));
	r->setSlipsOnSlope(p_slips_on_slope);
	return r;
}

/* PLANE */

PlaneShapeBullet::PlaneShapeBullet() :
		ShapeBullet() {}

void PlaneShapeBullet::set_data(const Variant &p_data) {
	setup(p_data);
}

Variant PlaneShapeBullet::get_data() const {
	return plane;
}

PhysicsServer::ShapeType PlaneShapeBullet::get_type() const {
	return PhysicsServer::SHAPE_PLANE;
}

void PlaneShapeBullet::setup(const Plane &p_plane) {
	plane = p_plane;
	notifyShapeChanged();
}

btCollisionShape *PlaneShapeBullet::create_bt_shape(const btVector3 &p_implicit_scale, real_t p_extra_edge) {
	btVector3 btPlaneNormal;
	G_TO_B(plane.normal, btPlaneNormal);
	return prepare(PlaneShapeBullet::create_shape_plane(btPlaneNormal, plane.d));
}

/* Sphere */

SphereShapeBullet::SphereShapeBullet() :
		ShapeBullet() {}

void SphereShapeBullet::set_data(const Variant &p_data) {
	setup(p_data);
}

Variant SphereShapeBullet::get_data() const {
	return radius;
}

PhysicsServer::ShapeType SphereShapeBullet::get_type() const {
	return PhysicsServer::SHAPE_SPHERE;
}

void SphereShapeBullet::setup(real_t p_radius) {
	radius = p_radius;
	notifyShapeChanged();
}

btCollisionShape *SphereShapeBullet::create_bt_shape(const btVector3 &p_implicit_scale, real_t p_extra_edge) {
	return prepare(ShapeBullet::create_shape_sphere(radius * p_implicit_scale[0] + p_extra_edge));
}

/* Box */
BoxShapeBullet::BoxShapeBullet() :
		ShapeBullet() {}

void BoxShapeBullet::set_data(const Variant &p_data) {
	setup(p_data);
}

Variant BoxShapeBullet::get_data() const {
	Vector3 g_half_extents;
	B_TO_G(half_extents, g_half_extents);
	return g_half_extents;
}

PhysicsServer::ShapeType BoxShapeBullet::get_type() const {
	return PhysicsServer::SHAPE_BOX;
}

void BoxShapeBullet::setup(const Vector3 &p_half_extents) {
	G_TO_B(p_half_extents, half_extents);
	notifyShapeChanged();
}

btCollisionShape *BoxShapeBullet::create_bt_shape(const btVector3 &p_implicit_scale, real_t p_extra_edge) {
	return prepare(ShapeBullet::create_shape_box((half_extents * p_implicit_scale) + btVector3(p_extra_edge, p_extra_edge, p_extra_edge)));
}

/* Capsule */

CapsuleShapeBullet::CapsuleShapeBullet() :
		ShapeBullet() {}

void CapsuleShapeBullet::set_data(const Variant &p_data) {
	Dictionary d = p_data;
	ERR_FAIL_COND(!d.has("radius"));
	ERR_FAIL_COND(!d.has("height"));
	setup(d["height"], d["radius"]);
}

Variant CapsuleShapeBullet::get_data() const {
	Dictionary d;
	d["radius"] = radius;
	d["height"] = height;
	return d;
}

PhysicsServer::ShapeType CapsuleShapeBullet::get_type() const {
	return PhysicsServer::SHAPE_CAPSULE;
}

void CapsuleShapeBullet::setup(real_t p_height, real_t p_radius) {
	radius = p_radius;
	height = p_height;
	notifyShapeChanged();
}

btCollisionShape *CapsuleShapeBullet::create_bt_shape(const btVector3 &p_implicit_scale, real_t p_extra_edge) {
	return prepare(ShapeBullet::create_shape_capsule(radius * p_implicit_scale[0] + p_extra_edge, height * p_implicit_scale[1] + p_extra_edge));
}

/* Cylinder */

CylinderShapeBullet::CylinderShapeBullet() :
		ShapeBullet() {}

void CylinderShapeBullet::set_data(const Variant &p_data) {
	Dictionary d = p_data;
	ERR_FAIL_COND(!d.has("radius"));
	ERR_FAIL_COND(!d.has("height"));
	setup(d["height"], d["radius"]);
}

Variant CylinderShapeBullet::get_data() const {
	Dictionary d;
	d["radius"] = radius;
	d["height"] = height;
	return d;
}

PhysicsServer::ShapeType CylinderShapeBullet::get_type() const {
	return PhysicsServer::SHAPE_CYLINDER;
}

void CylinderShapeBullet::setup(real_t p_height, real_t p_radius) {
	radius = p_radius;
	height = p_height;
	notifyShapeChanged();
}

btCollisionShape *CylinderShapeBullet::create_bt_shape(const btVector3 &p_implicit_scale, real_t p_margin) {
	return prepare(ShapeBullet::create_shape_cylinder(radius * p_implicit_scale[0] + p_margin, height * p_implicit_scale[1] + p_margin));
}

/* Convex polygon */

ConvexPolygonShapeBullet::ConvexPolygonShapeBullet() :
		ShapeBullet() {}

void ConvexPolygonShapeBullet::set_data(const Variant &p_data) {
	setup(p_data);
}

void ConvexPolygonShapeBullet::get_vertices(Vector<Vector3> &out_vertices) {
	const int n_of_vertices = vertices.size();
	out_vertices.resize(n_of_vertices);
	for (int i = n_of_vertices - 1; 0 <= i; --i) {
		B_TO_G(vertices[i], out_vertices.write[i]);
	}
}

Variant ConvexPolygonShapeBullet::get_data() const {
	ConvexPolygonShapeBullet *variable_self = const_cast<ConvexPolygonShapeBullet *>(this);
	Vector<Vector3> out_vertices;
	variable_self->get_vertices(out_vertices);
	return out_vertices;
}

PhysicsServer::ShapeType ConvexPolygonShapeBullet::get_type() const {
	return PhysicsServer::SHAPE_CONVEX_POLYGON;
}

void ConvexPolygonShapeBullet::setup(const Vector<Vector3> &p_vertices) {
	// Make a copy of vertices
	const int n_of_vertices = p_vertices.size();
	vertices.resize(n_of_vertices);
	for (int i = n_of_vertices - 1; 0 <= i; --i) {
		G_TO_B(p_vertices[i], vertices[i]);
	}
	notifyShapeChanged();
}

btCollisionShape *ConvexPolygonShapeBullet::create_bt_shape(const btVector3 &p_implicit_scale, real_t p_extra_edge) {
	if (!vertices.size())
		// This is necessary since 0 vertices
		return prepare(ShapeBullet::create_shape_empty());
	btCollisionShape *cs(ShapeBullet::create_shape_convex(vertices));
	cs->setLocalScaling(p_implicit_scale);
	prepare(cs);
	return cs;
}

/* Concave polygon */

ConcavePolygonShapeBullet::ConcavePolygonShapeBullet() :
		ShapeBullet(),
		meshShape(NULL) {}

ConcavePolygonShapeBullet::~ConcavePolygonShapeBullet() {
	if (meshShape) {
		delete meshShape->getMeshInterface();
		delete meshShape->getTriangleInfoMap();
		bulletdelete(meshShape);
	}
	faces = PoolVector<Vector3>();
}

void ConcavePolygonShapeBullet::set_data(const Variant &p_data) {
	setup(p_data);
}

Variant ConcavePolygonShapeBullet::get_data() const {
	return faces;
}

PhysicsServer::ShapeType ConcavePolygonShapeBullet::get_type() const {
	return PhysicsServer::SHAPE_CONCAVE_POLYGON;
}

void ConcavePolygonShapeBullet::setup(PoolVector<Vector3> p_faces) {
	faces = p_faces;
	if (meshShape) {
		/// Clear previous created shape
		delete meshShape->getMeshInterface();
		delete meshShape->getTriangleInfoMap();
		bulletdelete(meshShape);
	}
	int src_face_count = faces.size();
	if (0 < src_face_count) {

		// It counts the faces and assert the array contains the correct number of vertices.
		ERR_FAIL_COND(src_face_count % 3);

		btTriangleMesh *shapeInterface = bulletnew(btTriangleMesh);
		src_face_count /= 3;
		PoolVector<Vector3>::Read r = p_faces.read();
		const Vector3 *facesr = r.ptr();

		btVector3 supVec_0;
		btVector3 supVec_1;
		btVector3 supVec_2;
		for (int i = 0; i < src_face_count; ++i) {
			G_TO_B(facesr[i * 3], supVec_0);
			G_TO_B(facesr[i * 3 + 1], supVec_1);
			G_TO_B(facesr[i * 3 + 2], supVec_2);

			shapeInterface->addTriangle(supVec_0, supVec_1, supVec_2);
		}

		const bool useQuantizedAabbCompression = true;

		meshShape = bulletnew(btBvhTriangleMeshShape(shapeInterface, useQuantizedAabbCompression));
		btTriangleInfoMap *triangleInfoMap = new btTriangleInfoMap();
		btGenerateInternalEdgeInfo(meshShape, triangleInfoMap);
	} else {
		meshShape = NULL;
		ERR_PRINT("The faces count are 0, the mesh shape cannot be created");
	}
	notifyShapeChanged();
}

btCollisionShape *ConcavePolygonShapeBullet::create_bt_shape(const btVector3 &p_implicit_scale, real_t p_extra_edge) {
	btCollisionShape *cs = ShapeBullet::create_shape_concave(meshShape);
	if (!cs)
		// This is necessary since if 0 faces the creation of concave return NULL
		cs = ShapeBullet::create_shape_empty();
	cs->setLocalScaling(p_implicit_scale);
	prepare(cs);
	return cs;
}

/* Height map shape */

HeightMapShapeBullet::HeightMapShapeBullet() :
		ShapeBullet() {}

void HeightMapShapeBullet::set_data(const Variant &p_data) {
	ERR_FAIL_COND(p_data.get_type() != Variant::DICTIONARY);
	Dictionary d = p_data;
	ERR_FAIL_COND(!d.has("width"));
	ERR_FAIL_COND(!d.has("depth"));
	ERR_FAIL_COND(!d.has("heights"));

	real_t l_min_height = 0.0;
	real_t l_max_height = 0.0;

	// If specified, min and max height will be used as precomputed values
	if (d.has("min_height"))
		l_min_height = d["min_height"];
	if (d.has("max_height"))
		l_max_height = d["max_height"];

	ERR_FAIL_COND(l_min_height > l_max_height);

	int l_width = d["width"];
	int l_depth = d["depth"];
	PoolVector<real_t> l_heights = d["heights"];

	ERR_FAIL_COND(l_width <= 0);
	ERR_FAIL_COND(l_depth <= 0);
	ERR_FAIL_COND(l_heights.size() != (l_width * l_depth));

	// Compute min and max heights if not specified.
	if (!d.has("min_height") && !d.has("max_height")) {

		PoolVector<real_t>::Read r = heights.read();
		int heights_size = heights.size();

		for (int i = 0; i < heights_size; ++i) {
			real_t h = r[i];

			if (h < l_min_height)
				l_min_height = h;
			else if (h > l_max_height)
				l_max_height = h;
		}
	}

	setup(l_heights, l_width, l_depth, l_min_height, l_max_height);
}

Variant HeightMapShapeBullet::get_data() const {
	ERR_FAIL_V(Variant());
}

PhysicsServer::ShapeType HeightMapShapeBullet::get_type() const {
	return PhysicsServer::SHAPE_HEIGHTMAP;
}

void HeightMapShapeBullet::setup(PoolVector<real_t> &p_heights, int p_width, int p_depth, real_t p_min_height, real_t p_max_height) {
	// TODO cell size must be tweaked using localScaling, which is a shared property for all Bullet shapes

	{ // Copy

		// TODO If Godot supported 16-bit integer image format, we could share the same memory block for heightfields
		// without having to copy anything, optimizing memory and loading performance (Bullet only reads and doesn't take ownership of the data).

		const int heights_size = p_heights.size();
		heights.resize(heights_size);
		PoolVector<real_t>::Read p_heights_r = p_heights.read();
		PoolVector<real_t>::Write heights_w = heights.write();
		for (int i = heights_size - 1; 0 <= i; --i) {
			heights_w[i] = p_heights_r[i];
		}
	}

	width = p_width;
	depth = p_depth;
	min_height = p_min_height;
	max_height = p_max_height;
	notifyShapeChanged();
}

btCollisionShape *HeightMapShapeBullet::create_bt_shape(const btVector3 &p_implicit_scale, real_t p_extra_edge) {
	btCollisionShape *cs(ShapeBullet::create_shape_height_field(heights, width, depth, min_height, max_height));
	cs->setLocalScaling(p_implicit_scale);
	prepare(cs);
	return cs;
}

/* Ray shape */
RayShapeBullet::RayShapeBullet() :
		ShapeBullet(),
		length(1),
		slips_on_slope(false) {}

void RayShapeBullet::set_data(const Variant &p_data) {

	Dictionary d = p_data;
	setup(d["length"], d["slips_on_slope"]);
}

Variant RayShapeBullet::get_data() const {

	Dictionary d;
	d["length"] = length;
	d["slips_on_slope"] = slips_on_slope;
	return d;
}

PhysicsServer::ShapeType RayShapeBullet::get_type() const {
	return PhysicsServer::SHAPE_RAY;
}

void RayShapeBullet::setup(real_t p_length, bool p_slips_on_slope) {
	length = p_length;
	slips_on_slope = p_slips_on_slope;
	notifyShapeChanged();
}

btCollisionShape *RayShapeBullet::create_bt_shape(const btVector3 &p_implicit_scale, real_t p_extra_edge) {
	return prepare(ShapeBullet::create_shape_ray(length * p_implicit_scale[1] + p_extra_edge, slips_on_slope));
}
