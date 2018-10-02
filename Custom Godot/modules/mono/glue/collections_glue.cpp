/*************************************************************************/
/*  collections_glue.cpp                                                 */
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

#include "collections_glue.h"

#include <mono/metadata/exception.h>

#include "../mono_gd/gd_mono_class.h"

Array *godot_icall_Array_Ctor() {
	return memnew(Array);
}

void godot_icall_Array_Dtor(Array *ptr) {
	memdelete(ptr);
}

MonoObject *godot_icall_Array_At(Array *ptr, int index) {
	if (index < 0 || index > ptr->size()) {
		GDMonoUtils::set_pending_exception(mono_get_exception_index_out_of_range());
		return NULL;
	}
	return GDMonoMarshal::variant_to_mono_object(ptr->operator[](index));
}

void godot_icall_Array_SetAt(Array *ptr, int index, MonoObject *value) {
	if (index < 0 || index > ptr->size()) {
		GDMonoUtils::set_pending_exception(mono_get_exception_index_out_of_range());
		return;
	}
	ptr->operator[](index) = GDMonoMarshal::mono_object_to_variant(value);
}

int godot_icall_Array_Count(Array *ptr) {
	return ptr->size();
}

void godot_icall_Array_Add(Array *ptr, MonoObject *item) {
	ptr->append(GDMonoMarshal::mono_object_to_variant(item));
}

void godot_icall_Array_Clear(Array *ptr) {
	ptr->clear();
}

bool godot_icall_Array_Contains(Array *ptr, MonoObject *item) {
	return ptr->find(GDMonoMarshal::mono_object_to_variant(item)) != -1;
}

void godot_icall_Array_CopyTo(Array *ptr, MonoArray *array, int array_index) {
	int count = ptr->size();

	if (mono_array_length(array) < (array_index + count)) {
		MonoException *exc = mono_get_exception_argument("", "Destination array was not long enough. Check destIndex and length, and the array's lower bounds.");
		GDMonoUtils::set_pending_exception(exc);
		return;
	}

	for (int i = 0; i < count; i++) {
		MonoObject *boxed = GDMonoMarshal::variant_to_mono_object(ptr->operator[](i));
		mono_array_setref(array, array_index, boxed);
		array_index++;
	}
}

int godot_icall_Array_IndexOf(Array *ptr, MonoObject *item) {
	return ptr->find(GDMonoMarshal::mono_object_to_variant(item));
}

void godot_icall_Array_Insert(Array *ptr, int index, MonoObject *item) {
	if (index < 0 || index > ptr->size()) {
		GDMonoUtils::set_pending_exception(mono_get_exception_index_out_of_range());
		return;
	}
	ptr->insert(index, GDMonoMarshal::mono_object_to_variant(item));
}

bool godot_icall_Array_Remove(Array *ptr, MonoObject *item) {
	int idx = ptr->find(GDMonoMarshal::mono_object_to_variant(item));
	if (idx >= 0) {
		ptr->remove(idx);
		return true;
	}
	return false;
}

void godot_icall_Array_RemoveAt(Array *ptr, int index) {
	if (index < 0 || index > ptr->size()) {
		GDMonoUtils::set_pending_exception(mono_get_exception_index_out_of_range());
		return;
	}
	ptr->remove(index);
}

Dictionary *godot_icall_Dictionary_Ctor() {
	return memnew(Dictionary);
}

void godot_icall_Dictionary_Dtor(Dictionary *ptr) {
	memdelete(ptr);
}

MonoObject *godot_icall_Dictionary_GetValue(Dictionary *ptr, MonoObject *key) {
	Variant *ret = ptr->getptr(GDMonoMarshal::mono_object_to_variant(key));
	if (ret == NULL) {
		MonoObject *exc = mono_object_new(mono_domain_get(), CACHED_CLASS(KeyNotFoundException)->get_mono_ptr());
#ifdef DEBUG_ENABLED
		CRASH_COND(!exc);
#endif
		GDMonoUtils::runtime_object_init(exc);
		GDMonoUtils::set_pending_exception((MonoException *)exc);
		return NULL;
	}
	return GDMonoMarshal::variant_to_mono_object(ret);
}

void godot_icall_Dictionary_SetValue(Dictionary *ptr, MonoObject *key, MonoObject *value) {
	ptr->operator[](GDMonoMarshal::mono_object_to_variant(key)) = GDMonoMarshal::mono_object_to_variant(value);
}

Array *godot_icall_Dictionary_Keys(Dictionary *ptr) {
	return memnew(Array(ptr->keys()));
}

Array *godot_icall_Dictionary_Values(Dictionary *ptr) {
	return memnew(Array(ptr->values()));
}

int godot_icall_Dictionary_Count(Dictionary *ptr) {
	return ptr->size();
}

void godot_icall_Dictionary_Add(Dictionary *ptr, MonoObject *key, MonoObject *value) {
	Variant varKey = GDMonoMarshal::mono_object_to_variant(key);
	Variant *ret = ptr->getptr(varKey);
	if (ret != NULL) {
		GDMonoUtils::set_pending_exception(mono_get_exception_argument("key", "An element with the same key already exists"));
		return;
	}
	ptr->operator[](varKey) = GDMonoMarshal::mono_object_to_variant(value);
}

void godot_icall_Dictionary_Clear(Dictionary *ptr) {
	ptr->clear();
}

