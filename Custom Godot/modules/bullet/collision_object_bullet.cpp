/*************************************************************************/
/*  collision_object_bullet.cpp                                          */
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

#include "collision_object_bullet.h"

#include "area_bullet.h"
#include "bullet_physics_server.h"
#include "bullet_types_converter.h"
#include "bullet_utilities.h"
#include "shape_bullet.h"
#include "space_bullet.h"

#include <btBulletCollisionCommon.h>

/**
	@author AndreaCatania
*/

#define enableDynamicAabbTree true
#define initialChildCapacity 1

CollisionObjectBullet::ShapeWrapper::~ShapeWrapper() {}

void CollisionObjectBullet::ShapeWrapper::set_transform(const Transform &p_transform) {
	G_TO_B(p_transform.get_basis().get_scale_abs(), scale);
	G_TO_B(p_transform, transform);
	UNSCALE_BT_BASIS(transform);
}

void CollisionObjectBullet::ShapeWrapper::set_transform(const btTransform &p_transform) {
	transform = p_transform;
}

void CollisionObjectBullet::ShapeWrapper::claim_bt_shape(const btVector3 &body_scale) {
	if (!bt_shape) {
		bt_shape = shape->create_bt_shape(scale * body_scale);
	}
}

CollisionObjectBullet::CollisionObjectBullet(Type p_type) :
		RIDBullet(),
		space(NULL),
		type(p_type),
		collisionsEnabled(true),
		m_isStatic(false),
		bt_collision_object(NULL),
		body_scale(1., 1., 1.),
		force_shape_reset(false) {}

CollisionObjectBullet::~CollisionObjectBullet() {
	// Remove all overlapping, notify is not required since godot take care of it
	for (int i = areasOverlapped.size() - 1; 0 <= i; --i) {
		areasOverlapped[i]->remove_overlap(this, /*Notify*/ false);
	}

	destroyBulletCollisionObject();
}

bool equal(real_t first, real_t second) {
	return Math::abs(first - second) <= 0.001f;
}

void CollisionObjectBullet::set_body_scale(const Vector3 &p_new_scale) {
	if (!equal(p_new_scale[0], body_scale[0]) || !equal(p_new_scale[1], body_scale[1]) || !equal(p_new_scale[2], body_scale[2])) {
		body_scale = p_new_scale;
		on_body_scale_changed();
	}
}

btVector3 CollisionObjectBullet::get_bt_body_scale() const {
	btVector3 s;
	G_TO_B(body_scale, s);
	return s;
}

void CollisionObjectBullet::on_body_scale_changed() {
	force_shape_reset = true;
}

void CollisionObjectBullet::destroyBulletCollisionObject() {
	bulletdelete(bt_collision_object);
}

void CollisionObjectBullet::setupBulletCollisionObject(btCollisionObject *p_collisionObject) {
	bt_collision_object = p_collisionObject;
	bt_collision_object->setUserPointer(this);
	bt_collision_object->setUserIndex(type);
	// Force the enabling of collision and avoid problems
	set_collision_enabled(collisionsEnabled);
	p_collisionObject->setCollisionFlags(p_collisionObject->getCollisionFlags() | btCollisionObject::CF_CUSTOM_MATERIAL_CALLBACK);
}

void CollisionObjectBullet::add_collision_exception(const CollisionObjectBullet *p_ignoreCollisionObject) {
	exceptions.insert(p_ignoreCollisionObject->get_self());
	if (!bt_collision_object)
		return;
	bt_collision_object->setIgnoreCollisionCheck(p_ignoreCollisionObject->bt_collision_object, true);
	if (space)
		space->get_broadphase()->getOverlappingPairCache()->cleanProxyFromPairs(bt_collision_object->getBroadphaseHandle(), space->get_dispatcher());
}

void CollisionObjectBullet::remove_collision_exception(const CollisionObjectBullet *p_ignoreCollisionObject) {
	exceptions.erase(p_ignoreCollisionObject->get_self());
	bt_collision_object->setIgnoreCollisionCheck(p_ignoreCollisionObject->bt_collision_object, false);
	if (space)
		space->get_broadphase()->getOverlappingPairCache()->cleanProxyFromPairs(bt_collision_object->getBroadphaseHandle(), space->get_dispatcher());
}

bool CollisionObjectBullet::has_collision_exception(const CollisionObjectBullet *p_otherCollisionObject) const {
	return !bt_collision_object->checkCollideWith(p_otherCollisionObject->bt_collision_object);
}

void CollisionObjectBullet::set_collision_enabled(bool p_enabled) {
	collisionsEnabled = p_enabled;
	if (collisionsEnabled) {
		bt_collision_object->setCollisionFlags(bt_collision_object->getCollisionFlags() & (~btCollisionObject::CF_NO_CONTACT_RESPONSE));
	} else {
		bt_collision_object->setCollisionFlags(bt_collision_object->getCollisionFlags() | btCollisionObject::CF_NO_CONTACT_RESPONSE);
	}
}

bool CollisionObjectBullet::is_collisions_response_enabled() {
	return collisionsEnabled;
}

void CollisionObjectBullet::notify_new_overlap(AreaBullet *p_area) {
	areasOverlapped.push_back(p_area);
}

void CollisionObjectBullet::on_exit_area(AreaBullet *p_area) {
	areasOverlapped.erase(p_area);
}

void CollisionObjectBullet::set_godot_object_flags(int flags) {
	bt_collision_object->setUserIndex2(flags);
}

int CollisionObjectBullet::get_godot_object_flags() const {
	return bt_collision_object->getUserIndex2();
}

void CollisionObjectBullet::set_transform(const Transform &p_global_transform) {

	set_body_scale(p_global_transform.basis.get_scale_abs());

	btTransform bt_transform;
	G_TO_B(p_global_transform, bt_transform);
	UNSCALE_BT_BASIS(bt_transform);

	set_transform__bullet(bt_transform);
}

Transform CollisionObjectBullet::get_transform() const {
	Transform t;
	B_TO_G(get_transform__bullet(), t);
	t.basis.scale(body_scale);
	return t;
}

void CollisionObjectBullet::set_transform__bullet(const btTransform &p_global_transform) {
	bt_collision_object->setWorldTransform(p_global_transform);
}

const btTransform &CollisionObjectBullet::get_transform__bullet() const {
	return bt_collision_object->getWorldTransform();
}

RigidCollisionObjectBullet::RigidCollisionObjectBullet(Type p_type) :
		CollisionObjectBullet(p_type),
		mainShape(NULL) {
}

RigidCollisionObjectBullet::~RigidCollisionObjectBullet() {
	remove_all_shapes(true);
	if (mainShape && mainShape->isCompound()) {
		bulletdelete(mainShape);
	}
}

/* Not used
void RigidCollisionObjectBullet::_internal_replaceShape(btCollisionShape *p_old_shape, btCollisionShape *p_new_shape) {
	bool at_least_one_was_changed = false;
	btTransform old_transf;
	// Inverse because I need remove the shapes
	// Fetch all shapes to be sure to remove all shapes
	for (int i = compoundShape->getNumChildShapes() - 1; 0 <= i; --i) {
		if (compoundShape->getChildShape(i) == p_old_shape) {

			old_transf = compoundShape->getChildTransform(i);
			compoundShape->removeChildShapeByIndex(i);
			compoundShape->addChildShape(old_transf, p_new_shape);
			at_least_one_was_changed = true;
		}
	}

	if (at_least_one_was_changed) {
		on_shapes_changed();
	}
}*/

void RigidCollisionObjectBullet::add_shape(ShapeBullet *p_shape, const Transform &p_transform) {
	shapes.push_back(ShapeWrapper(p_shape, p_transform, true));
	p_shape->add_owner(this);
	on_shapes_changed();
}

void RigidCollisionObjectBullet::set_shape(int p_index, ShapeBullet *p_shape) {
	ShapeWrapper &shp = shapes.write[p_index];
	shp.shape->remove_owner(this);
	p_shape->add_owner(this);
	shp.shape = p_shape;
	on_shapes_changed();
}

void RigidCollisionObjectBullet::set_shape_transform(int p_index, const Transform &p_transform) {
	ERR_FAIL_INDEX(p_index, get_shape_count());

	shapes.write[p_index].set_transform(p_transform);
	on_shape_changed(shapes.write[p_index].shape);
}

void RigidCollisionObjectBullet::remove_shape(ShapeBullet *p_shape) {
	// Remove the shape, all the times it appears
	// Reverse order required for delete.
	for (int i = shapes.size() - 1; 0 <= i; --i) {
		if (p_shape == shapes[i].shape) {
			internal_shape_destroy(i);
			shapes.remove(i);
		}
	}
	on_shapes_changed();
}