bool godot_icall_Dictionary_Contains(Dictionary *ptr, MonoObject *key, MonoObject *value) {
	// no dupes
	Variant *ret = ptr->getptr(GDMonoMarshal::mono_object_to_variant(key));
	return ret != NULL && *ret == GDMonoMarshal::mono_object_to_variant(value);
}

bool godot_icall_Dictionary_ContainsKey(Dictionary *ptr, MonoObject *key) {
	return ptr->has(GDMonoMarshal::mono_object_to_variant(key));
}

bool godot_icall_Dictionary_RemoveKey(Dictionary *ptr, MonoObject *key) {
	return ptr->erase_checked(GDMonoMarshal::mono_object_to_variant(key));
}

bool godot_icall_Dictionary_Remove(Dictionary *ptr, MonoObject *key, MonoObject *value) {
	Variant varKey = GDMonoMarshal::mono_object_to_variant(key);

	// no dupes
	Variant *ret = ptr->getptr(varKey);
	if (ret != NULL && *ret == GDMonoMarshal::mono_object_to_variant(value)) {
		ptr->erase_checked(varKey);
		return true;
	}

	return false;
}

bool godot_icall_Dictionary_TryGetValue(Dictionary *ptr, MonoObject *key, MonoObject **value) {
	Variant *ret = ptr->getptr(GDMonoMarshal::mono_object_to_variant(key));
	if (ret == NULL) {
		*value = NULL;
		return false;
	}
	*value = GDMonoMarshal::variant_to_mono_object(ret);
	return true;
}

void godot_register_collections_icalls() {
	mono_add_internal_call("Godot.Array::godot_icall_Array_Ctor", (void *)godot_icall_Array_Ctor);
	mono_add_internal_call("Godot.Array::godot_icall_Array_Dtor", (void *)godot_icall_Array_Dtor);
	mono_add_internal_call("Godot.Array::godot_icall_Array_At", (void *)godot_icall_Array_At);
	mono_add_internal_call("Godot.Array::godot_icall_Array_SetAt", (void *)godot_icall_Array_SetAt);
	mono_add_internal_call("Godot.Array::godot_icall_Array_Count", (void *)godot_icall_Array_Count);
	mono_add_internal_call("Godot.Array::godot_icall_Array_Add", (void *)godot_icall_Array_Add);
	mono_add_internal_call("Godot.Array::godot_icall_Array_Clear", (void *)godot_icall_Array_Clear);
	mono_add_internal_call("Godot.Array::godot_icall_Array_Contains", (void *)godot_icall_Array_Contains);
	mono_add_internal_call("Godot.Array::godot_icall_Array_CopyTo", (void *)godot_icall_Array_CopyTo);
	mono_add_internal_call("Godot.Array::godot_icall_Array_IndexOf", (void *)godot_icall_Array_IndexOf);
	mono_add_internal_call("Godot.Array::godot_icall_Array_Insert", (void *)godot_icall_Array_Insert);
	mono_add_internal_call("Godot.Array::godot_icall_Array_Remove", (void *)godot_icall_Array_Remove);
	mono_add_internal_call("Godot.Array::godot_icall_Array_RemoveAt", (void *)godot_icall_Array_RemoveAt);

	mono_add_internal_call("Godot.Dictionary::godot_icall_Dictionary_Ctor", (void *)godot_icall_Dictionary_Ctor);
	mono_add_internal_call("Godot.Dictionary::godot_icall_Dictionary_Dtor", (void *)godot_icall_Dictionary_Dtor);
	mono_add_internal_call("Godot.Dictionary::godot_icall_Dictionary_GetValue", (void *)godot_icall_Dictionary_GetValue);
	mono_add_internal_call("Godot.Dictionary::godot_icall_Dictionary_SetValue", (void *)godot_icall_Dictionary_SetValue);
	mono_add_internal_call("Godot.Dictionary::godot_icall_Dictionary_Keys", (void *)godot_icall_Dictionary_Keys);
	mono_add_internal_call("Godot.Dictionary::godot_icall_Dictionary_Values", (void *)godot_icall_Dictionary_Values);
	mono_add_internal_call("Godot.Dictionary::godot_icall_Dictionary_Count", (void *)godot_icall_Dictionary_Count);
	mono_add_internal_call("Godot.Dictionary::godot_icall_Dictionary_Add", (void *)godot_icall_Dictionary_Add);
	mono_add_internal_call("Godot.Dictionary::godot_icall_Dictionary_Clear", (void *)godot_icall_Dictionary_Clear);
	mono_add_internal_call("Godot.Dictionary::godot_icall_Dictionary_Contains", (void *)godot_icall_Dictionary_Contains);
	mono_add_internal_call("Godot.Dictionary::godot_icall_Dictionary_ContainsKey", (void *)godot_icall_Dictionary_ContainsKey);
	mono_add_internal_call("Godot.Dictionary::godot_icall_Dictionary_RemoveKey", (void *)godot_icall_Dictionary_RemoveKey);
	mono_add_internal_call("Godot.Dictionary::godot_icall_Dictionary_Remove", (void *)godot_icall_Dictionary_Remove);
	mono_add_internal_call("Godot.Dictionary::godot_icall_Dictionary_TryGetValue", (void *)godot_icall_Dictionary_TryGetValue);
}