void RigidCollisionObjectBullet::remove_shape(int p_index) {
	ERR_FAIL_INDEX(p_index, get_shape_count());
	internal_shape_destroy(p_index);
	shapes.remove(p_index);
	on_shapes_changed();
}

void RigidCollisionObjectBullet::remove_all_shapes(bool p_permanentlyFromThisBody) {
	// Reverse order required for delete.
	for (int i = shapes.size() - 1; 0 <= i; --i) {
		internal_shape_destroy(i, p_permanentlyFromThisBody);
	}
	shapes.clear();
	on_shapes_changed();
}

int RigidCollisionObjectBullet::get_shape_count() const {
	return shapes.size();
}

ShapeBullet *RigidCollisionObjectBullet::get_shape(int p_index) const {
	return shapes[p_index].shape;
}

btCollisionShape *RigidCollisionObjectBullet::get_bt_shape(int p_index) const {
	return shapes[p_index].bt_shape;
}

const btTransform &RigidCollisionObjectBullet::get_bt_shape_transform(int p_index) const {
	return shapes[p_index].transform;
}

Transform RigidCollisionObjectBullet::get_shape_transform(int p_index) const {
	Transform trs;
	B_TO_G(shapes[p_index].transform, trs);
	return trs;
}

void RigidCollisionObjectBullet::on_shape_changed(const ShapeBullet *const p_shape) {
	const int size = shapes.size();
	for (int i = 0; i < size; ++i) {
		if (shapes[i].shape == p_shape) {
			bulletdelete(shapes.write[i].bt_shape);
		}
	}
	on_shapes_changed();
}

void RigidCollisionObjectBullet::on_shapes_changed() {

	if (mainShape && mainShape->isCompound()) {
		bulletdelete(mainShape);
	}
	mainShape = NULL;

	ShapeWrapper *shpWrapper;
	const int shape_count = shapes.size();

	// Reset shape if required
	if (force_shape_reset) {
		for (int i(0); i < shape_count; ++i) {
			shpWrapper = &shapes.write[i];
			bulletdelete(shpWrapper->bt_shape);
		}
		force_shape_reset = false;
	}

	btVector3 body_scale(get_bt_body_scale());

	if (!shape_count)
		return;

	// Try to optimize by not using compound
	if (1 == shape_count) {
		shpWrapper = &shapes.write[0];
		if (shpWrapper->active && shpWrapper->transform.getOrigin().isZero() && shpWrapper->transform.getBasis() == shpWrapper->transform.getBasis().getIdentity()) {
			shpWrapper->claim_bt_shape(body_scale);
			mainShape = shpWrapper->bt_shape;
			main_shape_resetted();
			return;
		}
	}

	btCompoundShape *compoundShape = bulletnew(btCompoundShape(enableDynamicAabbTree, initialChildCapacity));

	// Insert all shapes into compound
	for (int i(0); i < shape_count; ++i) {
		shpWrapper = &shapes.write[i];
		if (shpWrapper->active) {
			shpWrapper->claim_bt_shape(body_scale);

			btTransform scaled_shape_transform(shpWrapper->transform);
			scaled_shape_transform.getOrigin() *= body_scale;
			compoundShape->addChildShape(scaled_shape_transform, shpWrapper->bt_shape);
		} else {
			compoundShape->addChildShape(btTransform(), BulletPhysicsServer::get_empty_shape());
		}
	}

	compoundShape->recalculateLocalAabb();
	mainShape = compoundShape;
	main_shape_resetted();
}

void RigidCollisionObjectBullet::set_shape_disabled(int p_index, bool p_disabled) {
	shapes.write[p_index].active = !p_disabled;
	on_shapes_changed();
}

bool RigidCollisionObjectBullet::is_shape_disabled(int p_index) {
	return !shapes[p_index].active;
}

void RigidCollisionObjectBullet::on_body_scale_changed() {
	CollisionObjectBullet::on_body_scale_changed();
	on_shapes_changed();
}

void RigidCollisionObjectBullet::internal_shape_destroy(int p_index, bool p_permanentlyFromThisBody) {
	ShapeWrapper &shp = shapes.write[p_index];
	shp.shape->remove_owner(this, p_permanentlyFromThisBody);
	bulletdelete(shp.bt_shape);
}
