/*************************************************************************/
/*  property_editor.cpp                                                  */
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

#include "property_editor.h"

#include "core/class_db.h"
#include "core/io/image_loader.h"
#include "core/io/marshalls.h"
#include "core/io/resource_loader.h"
#include "core/os/input.h"
#include "core/os/keyboard.h"
#include "core/pair.h"
#include "core/print_string.h"
#include "core/project_settings.h"
#include "editor/array_property_edit.h"
#include "editor/create_dialog.h"
#include "editor/dictionary_property_edit.h"
#include "editor/editor_export.h"
#include "editor/editor_file_system.h"
#include "editor/editor_help.h"
#include "editor/editor_node.h"
#include "editor/editor_settings.h"
#include "editor/multi_node_edit.h"
#include "editor/property_selector.h"
#include "scene/gui/label.h"
#include "scene/main/viewport.h"
#include "scene/resources/font.h"
#include "scene/resources/packed_scene.h"
#include "scene/scene_string_names.h"

void EditorResourceConversionPlugin::_bind_methods() {

	MethodInfo mi;
	mi.name = "_convert";
	mi.return_val.type = Variant::OBJECT;
	mi.return_val.class_name = "Resource";
	mi.return_val.hint = PROPERTY_HINT_RESOURCE_TYPE;
	mi.return_val.hint_string = "Resource";
	mi.arguments.push_back(mi.return_val);
	mi.arguments[0].name = "resource";

	BIND_VMETHOD(mi)

	mi.name = "_handles";
	mi.return_val = PropertyInfo(Variant::BOOL, "");

	BIND_VMETHOD(MethodInfo(Variant::STRING, "_converts_to"));
}

String EditorResourceConversionPlugin::converts_to() const {

	if (get_script_instance())
		return get_script_instance()->call("_converts_to");

	return "";
}

bool EditorResourceConversionPlugin::handles(const Ref<Resource> &p_resource) const {

	if (get_script_instance())
		return get_script_instance()->call("_handles", p_resource);

	return false;
}

Ref<Resource> EditorResourceConversionPlugin::convert(const Ref<Resource> &p_resource) {

	if (get_script_instance())
		return get_script_instance()->call("_convert", p_resource);

	return Ref<Resource>();
}

void CustomPropertyEditor::_notification(int p_what) {

	if (p_what == NOTIFICATION_DRAW) {

		RID ci = get_canvas_item();
		get_stylebox("panel", "PopupMenu")->draw(ci, Rect2(Point2(), get_size()));
	}
	if (p_what == MainLoop::NOTIFICATION_WM_QUIT_REQUEST) {
		hide();
	}
}

void CustomPropertyEditor::_menu_option(int p_which) {

	switch (type) {

		case Variant::INT: {

			if (hint == PROPERTY_HINT_FLAGS) {

				int val = v;

				if (val & (1 << p_which)) {

					val &= ~(1 << p_which);
				} else {
					val |= (1 << p_which);
				}

				v = val;
				emit_signal("variant_changed");
			} else if (hint == PROPERTY_HINT_ENUM) {

				v = p_which;
				emit_signal("variant_changed");
			}
		} break;
		case Variant::STRING: {

			if (hint == PROPERTY_HINT_ENUM) {

				v = hint_text.get_slice(",", p_which);
				emit_signal("variant_changed");
			}
		} break;
		case Variant::OBJECT: {

			switch (p_which) {
				case OBJ_MENU_LOAD: {

					file->set_mode(EditorFileDialog::MODE_OPEN_FILE);
					String type = (hint == PROPERTY_HINT_RESOURCE_TYPE) ? hint_text : String();

					List<String> extensions;
					for (int i = 0; i < type.get_slice_count(","); i++) {

						ResourceLoader::get_recognized_extensions_for_type(type.get_slice(",", i), &extensions);
					}

					Set<String> valid_extensions;
					for (List<String>::Element *E = extensions.front(); E; E = E->next()) {
						valid_extensions.insert(E->get());
					}

					file->clear_filters();
					for (Set<String>::Element *E = valid_extensions.front(); E; E = E->next()) {

						file->add_filter("*." + E->get() + " ; " + E->get().to_upper());
					}

					file->popup_centered_ratio();
				} break;

				case OBJ_MENU_EDIT: {

					RefPtr RefPtr = v;

					if (!RefPtr.is_null()) {

						emit_signal("resource_edit_request");
						hide();
					}
				} break;
				case OBJ_MENU_CLEAR: {

					v = Variant();
					emit_signal("variant_changed");
					hide();
				} break;

				case OBJ_MENU_MAKE_UNIQUE: {

					RefPtr RefPtr = v;
					Ref<Resource> res_orig = RefPtr;
					if (res_orig.is_null())
						return;

					List<PropertyInfo> property_list;
					res_orig->get_property_list(&property_list);
					List<Pair<String, Variant> > propvalues;

					for (List<PropertyInfo>::Element *E = property_list.front(); E; E = E->next()) {

						Pair<String, Variant> p;
						PropertyInfo &pi = E->get();
						if (pi.usage & PROPERTY_USAGE_STORAGE) {

							p.first = pi.name;
							p.second = res_orig->get(pi.name);
						}

						propvalues.push_back(p);
					}

					String orig_type = res_orig->get_class();

					Object *inst = ClassDB::instance(orig_type);

					Ref<Resource> res = Ref<Resource>(Object::cast_to<Resource>(inst));

					ERR_FAIL_COND(res.is_null());

					for (List<Pair<String, Variant> >::Element *E = propvalues.front(); E; E = E->next()) {

						Pair<String, Variant> &p = E->get();
						res->set(p.first, p.second);
					}

					v = res.get_ref_ptr();
					emit_signal("variant_changed");
					hide();
				} break;

				case OBJ_MENU_COPY: {

					EditorSettings::get_singleton()->set_resource_clipboard(v);

				} break;
				case OBJ_MENU_PASTE: {

					v = EditorSettings::get_singleton()->get_resource_clipboard();
					emit_signal("variant_changed");

				} break;
				case OBJ_MENU_NEW_SCRIPT: {

					if (Object::cast_to<Node>(owner))
						EditorNode::get_singleton()->get_scene_tree_dock()->open_script_dialog(Object::cast_to<Node>(owner));

				} break;
				case OBJ_MENU_SHOW_IN_FILE_SYSTEM: {
					RES r = v;
					FileSystemDock *file_system_dock = EditorNode::get_singleton()->get_filesystem_dock();
					file_system_dock->navigate_to_path(r->get_path());
					// Ensure that the FileSystem dock is visible.
					TabContainer *tab_container = (TabContainer *)file_system_dock->get_parent_control();
					tab_container->set_current_tab(file_system_dock->get_position_in_parent());
				} break;
				default: {

					if (p_which >= CONVERT_BASE_ID) {

						int to_type = p_which - CONVERT_BASE_ID;

						Vector<Ref<EditorResourceConversionPlugin> > conversions = EditorNode::get_singleton()->find_resource_conversion_plugin(RES(v));

						ERR_FAIL_INDEX(to_type, conversions.size());

						Ref<Resource> new_res = conversions[to_type]->convert(v);

						v = new_res;
						emit_signal("variant_changed");
						break;
					}
					ERR_FAIL_COND(inheritors_array.empty());

					String intype = inheritors_array[p_which - TYPE_BASE_ID];

					if (intype == "ViewportTexture") {

						scene_tree->set_title(TTR("Pick a Viewport"));
						scene_tree->popup_centered_ratio();
						picking_viewport = true;
						return;
					}

					Object *obj = ClassDB::instance(intype);
					ERR_BREAK(!obj);
					Resource *res = Object::cast_to<Resource>(obj);
					ERR_BREAK(!res);
					if (owner && hint == PROPERTY_HINT_RESOURCE_TYPE && hint_text == "Script") {
						//make visual script the right type
						res->call("set_instance_base_type", owner->get_class());
					}

					v = Ref<Resource>(res).get_ref_ptr();
					emit_signal("variant_changed");

				} break;
			}

		} break;
		default: {}
	}
}

void CustomPropertyEditor::hide_menu() {
	menu->hide();
}

Variant CustomPropertyEditor::get_variant() const {

	return v;
}

String CustomPropertyEditor::get_name() const {

	return name;
}

bool CustomPropertyEditor::edit(Object *p_owner, const String &p_name, Variant::Type p_type, const Variant &p_variant, int p_hint, String p_hint_text) {

	owner = p_owner;
	updating = true;
	name = p_name;
	v = p_variant;
	field_names.clear();
	hint = p_hint;
	hint_text = p_hint_text;
	type_button->hide();
	if (color_picker)
		color_picker->hide();
	texture_preview->hide();
	inheritors_array.clear();
	text_edit->hide();
	easing_draw->hide();
	spinbox->hide();
	slider->hide();
	menu->clear();
	menu->set_size(Size2(1, 1) * EDSCALE);

	for (int i = 0; i < MAX_VALUE_EDITORS; i++) {

		value_editor[i]->hide();
		value_label[i]->hide();
		if (i < 4)
			scroll[i]->hide();
	}

	for (int i = 0; i < MAX_ACTION_BUTTONS; i++) {

		action_buttons[i]->hide();
	}

	checks20gc->hide();
	for (int i = 0; i < 20; i++)
		checks20[i]->hide();

	type = (p_variant.get_type() != Variant::NIL && p_variant.get_type() != Variant::_RID && p_type != Variant::OBJECT) ? p_variant.get_type() : p_type;

	switch (type) {

		case Variant::BOOL: {

			checks20gc->show();

			CheckBox *c = checks20[0];
			c->set_text("True");
			checks20gc->set_position(Vector2(4, 4) * EDSCALE);
			c->set_pressed(v);
			c->show();

			checks20gc->set_size(checks20gc->get_minimum_size());
			set_size(checks20gc->get_position() + checks20gc->get_size() + c->get_size() + Vector2(4, 4) * EDSCALE);

		} break;
		case Variant::INT:
		case Variant::REAL: {

			if (hint == PROPERTY_HINT_RANGE) {

				int c = hint_text.get_slice_count(",");
				float min = 0, max = 100, step = type == Variant::REAL ? .01 : 1;
				if (c >= 1) {

					if (!hint_text.get_slice(",", 0).empty())
						min = hint_text.get_slice(",", 0).to_double();
				}
				if (c >= 2) {

					if (!hint_text.get_slice(",", 1).empty())
						max = hint_text.get_slice(",", 1).to_double();
				}

				if (c >= 3) {

					if (!hint_text.get_slice(",", 2).empty())
						step = hint_text.get_slice(",", 2).to_double();
				}

				if (c >= 4 && hint_text.get_slice(",", 3) == "slider") {
					slider->set_min(min);
					slider->set_max(max);
					slider->set_step(step);
					slider->set_value(v);
					slider->show();
					set_size(Size2(110, 30) * EDSCALE);
				} else {
					spinbox->set_min(min);
					spinbox->set_max(max);
					spinbox->set_step(step);
					spinbox->set_value(v);
					spinbox->show();
					set_size(Size2(70, 35) * EDSCALE);
				}

			} else if (hint == PROPERTY_HINT_ENUM) {

				Vector<String> options = hint_text.split(",");
				for (int i = 0; i < options.size(); i++) {
					if (options[i].find(":") != -1) {
						menu->add_item(options[i].get_slicec(':', 0), options[i].get_slicec(':', 1).to_int());
					} else {
						menu->add_item(options[i], i);
					}
				}
				menu->set_position(get_position());
				menu->popup();
				hide();
				updating = false;
				return false;

			} else if (hint == PROPERTY_HINT_LAYERS_2D_PHYSICS || hint == PROPERTY_HINT_LAYERS_2D_RENDER || hint == PROPERTY_HINT_LAYERS_3D_PHYSICS || hint == PROPERTY_HINT_LAYERS_3D_RENDER) {

				String basename;
				switch (hint) {
					case PROPERTY_HINT_LAYERS_2D_RENDER:
						basename = "layer_names/2d_render";
						break;
					case PROPERTY_HINT_LAYERS_2D_PHYSICS:
						basename = "layer_names/2d_physics";
						break;
					case PROPERTY_HINT_LAYERS_3D_RENDER:
						basename = "layer_names/3d_render";
						break;
					case PROPERTY_HINT_LAYERS_3D_PHYSICS:
						basename = "layer_names/3d_physics";
						break;
				}

				checks20gc->show();
				uint32_t flgs = v;
				for (int i = 0; i < 2; i++) {

					Point2 ofs(4, 4);
					ofs.y += 22 * i;
					for (int j = 0; j < 10; j++) {

						int idx = i * 10 + j;
						CheckBox *c = checks20[idx];
						c->set_text(ProjectSettings::get_singleton()->get(basename + "/layer_" + itos(idx + 1)));
						c->set_pressed(flgs & (1 << (i * 10 + j)));
						c->show();
					}
				}

				show();

				checks20gc->set_position(Vector2(4, 4) * EDSCALE);
				checks20gc->set_size(checks20gc->get_minimum_size());

				set_size(Vector2(4, 4) * EDSCALE + checks20gc->get_position() + checks20gc->get_size());

			} else if (hint == PROPERTY_HINT_EXP_EASING) {

				easing_draw->set_anchor_and_margin(MARGIN_LEFT, ANCHOR_BEGIN, 5 * EDSCALE);
				easing_draw->set_anchor_and_margin(MARGIN_RIGHT, ANCHOR_END, -5 * EDSCALE);
				easing_draw->set_anchor_and_margin(MARGIN_TOP, ANCHOR_BEGIN, 5 * EDSCALE);
				easing_draw->set_anchor_and_margin(MARGIN_BOTTOM, ANCHOR_END, -30 * EDSCALE);
				type_button->set_anchor_and_margin(MARGIN_LEFT, ANCHOR_BEGIN, 3 * EDSCALE);
				type_button->set_anchor_and_margin(MARGIN_RIGHT, ANCHOR_END, -3 * EDSCALE);
				type_button->set_anchor_and_margin(MARGIN_TOP, ANCHOR_END, -25 * EDSCALE);
				type_button->set_anchor_and_margin(MARGIN_BOTTOM, ANCHOR_END, -7 * EDSCALE);
				type_button->set_text(TTR("Preset..."));
				type_button->get_popup()->clear();
				type_button->get_popup()->add_item(TTR("Linear"), EASING_LINEAR);
				type_button->get_popup()->add_item(TTR("Ease In"), EASING_EASE_IN);
				type_button->get_popup()->add_item(TTR("Ease Out"), EASING_EASE_OUT);
				if (hint_text != "attenuation") {
					type_button->get_popup()->add_item(TTR("Zero"), EASING_ZERO);
					type_button->get_popup()->add_item(TTR("Easing In-Out"), EASING_IN_OUT);
					type_button->get_popup()->add_item(TTR("Easing Out-In"), EASING_OUT_IN);
				}

				type_button->show();
				easing_draw->show();
				set_size(Size2(200, 150) * EDSCALE);
			} else if (hint == PROPERTY_HINT_FLAGS) {
				Vector<String> flags = hint_text.split(",");
				for (int i = 0; i < flags.size(); i++) {
					String flag = flags[i];
					if (flag == "")
						continue;
					menu->add_check_item(flag, i);
					int f = v;
					if (f & (1 << i))
						menu->set_item_checked(menu->get_item_index(i), true);
				}
				menu->set_position(get_position());
				menu->popup();
				hide();
				updating = false;
				return false;

			} else {
				List<String> names;
				names.push_back("value:");
				config_value_editors(1, 1, 50, names);
				value_editor[0]->set_text(String::num(v));
			}

		} break;
		case Variant::STRING: {

			if (hint == PROPERTY_HINT_FILE || hint == PROPERTY_HINT_GLOBAL_FILE) {

				List<String> names;
				names.push_back(TTR("File..."));
				names.push_back(TTR("Clear"));
				config_action_buttons(names);

			} else if (hint == PROPERTY_HINT_DIR || hint == PROPERTY_HINT_GLOBAL_DIR) {

				List<String> names;
				names.push_back(TTR("Dir..."));
				names.push_back(TTR("Clear"));
				config_action_buttons(names);
			} else if (hint == PROPERTY_HINT_ENUM) {

				Vector<String> options = hint_text.split(",");
				for (int i = 0; i < options.size(); i++) {
					menu->add_item(options[i], i);
				}
				menu->set_position(get_position());
				menu->popup();
				hide();
				updating = false;
				return false;

			} else if (hint == PROPERTY_HINT_MULTILINE_TEXT) {

				text_edit->show();
				text_edit->set_text(v);
				text_edit->deselect();

				int button_margin = get_constant("button_margin", "Dialogs");
				int margin = get_constant("margin", "Dialogs");

				action_buttons[0]->set_anchor(MARGIN_LEFT, ANCHOR_END);
				action_buttons[0]->set_anchor(MARGIN_TOP, ANCHOR_END);
				action_buttons[0]->set_anchor(MARGIN_RIGHT, ANCHOR_END);
				action_buttons[0]->set_anchor(MARGIN_BOTTOM, ANCHOR_END);
				action_buttons[0]->set_begin(Point2(-70 * EDSCALE, -button_margin + 5 * EDSCALE));
				action_buttons[0]->set_end(Point2(-margin, -margin));
				action_buttons[0]->set_text(TTR("Close"));
				action_buttons[0]->show();

			} else if (hint == PROPERTY_HINT_TYPE_STRING) {

				if (!create_dialog) {
					create_dialog = memnew(CreateDialog);
					create_dialog->connect("create", this, "_create_dialog_callback");
					add_child(create_dialog);
				}

				if (hint_text != String()) {
					create_dialog->set_base_type(hint_text);
				} else {
					create_dialog->set_base_type("Object");
				}

				create_dialog->popup_create(false);
				hide();
				updating = false;
				return false;

			} else if (hint == PROPERTY_HINT_METHOD_OF_VARIANT_TYPE) {
#define MAKE_PROPSELECT                                                          \
	if (!property_select) {                                                      \
		property_select = memnew(PropertySelector);                              \
		property_select->connect("selected", this, "_create_selected_property"); \
		add_child(property_select);                                              \
	}                                                                            \
	hide();

				MAKE_PROPSELECT;

				Variant::Type type = Variant::NIL;
				for (int i = 0; i < Variant::VARIANT_MAX; i++) {
					if (hint_text == Variant::get_type_name(Variant::Type(i))) {
						type = Variant::Type(i);
					}
				}
				if (type)
					property_select->select_method_from_basic_type(type, v);
				updating = false;
				return false;

			} else if (hint == PROPERTY_HINT_METHOD_OF_BASE_TYPE) {
				MAKE_PROPSELECT

				property_select->select_method_from_base_type(hint_text, v);

				updating = false;
				return false;

			} else if (hint == PROPERTY_HINT_METHOD_OF_INSTANCE) {

				MAKE_PROPSELECT

				Object *instance = ObjectDB::get_instance(hint_text.to_int64());
				if (instance)
					property_select->select_method_from_instance(instance, v);
				updating = false;
				return false;

			} else if (hint == PROPERTY_HINT_METHOD_OF_SCRIPT) {
				MAKE_PROPSELECT

				Object *obj = ObjectDB::get_instance(hint_text.to_int64());
				if (Object::cast_to<Script>(obj)) {
					property_select->select_method_from_script(Object::cast_to<Script>(obj), v);
				}

				updating = false;
				return false;

			} else if (hint == PROPERTY_HINT_PROPERTY_OF_VARIANT_TYPE) {

				MAKE_PROPSELECT
				Variant::Type type = Variant::NIL;
				String tname = hint_text;
				if (tname.find(".") != -1)
					tname = tname.get_slice(".", 0);
				for (int i = 0; i < Variant::VARIANT_MAX; i++) {
					if (tname == Variant::get_type_name(Variant::Type(i))) {
						type = Variant::Type(Variant::Type(i));
					}
				}

				if (type != Variant::NIL)
					property_select->select_property_from_basic_type(type, v);

				updating = false;
				return false;

			} else if (hint == PROPERTY_HINT_PROPERTY_OF_BASE_TYPE) {

				MAKE_PROPSELECT

				property_select->select_property_from_base_type(hint_text, v);

				updating = false;
				return false;

			} else if (hint == PROPERTY_HINT_PROPERTY_OF_INSTANCE) {

				MAKE_PROPSELECT

				Object *instance = ObjectDB::get_instance(hint_text.to_int64());
				if (instance)
					property_select->select_property_from_instance(instance, v);

				updating = false;
				return false;

			} else if (hint == PROPERTY_HINT_PROPERTY_OF_SCRIPT) {
				MAKE_PROPSELECT

				Object *obj = ObjectDB::get_instance(hint_text.to_int64());
				if (Object::cast_to<Script>(obj)) {
					property_select->select_property_from_script(Object::cast_to<Script>(obj), v);
				}

				updating = false;
				return false;

			} else {
				List<String> names;
				names.push_back("string:");
				config_value_editors(1, 1, 50, names);
				value_editor[0]->set_text(v);
			}

		} break;
		case Variant::VECTOR2: {

			field_names.push_back("x");
			field_names.push_back("y");
			config_value_editors(2, 2, 10, field_names);
			Vector2 vec = v;
			value_editor[0]->set_text(String::num(vec.x));
			value_editor[1]->set_text(String::num(vec.y));
		} break;
		case Variant::RECT2: {

			field_names.push_back("x");
			field_names.push_back("y");
			field_names.push_back("w");
			field_names.push_back("h");
			config_value_editors(4, 4, 10, field_names);
			Rect2 r = v;
			value_editor[0]->set_text(String::num(r.position.x));
			value_editor[1]->set_text(String::num(r.position.y));
			value_editor[2]->set_text(String::num(r.size.x));
			value_editor[3]->set_text(String::num(r.size.y));
		} break;
		case Variant::VECTOR3: {

			field_names.push_back("x");
			field_names.push_back("y");
			field_names.push_back("z");
			config_value_editors(3, 3, 10, field_names);
			Vector3 vec = v;
			value_editor[0]->set_text(String::num(vec.x));
			value_editor[1]->set_text(String::num(vec.y));
			value_editor[2]->set_text(String::num(vec.z));
		} break;
		case Variant::PLANE: {

			field_names.push_back("x");
			field_names.push_back("y");
			field_names.push_back("z");
			field_names.push_back("d");
			config_value_editors(4, 4, 10, field_names);
			Plane plane = v;
			value_editor[0]->set_text(String::num(plane.normal.x));
			value_editor[1]->set_text(String::num(plane.normal.y));
			value_editor[2]->set_text(String::num(plane.normal.z));
			value_editor[3]->set_text(String::num(plane.d));

		} break;
		case Variant::QUAT: {

			field_names.push_back("x");
			field_names.push_back("y");
			field_names.push_back("z");
			field_names.push_back("w");
			config_value_editors(4, 4, 10, field_names);
			Quat q = v;
			value_editor[0]->set_text(String::num(q.x));
			value_editor[1]->set_text(String::num(q.y));
			value_editor[2]->set_text(String::num(q.z));
			value_editor[3]->set_text(String::num(q.w));

		} break;
		case Variant::AABB: {

			field_names.push_back("px");
			field_names.push_back("py");
			field_names.push_back("pz");
			field_names.push_back("sx");
			field_names.push_back("sy");
			field_names.push_back("sz");
			config_value_editors(6, 3, 16, field_names);

			AABB aabb = v;
			value_editor[0]->set_text(String::num(aabb.position.x));
			value_editor[1]->set_text(String::num(aabb.position.y));
			value_editor[2]->set_text(String::num(aabb.position.z));
			value_editor[3]->set_text(String::num(aabb.size.x));
			value_editor[4]->set_text(String::num(aabb.size.y));
			value_editor[5]->set_text(String::num(aabb.size.z));

		} break;
		case Variant::TRANSFORM2D: {

			field_names.push_back("xx");
			field_names.push_back("xy");
			field_names.push_back("yx");
			field_names.push_back("yy");
			field_names.push_back("ox");
			field_names.push_back("oy");
			config_value_editors(6, 2, 16, field_names);

			Transform2D basis = v;
			for (int i = 0; i < 6; i++) {

				value_editor[i]->set_text(String::num(basis.elements[i / 2][i % 2]));
			}

		} break;
		case Variant::BASIS: {

			field_names.push_back("xx");
			field_names.push_back("xy");
			field_names.push_back("xz");
			field_names.push_back("yx");
			field_names.push_back("yy");
			field_names.push_back("yz");
			field_names.push_back("zx");
			field_names.push_back("zy");
			field_names.push_back("zz");
			config_value_editors(9, 3, 16, field_names);

			Basis basis = v;
			for (int i = 0; i < 9; i++) {

				value_editor[i]->set_text(String::num(basis.elements[i / 3][i % 3]));
			}

		} break;
		case Variant::TRANSFORM: {

			field_names.push_back("xx");
			field_names.push_back("xy");
			field_names.push_back("xz");
			field_names.push_back("xo");
			field_names.push_back("yx");
			field_names.push_back("yy");
			field_names.push_back("yz");
			field_names.push_back("yo");
			field_names.push_back("zx");
			field_names.push_back("zy");
			field_names.push_back("zz");
			field_names.push_back("zo");
			config_value_editors(12, 4, 16, field_names);

			Transform tr = v;
			for (int i = 0; i < 9; i++) {

				value_editor[(i / 3) * 4 + i % 3]->set_text(String::num(tr.basis.elements[i / 3][i % 3]));
			}

			value_editor[3]->set_text(String::num(tr.origin.x));
			value_editor[7]->set_text(String::num(tr.origin.y));
			value_editor[11]->set_text(String::num(tr.origin.z));

		} break;
		case Variant::COLOR: {

			if (!color_picker) {
				//late init for performance
				color_picker = memnew(ColorPicker);
				add_child(color_picker);
				color_picker->hide();
				color_picker->connect("color_changed", this, "_color_changed");
			}

			color_picker->show();
			color_picker->set_edit_alpha(hint != PROPERTY_HINT_COLOR_NO_ALPHA);
			color_picker->set_pick_color(v);
			color_picker->set_focus_on_line_edit();

		} break;

		case Variant::NODE_PATH: {

			List<String> names;
			names.push_back(TTR("Assign"));
			names.push_back(TTR("Clear"));

			if (owner && owner->is_class("Node") && (v.get_type() == Variant::NODE_PATH) && Object::cast_to<Node>(owner)->has_node(v))
				names.push_back(TTR("Select Node"));

			config_action_buttons(names);

		} break;
		case Variant::OBJECT: {

			if (hint != PROPERTY_HINT_RESOURCE_TYPE)
				break;

			if (p_name == "script" && hint_text == "Script" && Object::cast_to<Node>(owner)) {
				menu->add_icon_item(get_icon("Script", "EditorIcons"), TTR("New Script"), OBJ_MENU_NEW_SCRIPT);
				menu->add_separator();
			} else if (hint_text != "") {
				int idx = 0;

				for (int i = 0; i < hint_text.get_slice_count(","); i++) {

					String base = hint_text.get_slice(",", i);

					Set<String> valid_inheritors;
					valid_inheritors.insert(base);
					List<StringName> inheritors;
					ClassDB::get_inheriters_from_class(base.strip_edges(), &inheritors);
					List<StringName>::Element *E = inheritors.front();
					while (E) {
						valid_inheritors.insert(E->get());
						E = E->next();
					}

					for (Set<String>::Element *E = valid_inheritors.front(); E; E = E->next()) {
						String t = E->get();
						if (!ClassDB::can_instance(t))
							continue;
						inheritors_array.push_back(t);

						int id = TYPE_BASE_ID + idx;
						if (has_icon(t, "EditorIcons")) {

							menu->add_icon_item(get_icon(t, "EditorIcons"), vformat(TTR("New %s"), t), id);
						} else {

							menu->add_item(vformat(TTR("New %s"), t), id);
						}

						idx++;
					}
				}

				if (menu->get_item_count())
					menu->add_separator();
			}

			menu->add_icon_item(get_icon("Load", "EditorIcons"), TTR("Load"), OBJ_MENU_LOAD);

			if (!RES(v).is_null()) {

				menu->add_icon_item(get_icon("Edit", "EditorIcons"), TTR("Edit"), OBJ_MENU_EDIT);
				menu->add_icon_item(get_icon("Clear", "EditorIcons"), TTR("Clear"), OBJ_MENU_CLEAR);
				menu->add_icon_item(get_icon("Duplicate", "EditorIcons"), TTR("Make Unique"), OBJ_MENU_MAKE_UNIQUE);
				RES r = v;
				if (r.is_valid() && r->get_path().is_resource_file()) {
					menu->add_separator();
					menu->add_item(TTR("Show in File System"), OBJ_MENU_SHOW_IN_FILE_SYSTEM);
				}
			} else {
			}

			RES cb = EditorSettings::get_singleton()->get_resource_clipboard();
			bool paste_valid = false;
			if (cb.is_valid()) {
				if (hint_text == "")
					paste_valid = true;
				else
					for (int i = 0; i < hint_text.get_slice_count(","); i++)
						if (ClassDB::is_parent_class(cb->get_class(), hint_text.get_slice(",", i))) {
							paste_valid = true;
							break;
						}
			}

			if (!RES(v).is_null() || paste_valid) {
				menu->add_separator();

				if (!RES(v).is_null()) {

					menu->add_item(TTR("Copy"), OBJ_MENU_COPY);
				}

				if (paste_valid) {

					menu->add_item(TTR("Paste"), OBJ_MENU_PASTE);
				}
			}

			if (!RES(v).is_null()) {

				Vector<Ref<EditorResourceConversionPlugin> > conversions = EditorNode::get_singleton()->find_resource_conversion_plugin(RES(v));
				if (conversions.size()) {
					menu->add_separator();
				}
				for (int i = 0; i < conversions.size(); i++) {
					String what = conversions[i]->converts_to();
					Ref<Texture> icon;
					if (has_icon(what, "EditorIcons")) {

						icon = get_icon(what, "EditorIcons");
					} else {

						icon = get_icon(what, "Resource");
					}

					menu->add_icon_item(icon, vformat(TTR("Convert To %s"), what), CONVERT_BASE_ID + i);
				}
			}

			menu->set_position(get_position());
			menu->popup();
			hide();
			updating = false;
			return false;

		} break;
		case Variant::DICTIONARY: {

		} break;
		case Variant::POOL_BYTE_ARRAY: {

		} break;
		case Variant::POOL_INT_ARRAY: {

		} break;
		case Variant::POOL_REAL_ARRAY: {

		} break;
		case Variant::POOL_STRING_ARRAY: {

		} break;
		case Variant::POOL_VECTOR3_ARRAY: {

		} break;
		case Variant::POOL_COLOR_ARRAY: {

		} break;
		default: {}
	}

	updating = false;
	return true;
}

void CustomPropertyEditor::_file_selected(String p_file) {

	switch (type) {

		case Variant::STRING: {

			if (hint == PROPERTY_HINT_FILE || hint == PROPERTY_HINT_DIR) {

				v = ProjectSettings::get_singleton()->localize_path(p_file);
				emit_signal("variant_changed");
				hide();
			}

			if (hint == PROPERTY_HINT_GLOBAL_FILE || hint == PROPERTY_HINT_GLOBAL_DIR) {

				v = p_file;
				emit_signal("variant_changed");
				hide();
			}

		} break;
		case Variant::OBJECT: {

			String type = (hint == PROPERTY_HINT_RESOURCE_TYPE) ? hint_text : String();

			RES res = ResourceLoader::load(p_file, type);
			if (res.is_null()) {
				error->set_text(TTR("Error loading file: Not a resource!"));
				error->popup_centered_minsize();
				break;
			}
			v = res.get_ref_ptr();
			emit_signal("variant_changed");
			hide();
		} break;
		default: {}
	}
}

void CustomPropertyEditor::_type_create_selected(int p_idx) {

	if (type == Variant::INT || type == Variant::REAL) {

		float newval = 0;
		switch (p_idx) {

			case EASING_LINEAR: {

				newval = 1;
			} break;
			case EASING_EASE_IN: {

				newval = 2.0;
			} break;
			case EASING_EASE_OUT: {
				newval = 0.5;
			} break;
			case EASING_ZERO: {

				newval = 0;
			} break;
			case EASING_IN_OUT: {

				newval = -0.5;
			} break;
			case EASING_OUT_IN: {
				newval = -2.0;
			} break;
		}

		v = newval;
		emit_signal("variant_changed");
		easing_draw->update();

	} else if (type == Variant::OBJECT) {

		ERR_FAIL_INDEX(p_idx, inheritors_array.size());

		String intype = inheritors_array[p_idx];

		Object *obj = ClassDB::instance(intype);

		ERR_FAIL_COND(!obj);

		Resource *res = Object::cast_to<Resource>(obj);
		ERR_FAIL_COND(!res);

		v = Ref<Resource>(res).get_ref_ptr();
		emit_signal("variant_changed");
		hide();
	}
}

void CustomPropertyEditor::_color_changed(const Color &p_color) {

	v = p_color;
	emit_signal("variant_changed");
}

void CustomPropertyEditor::_node_path_selected(NodePath p_path) {

	if (picking_viewport) {

		Node *to_node = get_node(p_path);
		if (!Object::cast_to<Viewport>(to_node)) {
			EditorNode::get_singleton()->show_warning(TTR("Selected node is not a Viewport!"));
			return;
		}

		Ref<ViewportTexture> vt;
		vt.instance();
		vt->set_viewport_path_in_scene(get_tree()->get_edited_scene_root()->get_path_to(to_node));
		vt->setup_local_to_scene();
		v = vt;
		emit_signal("variant_changed");
		return;
	}

	if (hint == PROPERTY_HINT_NODE_PATH_TO_EDITED_NODE && hint_text != String()) {

		Node *node = get_node(hint_text);
		if (node) {

			Node *tonode = node->get_node(p_path);
			if (tonode) {
				p_path = node->get_path_to(tonode);
			}
		}

	} else if (owner) {

		Node *node = NULL;

		if (owner->is_class("Node"))
			node = Object::cast_to<Node>(owner);
		else if (owner->is_class("ArrayPropertyEdit"))
			node = Object::cast_to<ArrayPropertyEdit>(owner)->get_node();
		else if (owner->is_class("DictionaryPropertyEdit"))
			node = Object::cast_to<DictionaryPropertyEdit>(owner)->get_node();
		if (!node) {
			v = p_path;
			emit_signal("variant_changed");
			call_deferred("hide"); //to not mess with dialogs
			return;
		}

		Node *tonode = node->get_node(p_path);
		if (tonode) {
			p_path = node->get_path_to(tonode);
		}
	}

	v = p_path;
	emit_signal("variant_changed");
	call_deferred("hide"); //to not mess with dialogs
}

void CustomPropertyEditor::_action_pressed(int p_which) {

	if (updating)
		return;

	switch (type) {
		case Variant::BOOL: {
			v = checks20[0]->is_pressed();
			emit_signal("variant_changed");
		} break;
		case Variant::INT: {

			if (hint == PROPERTY_HINT_LAYERS_2D_PHYSICS || hint == PROPERTY_HINT_LAYERS_2D_RENDER || hint == PROPERTY_HINT_LAYERS_3D_PHYSICS || hint == PROPERTY_HINT_LAYERS_3D_RENDER) {

				uint32_t f = v;
				if (checks20[p_which]->is_pressed())
					f |= (1 << p_which);
				else
					f &= ~(1 << p_which);

				v = f;
				emit_signal("variant_changed");
			}

		} break;
		case Variant::STRING: {

			if (hint == PROPERTY_HINT_MULTILINE_TEXT) {

				hide();

			} else if (hint == PROPERTY_HINT_FILE || hint == PROPERTY_HINT_GLOBAL_FILE) {
				if (p_which == 0) {

					if (hint == PROPERTY_HINT_FILE)
						file->set_access(EditorFileDialog::ACCESS_RESOURCES);
					else
						file->set_access(EditorFileDialog::ACCESS_FILESYSTEM);

					file->set_mode(EditorFileDialog::MODE_OPEN_FILE);
					file->clear_filters();

					file->clear_filters();

					if (hint_text != "") {
						Vector<String> extensions = hint_text.split(",");
						for (int i = 0; i < extensions.size(); i++) {

							String filter = extensions[i];
							if (filter.begins_with("."))
								filter = "*" + extensions[i];
							else if (!filter.begins_with("*"))
								filter = "*." + extensions[i];

							file->add_filter(filter + " ; " + extensions[i].to_upper());
						}
					}
					file->popup_centered_ratio();
				} else {

					v = "";
					emit_signal("variant_changed");
					hide();
				}

			} else if (hint == PROPERTY_HINT_DIR || hint == PROPERTY_HINT_GLOBAL_DIR) {

				if (p_which == 0) {

					if (hint == PROPERTY_HINT_DIR)
						file->set_access(EditorFileDialog::ACCESS_RESOURCES);
					else
						file->set_access(EditorFileDialog::ACCESS_FILESYSTEM);
					file->set_mode(EditorFileDialog::MODE_OPEN_DIR);
					file->clear_filters();
					file->popup_centered_ratio();
				} else {

					v = "";
					emit_signal("variant_changed");
					hide();
				}
			}

		} break;
		case Variant::NODE_PATH: {

			if (p_which == 0) {

				picking_viewport = false;
				scene_tree->set_title(TTR("Pick a Node"));
				scene_tree->popup_centered_ratio();

			} else if (p_which == 1) {

				v = NodePath();
				emit_signal("variant_changed");
				hide();
			} else if (p_which == 2) {

				if (owner->is_class("Node") && (v.get_type() == Variant::NODE_PATH) && Object::cast_to<Node>(owner)->has_node(v)) {

					Node *target_node = Object::cast_to<Node>(owner)->get_node(v);
					EditorNode::get_singleton()->get_editor_selection()->clear();
					EditorNode::get_singleton()->get_scene_tree_dock()->set_selected(target_node);
				}

				hide();
			}

		} break;
		case Variant::OBJECT: {

			if (p_which == 0) {

				ERR_FAIL_COND(inheritors_array.empty());

				String intype = inheritors_array[0];

				if (hint == PROPERTY_HINT_RESOURCE_TYPE) {

					Object *obj = ClassDB::instance(intype);
					ERR_BREAK(!obj);
					Resource *res = Object::cast_to<Resource>(obj);
					ERR_BREAK(!res);

					v = Ref<Resource>(res).get_ref_ptr();
					emit_signal("variant_changed");
					hide();
				}
			} else if (p_which == 1) {

				file->set_access(EditorFileDialog::ACCESS_RESOURCES);
				file->set_mode(EditorFileDialog::MODE_OPEN_FILE);
				List<String> extensions;
				String type = (hint == PROPERTY_HINT_RESOURCE_TYPE) ? hint_text : String();

				ResourceLoader::get_recognized_extensions_for_type(type, &extensions);
				file->clear_filters();
				for (List<String>::Element *E = extensions.front(); E; E = E->next()) {

					file->add_filter("*." + E->get() + " ; " + E->get().to_upper());
				}

				file->popup_centered_ratio();

			} else if (p_which == 2) {

				RefPtr RefPtr = v;

				if (!RefPtr.is_null()) {

					emit_signal("resource_edit_request");
					hide();
				}

			} else if (p_which == 3) {

				v = Variant();
				emit_signal("variant_changed");
				hide();
			} else if (p_which == 4) {

				RefPtr RefPtr = v;
				Ref<Resource> res_orig = RefPtr;
				if (res_orig.is_null())
					return;

				List<PropertyInfo> property_list;
				res_orig->get_property_list(&property_list);
				List<Pair<String, Variant> > propvalues;

				for (List<PropertyInfo>::Element *E = property_list.front(); E; E = E->next()) {

					Pair<String, Variant> p;
					PropertyInfo &pi = E->get();
					if (pi.usage & PROPERTY_USAGE_STORAGE) {

						p.first = pi.name;
						p.second = res_orig->get(pi.name);
					}

					propvalues.push_back(p);
				}

				Ref<Resource> res = Ref<Resource>(ClassDB::instance(res_orig->get_class()));

				ERR_FAIL_COND(res.is_null());

				for (List<Pair<String, Variant> >::Element *E = propvalues.front(); E; E = E->next()) {

					Pair<String, Variant> &p = E->get();
					res->set(p.first, p.second);
				}

				v = res.get_ref_ptr();
				emit_signal("variant_changed");
				hide();
			}

		} break;

		default: {};
	}
}

void CustomPropertyEditor::_drag_easing(const Ref<InputEvent> &p_ev) {

	Ref<InputEventMouseMotion> mm = p_ev;

	if (mm.is_valid() && mm->get_button_mask() & BUTTON_MASK_LEFT) {

		float rel = mm->get_relative().x;
		if (rel == 0)
			return;

		bool flip = hint_text == "attenuation";

		if (flip)
			rel = -rel;

		float val = v;
		if (val == 0)
			return;
		bool sg = val < 0;
		val = Math::absf(val);

		val = Math::log(val) / Math::log((float)2.0);
		//logspace
		val += rel * 0.05;

		val = Math::pow(2.0f, val);
		if (sg)
			val = -val;

		v = val;
		easing_draw->update();
		emit_signal("variant_changed");
	}
}

void CustomPropertyEditor::_draw_easing() {

	RID ci = easing_draw->get_canvas_item();

	Size2 s = easing_draw->get_size();
	Rect2 r(Point2(), s);
	r = r.grow(3);
	get_stylebox("normal", "LineEdit")->draw(ci, r);

	int points = 48;

	float prev = 1.0;
	float exp = v;
	bool flip = hint_text == "attenuation";

	Ref<Font> f = get_font("font", "Label");
	Color color = get_color("font_color", "Label");

	for (int i = 1; i <= points; i++) {

		float ifl = i / float(points);
		float iflp = (i - 1) / float(points);

		float h = 1.0 - Math::ease(ifl, exp);

		if (flip) {
			ifl = 1.0 - ifl;
			iflp = 1.0 - iflp;
		}

		VisualServer::get_singleton()->canvas_item_add_line(ci, Point2(iflp * s.width, prev * s.height), Point2(ifl * s.width, h * s.height), color);
		prev = h;
	}

	f->draw(ci, Point2(10, 10 + f->get_ascent()), String::num(exp, 2), color);
}

void CustomPropertyEditor::_text_edit_changed() {

	v = text_edit->get_text();
	emit_signal("variant_changed");
}

void CustomPropertyEditor::_create_dialog_callback() {

	v = create_dialog->get_selected_type();
	emit_signal("variant_changed");
}

void CustomPropertyEditor::_create_selected_property(const String &p_prop) {

	v = p_prop;
	emit_signal("variant_changed");
}

void CustomPropertyEditor::_modified(String p_string) {

	if (updating)
		return;

	updating = true;
	switch (type) {
		case Variant::INT: {

			if (evaluator)
				v = evaluator->eval(value_editor[0]->get_text());
			else
				v = value_editor[0]->get_text().to_int();
			emit_signal("variant_changed");

		} break;
		case Variant::REAL: {

			if (hint != PROPERTY_HINT_EXP_EASING) {
				if (evaluator)
					v = evaluator->eval(value_editor[0]->get_text());
				else
					v = value_editor[0]->get_text().to_double();
				emit_signal("variant_changed");
			}

		} break;
		case Variant::STRING: {

			v = value_editor[0]->get_text();
			emit_signal("variant_changed");
		} break;
		case Variant::VECTOR2: {

			Vector2 vec;
			if (evaluator) {
				vec.x = evaluator->eval(value_editor[0]->get_text());
				vec.y = evaluator->eval(value_editor[1]->get_text());
			} else {
				vec.x = value_editor[0]->get_text().to_double();
				vec.y = value_editor[1]->get_text().to_double();
			}
			v = vec;
			_emit_changed_whole_or_field();

		} break;
		case Variant::RECT2: {

			Rect2 r2;
			if (evaluator) {
				r2.position.x = evaluator->eval(value_editor[0]->get_text());
				r2.position.y = evaluator->eval(value_editor[1]->get_text());
				r2.size.x = evaluator->eval(value_editor[2]->get_text());
				r2.size.y = evaluator->eval(value_editor[3]->get_text());
			} else {
				r2.position.x = value_editor[0]->get_text().to_double();
				r2.position.y = value_editor[1]->get_text().to_double();
				r2.size.x = value_editor[2]->get_text().to_double();
				r2.size.y = value_editor[3]->get_text().to_double();
			}
			v = r2;
			_emit_changed_whole_or_field();

		} break;

		case Variant::VECTOR3: {

			Vector3 vec;
			if (evaluator) {
				vec.x = evaluator->eval(value_editor[0]->get_text());
				vec.y = evaluator->eval(value_editor[1]->get_text());
				vec.z = evaluator->eval(value_editor[2]->get_text());
			} else {
				vec.x = value_editor[0]->get_text().to_double();
				vec.y = value_editor[1]->get_text().to_double();
				vec.z = value_editor[2]->get_text().to_double();
			}
			v = vec;
			_emit_changed_whole_or_field();

		} break;
		case Variant::PLANE: {

			Plane pl;
			if (evaluator) {
				pl.normal.x = evaluator->eval(value_editor[0]->get_text());
				pl.normal.y = evaluator->eval(value_editor[1]->get_text());
				pl.normal.z = evaluator->eval(value_editor[2]->get_text());
				pl.d = evaluator->eval(value_editor[3]->get_text());
			} else {
				pl.normal.x = value_editor[0]->get_text().to_double();
				pl.normal.y = value_editor[1]->get_text().to_double();
				pl.normal.z = value_editor[2]->get_text().to_double();
				pl.d = value_editor[3]->get_text().to_double();
			}
			v = pl;
			_emit_changed_whole_or_field();

		} break;
		case Variant::QUAT: {

			Quat q;
			if (evaluator) {
				q.x = evaluator->eval(value_editor[0]->get_text());
				q.y = evaluator->eval(value_editor[1]->get_text());
				q.z = evaluator->eval(value_editor[2]->get_text());
				q.w = evaluator->eval(value_editor[3]->get_text());
			} else {
				q.x = value_editor[0]->get_text().to_double();
				q.y = value_editor[1]->get_text().to_double();
				q.z = value_editor[2]->get_text().to_double();
				q.w = value_editor[3]->get_text().to_double();
			}
			v = q;
			_emit_changed_whole_or_field();

		} break;
		case Variant::AABB: {

			Vector3 pos;
			Vector3 size;

			if (evaluator) {
				pos.x = evaluator->eval(value_editor[0]->get_text());
				pos.y = evaluator->eval(value_editor[1]->get_text());
				pos.z = evaluator->eval(value_editor[2]->get_text());
				size.x = evaluator->eval(value_editor[3]->get_text());
				size.y = evaluator->eval(value_editor[4]->get_text());
				size.z = evaluator->eval(value_editor[5]->get_text());
			} else {
				pos.x = value_editor[0]->get_text().to_double();
				pos.y = value_editor[1]->get_text().to_double();
				pos.z = value_editor[2]->get_text().to_double();
				size.x = value_editor[3]->get_text().to_double();
				size.y = value_editor[4]->get_text().to_double();
				size.z = value_editor[5]->get_text().to_double();
			}
			v = AABB(pos, size);
			_emit_changed_whole_or_field();

		} break;
		case Variant::TRANSFORM2D: {

			Transform2D m;
			for (int i = 0; i < 6; i++) {
				if (evaluator) {
					m.elements[i / 2][i % 2] = evaluator->eval(value_editor[i]->get_text());
				} else {
					m.elements[i / 2][i % 2] = value_editor[i]->get_text().to_double();
				}
			}

			v = m;
			_emit_changed_whole_or_field();

		} break;
		case Variant::BASIS: {

			Basis m;
			for (int i = 0; i < 9; i++) {

				if (evaluator) {
					m.elements[i / 3][i % 3] = evaluator->eval(value_editor[i]->get_text());
				} else {
					m.elements[i / 3][i % 3] = value_editor[i]->get_text().to_double();
				}
			}

			v = m;
			_emit_changed_whole_or_field();

		} break;
		case Variant::TRANSFORM: {

			Basis basis;
			for (int i = 0; i < 9; i++) {

				if (evaluator) {
					basis.elements[i / 3][i % 3] = evaluator->eval(value_editor[(i / 3) * 4 + i % 3]->get_text());
				} else {
					basis.elements[i / 3][i % 3] = value_editor[(i / 3) * 4 + i % 3]->get_text().to_double();
				}
			}

			Vector3 origin;

			if (evaluator) {
				origin.x = evaluator->eval(value_editor[3]->get_text());
				origin.y = evaluator->eval(value_editor[7]->get_text());
				origin.z = evaluator->eval(value_editor[11]->get_text());
			} else {
				origin.x = value_editor[3]->get_text().to_double();
				origin.y = value_editor[7]->get_text().to_double();
				origin.z = value_editor[11]->get_text().to_double();
			}

			v = Transform(basis, origin);
			_emit_changed_whole_or_field();

		} break;
		case Variant::COLOR: {

		} break;

		case Variant::NODE_PATH: {

			v = NodePath(value_editor[0]->get_text());
			emit_signal("variant_changed");
		} break;
		case Variant::DICTIONARY: {

		} break;
		case Variant::POOL_BYTE_ARRAY: {

		} break;
		case Variant::POOL_INT_ARRAY: {

		} break;
		case Variant::POOL_REAL_ARRAY: {

		} break;
		case Variant::POOL_STRING_ARRAY: {

		} break;
		case Variant::POOL_VECTOR3_ARRAY: {

		} break;
		case Variant::POOL_COLOR_ARRAY: {

		} break;
		default: {}
	}

	updating = false;
}

void CustomPropertyEditor::_emit_changed_whole_or_field() {

	if (!Input::get_singleton()->is_key_pressed(KEY_SHIFT)) {
		emit_signal("variant_changed");
	} else {
		emit_signal("variant_field_changed", field_names[focused_value_editor]);
	}
}

void CustomPropertyEditor::_range_modified(double p_value) {
	v = p_value;
	emit_signal("variant_changed");
}

void CustomPropertyEditor::_focus_enter() {
	switch (type) {
		case Variant::REAL:
		case Variant::STRING:
		case Variant::VECTOR2:
		case Variant::RECT2:
		case Variant::VECTOR3:
		case Variant::PLANE:
		case Variant::QUAT:
		case Variant::AABB:
		case Variant::TRANSFORM2D:
		case Variant::BASIS:
		case Variant::TRANSFORM: {
			for (int i = 0; i < MAX_VALUE_EDITORS; ++i) {
				if (value_editor[i]->has_focus()) {
					focused_value_editor = i;
					value_editor[i]->select_all();
					break;
				}
			}
		} break;
		default: {}
	}
}

void CustomPropertyEditor::_focus_exit() {
	switch (type) {
		case Variant::REAL:
		case Variant::STRING:
		case Variant::VECTOR2:
		case Variant::RECT2:
		case Variant::VECTOR3:
		case Variant::PLANE:
		case Variant::QUAT:
		case Variant::AABB:
		case Variant::TRANSFORM2D:
		case Variant::BASIS:
		case Variant::TRANSFORM: {
			for (int i = 0; i < MAX_VALUE_EDITORS; ++i) {
				value_editor[i]->select(0, 0);
			}
		} break;
		default: {}
	}
}

void CustomPropertyEditor::config_action_buttons(const List<String> &p_strings) {

	Ref<StyleBox> sb = get_stylebox("panel");
	int margin_top = sb->get_margin(MARGIN_TOP);
	int margin_left = sb->get_margin(MARGIN_LEFT);
	int margin_bottom = sb->get_margin(MARGIN_BOTTOM);
	int margin_right = sb->get_margin(MARGIN_RIGHT);

	int max_width = 0;
	int height = 0;

	for (int i = 0; i < MAX_ACTION_BUTTONS; i++) {

		if (i < p_strings.size()) {

			action_buttons[i]->show();
			action_buttons[i]->set_text(p_strings[i]);

			Size2 btn_m_size = action_buttons[i]->get_minimum_size();
			if (btn_m_size.width > max_width)
				max_width = btn_m_size.width;

		} else {
			action_buttons[i]->hide();
		}
	}

	for (int i = 0; i < p_strings.size(); i++) {

		Size2 btn_m_size = action_buttons[i]->get_size();
		action_buttons[i]->set_position(Point2(0, height) + Point2(margin_left, margin_top));
		action_buttons[i]->set_size(Size2(max_width, btn_m_size.height));

		height += btn_m_size.height;
	}
	set_size(Size2(max_width, height) + Size2(margin_left + margin_right, margin_top + margin_bottom));
}

void CustomPropertyEditor::config_value_editors(int p_amount, int p_columns, int p_label_w, const List<String> &p_strings) {

	int cell_width = 95;
	int cell_height = 25;
	int cell_margin = 5;
	int hor_spacing = 5; // Spacing between labels and their values

	int rows = ((p_amount - 1) / p_columns) + 1;

	set_size(Size2(cell_margin + p_label_w + (cell_width + cell_margin + p_label_w) * p_columns, cell_margin + (cell_height + cell_margin) * rows) * EDSCALE);

	for (int i = 0; i < MAX_VALUE_EDITORS; i++) {

		int c = i % p_columns;
		int r = i / p_columns;

		if (i < p_amount) {
			value_editor[i]->show();
			value_label[i]->show();
			value_label[i]->set_text(i < p_strings.size() ? p_strings[i] : String(""));
			value_editor[i]->set_position(Point2(cell_margin + p_label_w + hor_spacing + (cell_width + cell_margin + p_label_w + hor_spacing) * c, cell_margin + (cell_height + cell_margin) * r) * EDSCALE);
			value_editor[i]->set_size(Size2(cell_width, cell_height));
			value_label[i]->set_position(Point2(cell_margin + (cell_width + cell_margin + p_label_w + hor_spacing) * c, cell_margin + (cell_height + cell_margin) * r) * EDSCALE);
			value_editor[i]->set_editable(!read_only);
		} else {
			value_editor[i]->hide();
			value_label[i]->hide();
		}
	}
}

void CustomPropertyEditor::_bind_methods() {

	ClassDB::bind_method("_focus_enter", &CustomPropertyEditor::_focus_enter);
	ClassDB::bind_method("_focus_exit", &CustomPropertyEditor::_focus_exit);
	ClassDB::bind_method("_modified", &CustomPropertyEditor::_modified);
	ClassDB::bind_method("_range_modified", &CustomPropertyEditor::_range_modified);
	ClassDB::bind_method("_action_pressed", &CustomPropertyEditor::_action_pressed);
	ClassDB::bind_method("_file_selected", &CustomPropertyEditor::_file_selected);
	ClassDB::bind_method("_type_create_selected", &CustomPropertyEditor::_type_create_selected);
	ClassDB::bind_method("_node_path_selected", &CustomPropertyEditor::_node_path_selected);
	ClassDB::bind_method("_color_changed", &CustomPropertyEditor::_color_changed);
	ClassDB::bind_method("_draw_easing", &CustomPropertyEditor::_draw_easing);
	ClassDB::bind_method("_drag_easing", &CustomPropertyEditor::_drag_easing);
	ClassDB::bind_method("_text_edit_changed", &CustomPropertyEditor::_text_edit_changed);
	ClassDB::bind_method("_menu_option", &CustomPropertyEditor::_menu_option);
	ClassDB::bind_method("_create_dialog_callback", &CustomPropertyEditor::_create_dialog_callback);
	ClassDB::bind_method("_create_selected_property", &CustomPropertyEditor::_create_selected_property);

	ADD_SIGNAL(MethodInfo("variant_changed"));
	ADD_SIGNAL(MethodInfo("variant_field_changed", PropertyInfo(Variant::STRING, "field")));
	ADD_SIGNAL(MethodInfo("resource_edit_request"));
}
CustomPropertyEditor::CustomPropertyEditor() {

	read_only = false;
	updating = false;

	for (int i = 0; i < MAX_VALUE_EDITORS; i++) {

		value_editor[i] = memnew(LineEdit);
		add_child(value_editor[i]);
		value_label[i] = memnew(Label);
		add_child(value_label[i]);
		value_editor[i]->hide();
		value_label[i]->hide();
		value_editor[i]->connect("text_entered", this, "_modified");
		value_editor[i]->connect("focus_entered", this, "_focus_enter");
		value_editor[i]->connect("focus_exited", this, "_focus_exit");
	}
	focused_value_editor = -1;

	for (int i = 0; i < 4; i++) {

		scroll[i] = memnew(HScrollBar);
		scroll[i]->hide();
		scroll[i]->set_min(0);
		scroll[i]->set_max(1.0);
		scroll[i]->set_step(0.01);
		add_child(scroll[i]);
	}

	checks20gc = memnew(GridContainer);
	add_child(checks20gc);
	checks20gc->set_columns(11);

	for (int i = 0; i < 20; i++) {
		if (i == 5 || i == 15) {
			Control *space = memnew(Control);
			space->set_custom_minimum_size(Size2(20, 0) * EDSCALE);
			checks20gc->add_child(space);
		}

		checks20[i] = memnew(CheckBox);
		checks20[i]->set_toggle_mode(true);
		checks20[i]->set_focus_mode(FOCUS_NONE);
		checks20gc->add_child(checks20[i]);
		checks20[i]->hide();
		checks20[i]->connect("pressed", this, "_action_pressed", make_binds(i));
		checks20[i]->set_tooltip(vformat(TTR("Bit %d, val %d."), i, 1 << i));
	}

	text_edit = memnew(TextEdit);
	add_child(text_edit);
	text_edit->set_anchors_and_margins_preset(Control::PRESET_WIDE, Control::PRESET_MODE_MINSIZE, 5);
	text_edit->set_margin(MARGIN_BOTTOM, -30);

	text_edit->hide();
	text_edit->connect("text_changed", this, "_text_edit_changed");

	for (int i = 0; i < MAX_ACTION_BUTTONS; i++) {

		action_buttons[i] = memnew(Button);
		action_buttons[i]->hide();
		add_child(action_buttons[i]);
		Vector<Variant> binds;
		binds.push_back(i);
		action_buttons[i]->connect("pressed", this, "_action_pressed", binds);
		action_buttons[i]->set_flat(true);
	}

	color_picker = NULL;

	set_as_toplevel(true);
	file = memnew(EditorFileDialog);
	add_child(file);
	file->hide();

	file->connect("file_selected", this, "_file_selected");
	file->connect("dir_selected", this, "_file_selected");

	error = memnew(ConfirmationDialog);
	error->set_title(TTR("Error!"));
	add_child(error);

	scene_tree = memnew(SceneTreeDialog);
	add_child(scene_tree);
	scene_tree->connect("selected", this, "_node_path_selected");
	scene_tree->get_scene_tree()->set_show_enabled_subscene(true);

	texture_preview = memnew(TextureRect);
	add_child(texture_preview);
	texture_preview->hide();

	easing_draw = memnew(Control);
	add_child(easing_draw);
	easing_draw->hide();
	easing_draw->connect("draw", this, "_draw_easing");
	easing_draw->connect("gui_input", this, "_drag_easing");
	easing_draw->set_default_cursor_shape(Control::CURSOR_MOVE);

	type_button = memnew(MenuButton);
	add_child(type_button);
	type_button->hide();
	type_button->get_popup()->connect("id_pressed", this, "_type_create_selected");

	menu = memnew(PopupMenu);
	menu->set_pass_on_modal_close_click(false);
	add_child(menu);
	menu->connect("id_pressed", this, "_menu_option");

	evaluator = NULL;

	spinbox = memnew(SpinBox);
	add_child(spinbox);
	spinbox->set_anchors_and_margins_preset(Control::PRESET_WIDE, Control::PRESET_MODE_MINSIZE, 5);
	spinbox->connect("value_changed", this, "_range_modified");

	slider = memnew(HSlider);
	add_child(slider);
	slider->set_anchors_and_margins_preset(Control::PRESET_WIDE, Control::PRESET_MODE_MINSIZE, 5);
	slider->connect("value_changed", this, "_range_modified");

	create_dialog = NULL;
	property_select = NULL;
}

bool PropertyEditor::_might_be_in_instance() {

	if (!obj)
		return false;

	Node *node = Object::cast_to<Node>(obj);

	Node *edited_scene = EditorNode::get_singleton()->get_edited_scene();

	bool might_be = false;

	while (node) {

		if (node->get_scene_instance_state().is_valid()) {
			might_be = true;
			break;
		}
		if (node == edited_scene) {
			if (node->get_scene_inherited_state().is_valid()) {
				might_be = true;
				break;
			}
			might_be = false;
			break;
		}
		node = node->get_owner();
	}

	return might_be;
}

bool PropertyEditor::_get_instanced_node_original_property(const StringName &p_prop, Variant &value) {

	Node *node = Object::cast_to<Node>(obj);

	if (!node)
		return false;

	Node *orig = node;

	Node *edited_scene = EditorNode::get_singleton()->get_edited_scene();

	bool found = false;

	while (node) {

		Ref<SceneState> ss;

		if (node == edited_scene) {
			ss = node->get_scene_inherited_state();

		} else {
			ss = node->get_scene_instance_state();
		}

		if (ss.is_valid()) {

			NodePath np = node->get_path_to(orig);
			int node_idx = ss->find_node_by_path(np);
			if (node_idx >= 0) {
				bool lfound = false;
				Variant lvar;
				lvar = ss->get_property_value(node_idx, p_prop, lfound);
				if (lfound) {

					found = true;
					value = lvar;
				}
			}
		}
		if (node == edited_scene) {
			//just in case
			break;
		}
		node = node->get_owner();
	}

	return found;
}

bool PropertyEditor::_is_property_different(const Variant &p_current, const Variant &p_orig, int p_usage) {

	{
		Node *node = Object::cast_to<Node>(obj);
		if (!node)
			return false;

		Node *edited_scene = EditorNode::get_singleton()->get_edited_scene();
		bool found_state = false;

		while (node) {

			Ref<SceneState> ss;

			if (node == edited_scene) {
				ss = node->get_scene_inherited_state();

			} else {
				ss = node->get_scene_instance_state();
			}

			if (ss.is_valid()) {
				found_state = true;
			}
			if (node == edited_scene) {
				//just in case
				break;
			}
			node = node->get_owner();
		}

		if (!found_state)
			return false; //pointless to check if we are not comparing against anything.
	}

	if (p_orig.get_type() == Variant::NIL) {

		//special cases
		if (p_current.is_zero() && p_usage & PROPERTY_USAGE_STORE_IF_NONZERO)
			return false;
		if (p_current.is_one() && p_usage & PROPERTY_USAGE_STORE_IF_NONONE)
			return false;
	}

	if (p_current.get_type() == Variant::REAL && p_orig.get_type() == Variant::REAL) {
		float a = p_current;
		float b = p_orig;

		return Math::abs(a - b) > CMP_EPSILON; //this must be done because, as some scenes save as text, there might be a tiny difference in floats due to numerical error
	}

	return bool(Variant::evaluate(Variant::OP_NOT_EQUAL, p_current, p_orig));
}

bool PropertyEditor::_is_instanced_node_with_original_property_different(const String &p_name, TreeItem *item) {
	bool mbi = _might_be_in_instance();
	if (mbi) {
		Variant vorig;
		Dictionary d = item->get_metadata(0);
		int usage = d.has("usage") ? int(int(d["usage"]) & (PROPERTY_USAGE_STORE_IF_NONONE | PROPERTY_USAGE_STORE_IF_NONZERO)) : 0;
		if (_get_instanced_node_original_property(p_name, vorig) || usage) {
			Variant v = obj->get(p_name);

			if (_is_property_different(v, vorig, usage)) {
				return true;
			}
		}
	}
	return false;
}

TreeItem *PropertyEditor::find_item(TreeItem *p_item, const String &p_name) {

	if (!p_item)
		return NULL;

	String name = p_item->get_metadata(1);

	if (name == p_name) {

		return p_item;
	}

	TreeItem *c = p_item->get_children();

	while (c) {

		TreeItem *found = find_item(c, p_name);
		if (found)
			return found;
		c = c->get_next();
	}

	return NULL;
}

void PropertyEditor::_changed_callback(Object *p_changed, const char *p_prop) {

	_changed_callbacks(p_changed, p_prop);
}

void PropertyEditor::_changed_callbacks(Object *p_changed, const String &p_prop) {

	if (p_changed != obj)
		return;

	if (changing)
		return;

	if (p_prop == String())
		update_tree_pending = true;
	else {

		pending[p_prop] = p_prop;
	}
}

void PropertyEditor::update_property(const String &p_prop) {

	if (obj)
		_changed_callbacks(obj, p_prop);
}

void PropertyEditor::set_item_text(TreeItem *p_item, int p_type, const String &p_name, int p_hint, const String &p_hint_text) {

	switch (p_type) {

		case Variant::BOOL: {

			p_item->set_checked(1, obj->get(p_name));
		} break;
		case Variant::REAL:
		case Variant::INT: {

			if (p_hint == PROPERTY_HINT_LAYERS_2D_PHYSICS || p_hint == PROPERTY_HINT_LAYERS_2D_RENDER || p_hint == PROPERTY_HINT_LAYERS_3D_PHYSICS || p_hint == PROPERTY_HINT_LAYERS_3D_RENDER) {
				tree->update();
				break;
			}

			if (p_hint == PROPERTY_HINT_FLAGS) {
				Vector<String> values = p_hint_text.split(",");
				String flags;
				int val = obj->get(p_name);
				for (int i = 0; i < values.size(); i++) {

					String v = values[i];
					if (v == "")
						continue;
					if (!(val & (1 << i)))
						continue;

					if (flags != "")
						flags += ", ";
					flags += v;
				}
				p_item->set_text(1, flags);
				break;
			}

			if (p_hint == PROPERTY_HINT_EXP_EASING) {

				p_item->set_text(1, String::num(obj->get(p_name), 2));
				break;
			}

			if (p_type == Variant::REAL) {
				p_item->set_range(1, obj->get(p_name));

			} else {
				/* FIXME: Why are both statements equal? */
				p_item->set_range(1, obj->get(p_name));
			}

			p_item->set_editable(1, !read_only);

		} break;
		case Variant::STRING:

			if (p_hint == PROPERTY_HINT_TYPE_STRING) {

				p_item->set_text(1, obj->get(p_name));
			}

			if (p_hint == PROPERTY_HINT_METHOD_OF_VARIANT_TYPE ||
					p_hint == PROPERTY_HINT_METHOD_OF_BASE_TYPE ||
					p_hint == PROPERTY_HINT_METHOD_OF_INSTANCE ||
					p_hint == PROPERTY_HINT_METHOD_OF_SCRIPT ||
					p_hint == PROPERTY_HINT_PROPERTY_OF_VARIANT_TYPE ||
					p_hint == PROPERTY_HINT_PROPERTY_OF_BASE_TYPE ||
					p_hint == PROPERTY_HINT_PROPERTY_OF_INSTANCE ||
					p_hint == PROPERTY_HINT_PROPERTY_OF_SCRIPT) {

				p_item->set_text(1, obj->get(p_name));
			}

			if (p_hint == PROPERTY_HINT_ENUM) {

				Vector<String> strings = p_hint_text.split(",");
				String current = obj->get(p_name);
				int idx = 0;
				for (int x = 0; x < strings.size(); x++) {
					if (strings[x] == current) {
						idx = x;
						break;
					}
				}
				p_item->set_text(1, p_hint_text);
				p_item->set_range(1, idx);
				break;
			}

		case Variant::VECTOR3:
		case Variant::QUAT:
		case Variant::VECTOR2:
		case Variant::AABB:
		case Variant::RECT2:
		case Variant::TRANSFORM2D:
		case Variant::BASIS:
		case Variant::TRANSFORM: {

			p_item->set_text(1, obj->get(p_name));

		} break;
		case Variant::COLOR: {

			tree->update();

		} break;
		case Variant::NODE_PATH: {

			p_item->set_text(1, obj->get(p_name));
		} break;
		case Variant::OBJECT: {

			Ref<EncodedObjectAsID> encoded = obj->get(p_name); //for debugger and remote tools

			if (encoded.is_valid()) {

				p_item->set_text(1, "Object: " + itos(encoded->get_object_id()));
				p_item->set_icon(1, Ref<Texture>());
				p_item->set_custom_as_button(1, true);

			} else if (obj->get(p_name).get_type() == Variant::NIL || obj->get(p_name).operator RefPtr().is_null()) {
				p_item->set_text(1, "<null>");
				p_item->set_icon(1, Ref<Texture>());
				p_item->set_custom_as_button(1, false);

				Dictionary d = p_item->get_metadata(0);
				int hint = d.has("hint") ? d["hint"].operator int() : -1;
				String hint_text = d.has("hint_text") ? d["hint_text"] : "";
				if (hint == PROPERTY_HINT_RESOURCE_TYPE && hint_text == "Texture") {
					p_item->set_icon(1, NULL);
				}

			} else {
				p_item->set_custom_as_button(1, true);
				RES res = obj->get(p_name).operator RefPtr();
				if (res->is_class("Texture")) {
					int tw = EditorSettings::get_singleton()->get("docks/property_editor/texture_preview_width");
					Vector2 size(res->call("get_width"), res->call("get_height"));
					if (size.width < size.height) {
						tw = MAX((size.width / size.height) * tw, 1);
					}
					p_item->set_icon_max_width(1, tw);
					p_item->set_icon(1, res);
					p_item->set_text(1, "");

				} else if (res->get_name() != "") {

					p_item->set_text(1, res->get_name());
				} else if (res->get_path() != "" && !res->get_path().begins_with("local://")) {
					p_item->set_text(1, res->get_path().get_file());
				} else {
					p_item->set_text(1, "<" + res->get_class() + ">");
				};

				if (res.is_valid() && res->get_path().is_resource_file()) {
					p_item->set_tooltip(1, res->get_path());
				} else if (res.is_valid()) {
					p_item->set_tooltip(1, res->get_name() + " (" + res->get_class() + ")");
				}

				if (has_icon(res->get_class(), "EditorIcons")) {

					p_item->set_icon(0, get_icon(res->get_class(), "EditorIcons"));
				} else {

					Dictionary d = p_item->get_metadata(0);
					int hint = d.has("hint") ? d["hint"].operator int() : -1;
					String hint_text = d.has("hint_text") ? d["hint_text"] : "";
					if (hint == PROPERTY_HINT_RESOURCE_TYPE) {

						if (has_icon(hint_text, "EditorIcons")) {

							p_item->set_icon(0, get_icon(hint_text, "EditorIcons"));

						} else {
							p_item->set_icon(0, get_icon("Object", "EditorIcons"));
						}
					}
				}

				if (res->is_class("Script")) {
					p_item->set_text(1, res->get_path().get_file());
				} else if (!res->is_class("Texture")) {
					//texture already previews via itself
					EditorResourcePreview::get_singleton()->queue_edited_resource_preview(res, this, "_resource_preview_done", p_item->get_instance_id());
				}
			}

		} break;
		default: {};
	}
}

void PropertyEditor::_check_reload_status(const String &p_name, TreeItem *item) {

	bool has_reload = false;
	int found = -1;
	bool is_disabled = false;

	for (int i = 0; i < item->get_button_count(1); i++) {

		if (item->get_button_id(1, i) == 3) {
			found = i;
			is_disabled = item->is_button_disabled(1, i);
			break;
		}
	}

	if (_is_instanced_node_with_original_property_different(p_name, item)) {
		has_reload = true;
	}

	if (obj->call("property_can_revert", p_name).operator bool()) {

		has_reload = true;
	}

	if (!has_reload && !obj->get_script().is_null()) {
		Ref<Script> scr = obj->get_script();
		Variant orig_value;
		if (scr->get_property_default_value(p_name, orig_value)) {
			if (orig_value != obj->get(p_name)) {
				has_reload = true;
			}
		}
	}

	if (found != -1 && !has_reload) {

		if (!is_disabled) {
			item->erase_button(1, found);
			if (item->get_cell_mode(1) == TreeItem::CELL_MODE_RANGE && item->get_text(1) == String()) {
				item->add_button(1, get_icon("ReloadEmpty", "EditorIcons"), 3, true);
			}
		}
	} else if (found == -1 && has_reload) {
		item->add_button(1, get_icon("ReloadSmall", "EditorIcons"), 3);
	} else if (found != -1 && has_reload && is_disabled) {
		item->erase_button(1, found);
		item->add_button(1, get_icon("ReloadSmall", "EditorIcons"), 3);
	}
}

bool PropertyEditor::_is_drop_valid(const Dictionary &p_drag_data, const Dictionary &p_item_data) const {

	Dictionary d = p_item_data;

	if (d.has("type")) {

		int type = d["type"];
		if (type == Variant::OBJECT && d.has("hint") && d.has("hint_text") && int(d["hint"]) == PROPERTY_HINT_RESOURCE_TYPE) {

			String allowed_type = d["hint_text"];

			Dictionary drag_data = p_drag_data;
			if (drag_data.has("type") && String(drag_data["type"]) == "resource") {
				Ref<Resource> res = drag_data["resource"];
				for (int i = 0; i < allowed_type.get_slice_count(","); i++) {
					String at = allowed_type.get_slice(",", i).strip_edges();
					if (res.is_valid() && ClassDB::is_parent_class(res->get_class(), at)) {
						return true;
					}
				}
			}

			if (drag_data.has("type") && String(drag_data["type"]) == "files") {

				Vector<String> files = drag_data["files"];

				if (files.size() == 1) {
					String file = files[0];
					String ftype = EditorFileSystem::get_singleton()->get_file_type(file);

					if (ftype != "") {

						for (int i = 0; i < allowed_type.get_slice_count(","); i++) {
							String at = allowed_type.get_slice(",", i).strip_edges();
							if (ClassDB::is_parent_class(ftype, at)) {
								return true;
							}
						}
					}
				}
			}
		}
	}

	return false;
}
void PropertyEditor::_mark_drop_fields(TreeItem *p_at) {

	if (_is_drop_valid(get_viewport()->gui_get_drag_data(), p_at->get_metadata(0)))
		p_at->set_custom_bg_color(1, get_color("accent_color", "Editor"), true);

	if (p_at->get_children()) {
		_mark_drop_fields(p_at->get_children());
	}

	if (p_at->get_next()) {
		_mark_drop_fields(p_at->get_next());
	}
}

Variant PropertyEditor::get_drag_data_fw(const Point2 &p_point, Control *p_from) {

	TreeItem *item = tree->get_item_at_position(p_point);
	if (!item)
		return Variant();

	Dictionary d = item->get_metadata(0);
	if (!d.has("name"))
		return Variant();

	int col = tree->get_column_at_position(p_point);
	if (col == 0) {

		Dictionary dp;
		dp["type"] = "obj_property";
		dp["object"] = obj;
		dp["property"] = d["name"];
		dp["value"] = obj->get(d["name"]);

		Label *label = memnew(Label);
		label->set_text(d["name"]);
		set_drag_preview(label);
		return dp;
	}

	Variant val = obj->get(d["name"]);

	if (val.get_type() == Variant::OBJECT) {
		RES res = val;
		if (res.is_valid()) {

			custom_editor->hide_menu();
			return EditorNode::get_singleton()->drag_resource(res, p_from);
		}
	}

	return Variant();
}

bool PropertyEditor::can_drop_data_fw(const Point2 &p_point, const Variant &p_data, Control *p_from) const {

	TreeItem *item = tree->get_item_at_position(p_point);
	if (!item)
		return false;

	int col = tree->get_column_at_position(p_point);
	if (col != 1)
		return false;

	return _is_drop_valid(p_data, item->get_metadata(0));
}
void PropertyEditor::drop_data_fw(const Point2 &p_point, const Variant &p_data, Control *p_from) {

	TreeItem *item = tree->get_item_at_position(p_point);
	if (!item)
		return;

	int col = tree->get_column_at_position(p_point);
	if (col != 1)
		return;

	if (!_is_drop_valid(p_data, item->get_metadata(0)))
		return;

	Dictionary d = item->get_metadata(0);

	if (!d.has("name"))
		return;

	String name = d["name"];

	Dictionary drag_data = p_data;
	if (drag_data.has("type") && String(drag_data["type"]) == "resource") {
		Ref<Resource> res = drag_data["resource"];
		if (res.is_valid()) {
			_edit_set(name, res);
			return;
		}
	}

	if (drag_data.has("type") && String(drag_data["type"]) == "files") {

		Vector<String> files = drag_data["files"];

		if (files.size() == 1) {
			String file = files[0];
			RES res = ResourceLoader::load(file);
			if (res.is_valid()) {
				_edit_set(name, res);
				return;
			}
		}
	}
}

void PropertyEditor::_clear_drop_fields(TreeItem *p_at) {

	Dictionary d = p_at->get_metadata(0);

	if (d.has("type")) {

		int type = d["type"];
		if (type == Variant::OBJECT) {
			p_at->clear_custom_bg_color(1);
		}
	}

	if (p_at->get_children()) {
		_clear_drop_fields(p_at->get_children());
	}

	if (p_at->get_next()) {
		_clear_drop_fields(p_at->get_next());
	}
}

void PropertyEditor::_notification(int p_what) {

	if (p_what == NOTIFICATION_ENTER_TREE) {

		get_tree()->connect("node_removed", this, "_node_removed");
	}
	if (p_what == NOTIFICATION_EXIT_TREE) {

		get_tree()->disconnect("node_removed", this, "_node_removed");
		edit(NULL);
	}

	if (p_what == NOTIFICATION_DRAG_BEGIN) {

		if (is_visible_in_tree() && tree->get_root()) {
			_mark_drop_fields(tree->get_root());
		}
	}

	if (p_what == NOTIFICATION_DRAG_END) {
		if (is_visible_in_tree() && tree->get_root()) {
			_clear_drop_fields(tree->get_root());
		}
	}

	if (p_what == NOTIFICATION_PHYSICS_PROCESS) {

		if (refresh_countdown > 0) {
			refresh_countdown -= get_physics_process_delta_time();
			if (refresh_countdown <= 0) {
				TreeItem *root = tree->get_root();
				_refresh_item(root);
			}
		}

		changing = true;

		if (update_tree_pending) {

			update_tree();
			update_tree_pending = false;

		} else {

			const String *k = NULL;
			while ((k = pending.next(k))) {

				TreeItem *item = find_item(tree->get_root(), *k);
				if (!item)
					continue;

				_check_reload_status(*k, item);

				Dictionary d = item->get_metadata(0);
				set_item_text(item, d["type"], d["name"], d["hint"], d["hint_text"]);
			}
		}

		pending.clear();

		changing = false;
	}

	if (p_what == EditorSettings::NOTIFICATION_EDITOR_SETTINGS_CHANGED) {
		update_tree();
	}
}

TreeItem *PropertyEditor::get_parent_node(String p_path, HashMap<String, TreeItem *> &item_paths, TreeItem *root, TreeItem *category) {

	TreeItem *item = NULL;

	if (p_path == "") {

		item = category ? category : root;
	} else if (item_paths.has(p_path)) {

		item = item_paths.get(p_path);
	} else {

		TreeItem *parent = get_parent_node(p_path.left(p_path.find_last("/")), item_paths, root, NULL);
		item = tree->create_item(parent);

		String name = (p_path.find("/") != -1) ? p_path.right(p_path.find_last("/") + 1) : p_path;
		item->set_text(0, capitalize_paths ? name.capitalize() : name);
		item->set_tooltip(0, p_path);
		if (item->get_parent() != root) {
			item->set_icon(0, get_icon("Folder", "EditorIcons"));
		}

		item->set_editable(0, false);
		if (!subsection_selectable) {
			item->set_expand_right(0, true);
		}
		item->set_selectable(0, subsection_selectable);
		item->set_editable(1, false);
		item->set_selectable(1, subsection_selectable);

		if (use_folding) {
			if (!obj->editor_is_section_unfolded(p_path)) {
				updating_folding = true;
				item->set_collapsed(true);
				updating_folding = false;
			}
			item->set_metadata(0, p_path);
			foldable_property_cache.push_back(p_path);
		}

		if (item->get_parent() == root) {

			item->set_custom_bg_color(0, get_color("prop_subsection", "Editor"));
			item->set_custom_bg_color(1, get_color("prop_subsection", "Editor"));
		}

		item_paths[p_path] = item;
	}

	return item;
}

void PropertyEditor::_refresh_item(TreeItem *p_item) {

	if (!p_item)
		return;

	String name = p_item->get_metadata(1);

	if (name != String()) {

		_check_reload_status(name, p_item);
		Dictionary d = p_item->get_metadata(0);
		set_item_text(p_item, d["type"], d["name"], d["hint"], d["hint_text"]);
	}

	TreeItem *c = p_item->get_children();

	while (c) {

		_refresh_item(c);

		c = c->get_next();
	}
}

void PropertyEditor::refresh() {

	if (refresh_countdown > 0)
		return;
	refresh_countdown = EditorSettings::get_singleton()->get("docks/property_editor/auto_refresh_interval");
}

void PropertyEditor::update_tree() {

	tree->clear();
	foldable_property_cache.clear();

	if (!obj)
		return;

	HashMap<String, TreeItem *> item_path;

	TreeItem *root = tree->create_item(NULL);
	tree->set_hide_root(true);

	List<PropertyInfo> plist;
	obj->get_property_list(&plist, true);

	bool draw_red = false;

	{
		Node *nod = Object::cast_to<Node>(obj);
		Node *es = EditorNode::get_singleton()->get_edited_scene();
		if (nod && es != nod && nod->get_owner() != es) {
			draw_red = true;
		}
	}

	Color sscolor = get_color("prop_subsection", "Editor");

	TreeItem *current_category = NULL;

	String filter = search_box ? search_box->get_text() : "";
	String group;
	String group_base;

	for (List<PropertyInfo>::Element *I = plist.front(); I; I = I->next()) {

		PropertyInfo &p = I->get();

		//make sure the property can be edited

		if (p.usage & PROPERTY_USAGE_GROUP) {

			group = p.name;
			group_base = p.hint_string;

			continue;

		} else if (p.usage & PROPERTY_USAGE_CATEGORY) {

			group = "";
			group_base = "";

			if (!show_categories)
				continue;

			List<PropertyInfo>::Element *N = I->next();
			bool valid = true;
			//if no properties in category, skip
			while (N) {
				if (N->get().usage & PROPERTY_USAGE_EDITOR)
					break;
				if (N->get().usage & PROPERTY_USAGE_CATEGORY) {
					valid = false;
					break;
				}
				N = N->next();
			}
			if (!valid)
				continue; //empty, ignore
			TreeItem *sep = tree->create_item(root);
			current_category = sep;
			String type = p.name;

			if (has_icon(type, "EditorIcons"))
				sep->set_icon(0, get_icon(type, "EditorIcons"));
			else
				sep->set_icon(0, get_icon("Object", "EditorIcons"));

			sep->set_text(0, type);
			sep->set_expand_right(0, true);
			sep->set_selectable(0, false);
			sep->set_selectable(1, false);
			sep->set_custom_bg_color(0, get_color("prop_category", "Editor"));
			sep->set_custom_bg_color(1, get_color("prop_category", "Editor"));
			sep->set_text_align(0, TreeItem::ALIGN_CENTER);
			sep->set_disable_folding(true);

			if (use_doc_hints) {
				StringName type = p.name;
				if (!class_descr_cache.has(type)) {

					String descr;
					DocData *dd = EditorHelp::get_doc_data();
					Map<String, DocData::ClassDoc>::Element *E = dd->class_list.find(type);
					if (E) {
						descr = E->get().brief_description;
					}
					class_descr_cache[type] = descr.word_wrap(80);
				}

				sep->set_tooltip(0, TTR("Class:") + " " + p.name + (class_descr_cache[type] == "" ? "" : "\n\n" + class_descr_cache[type]));
			}
			continue;

		} else if (!(p.usage & PROPERTY_USAGE_EDITOR))
			continue;

		if (hide_script && p.name == "script")
			continue;

		String basename = p.name;
		if (group != "") {
			if (group_base != "") {
				if (basename.begins_with(group_base)) {
					basename = basename.replace_first(group_base, "");
				} else if (group_base.begins_with(basename)) {
					//keep it, this is used pretty often
				} else {
					group = ""; //no longer using group base, clear
				}
			}
		}

		if (group != "") {
			basename = group + "/" + basename;
		}

		String name = (basename.find("/") != -1) ? basename.right(basename.find_last("/") + 1) : basename;

		if (capitalize_paths) {
			int dot = name.find(".");
			if (dot != -1) {
				String ov = name.right(dot);
				name = name.substr(0, dot);
				name = name.camelcase_to_underscore().capitalize();
				name += ov;

			} else {
				name = name.camelcase_to_underscore().capitalize();
			}
		}

		String path = basename.left(basename.find_last("/"));

		if (use_filter && filter != "") {

			String cat = path;

			if (capitalize_paths)
				cat = cat.capitalize();

			if (!filter.is_subsequence_ofi(cat) && !filter.is_subsequence_ofi(name))
				continue;
		}

		TreeItem *parent = get_parent_node(path, item_path, root, current_category);
		int level = 0;
		if (parent != root) {
			level++;
			TreeItem *parent_lev = parent;
			while (parent_lev->get_parent() != root) {
				parent_lev = parent_lev->get_parent();
				level++;
			}
		}
		if (level > 4)
			level = 4;

		Color col = sscolor;
		col.a = (level / 4.0) * 0.7;

		TreeItem *item = tree->create_item(parent);

		if (level > 0) {
			item->set_custom_bg_color(0, col);
		}
		item->set_editable(0, false);
		item->set_selectable(0, property_selectable);

		if (p.usage & PROPERTY_USAGE_CHECKABLE) {

			item->set_cell_mode(0, TreeItem::CELL_MODE_CHECK);
			item->set_selectable(0, true);
			item->set_editable(0, true);
			item->set_checked(0, p.usage & PROPERTY_USAGE_CHECKED);
		}

		item->set_text(0, name);
		item->set_tooltip(0, p.name);

		if (name.find(".") != -1) {
			Color textcol = get_color("font_color", "Tree");
			textcol.a *= 0.5;
			//override :D
			item->set_custom_color(0, textcol);
			item->set_custom_color(1, textcol);

			Color iconcol(1, 1, 1, 0.6);
			item->set_icon_color(0, iconcol);
			item->set_icon_color(1, iconcol);
		}

		if (use_doc_hints) {

			StringName classname = obj->get_class_name();
			StringName propname = p.name;
			String descr;
			bool found = false;

			Map<StringName, Map<StringName, String> >::Element *E = descr_cache.find(classname);
			if (E) {
				Map<StringName, String>::Element *F = E->get().find(propname);
				if (F) {
					found = true;
					descr = F->get();
				}
			}

			if (!found) {
				DocData *dd = EditorHelp::get_doc_data();
				Map<String, DocData::ClassDoc>::Element *E = dd->class_list.find(classname);
				while (E && descr == String()) {
					for (int i = 0; i < E->get().properties.size(); i++) {
						if (E->get().properties[i].name == propname.operator String()) {
							descr = E->get().properties[i].description.strip_edges().word_wrap(80);
							break;
						}
					}
					if (!E->get().inherits.empty()) {
						E = dd->class_list.find(E->get().inherits);
					} else {
						break;
					}
				}
				descr_cache[classname][propname] = descr;
			}

			item->set_tooltip(0, TTR("Property:") + " " + p.name + (descr == "" ? "" : "\n\n" + descr));
		}

		Dictionary d;
		d["name"] = p.name;
		d["type"] = (int)p.type;
		d["hint"] = (int)p.hint;
		d["hint_text"] = p.hint_string;
		d["usage"] = (int)p.usage;

		item->set_metadata(0, d);
		item->set_metadata(1, p.name);

		if (draw_red)
			item->set_custom_color(0, get_color("error_color", "Editor"));

		if (p.name == selected_property) {

			item->select(1);
		}

		switch (p.type) {

			case Variant::BOOL: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CHECK);
				item->set_text(1, TTR("On"));
				item->set_tooltip(1, obj->get(p.name) ? "True" : "False");
				item->set_checked(1, obj->get(p.name));
				if (show_type_icons)
					item->set_icon(0, get_icon("bool", "EditorIcons"));
				item->set_editable(1, !read_only);

			} break;
			case Variant::REAL:
			case Variant::INT: {

				if (p.hint == PROPERTY_HINT_EXP_EASING) {

					item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
					item->set_text(1, String::num(obj->get(p.name), 2));
					item->set_editable(1, !read_only);
					if (show_type_icons)
						item->set_icon(0, get_icon("Curve", "EditorIcons"));

					break;
				}

				if (p.hint == PROPERTY_HINT_LAYERS_2D_PHYSICS || p.hint == PROPERTY_HINT_LAYERS_2D_RENDER || p.hint == PROPERTY_HINT_LAYERS_3D_PHYSICS || p.hint == PROPERTY_HINT_LAYERS_3D_RENDER) {

					item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
					item->set_editable(1, !read_only);
					item->set_custom_draw(1, this, "_draw_flags");
					break;
				}

				if (p.hint == PROPERTY_HINT_FLAGS) {

					item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
					item->set_editable(1, !read_only);

					Vector<String> values = p.hint_string.split(",");
					String flags;
					int val = obj->get(p.name);
					for (int i = 0; i < values.size(); i++) {

						String v = values[i];
						if (v == "")
							continue;
						if (!(val & (1 << i)))
							continue;

						if (flags != "")
							flags += ", ";
						flags += v;
					}
					item->set_text(1, flags);
					break;
				}

				if (p.hint == PROPERTY_HINT_ENUM)
					item->set_cell_mode(1, TreeItem::CELL_MODE_RANGE);
				else
					item->set_cell_mode(1, TreeItem::CELL_MODE_RANGE_EXPRESSION);

				if (p.hint == PROPERTY_HINT_SPRITE_FRAME || p.hint == PROPERTY_HINT_RANGE || p.hint == PROPERTY_HINT_EXP_RANGE) {

					int c = p.hint_string.get_slice_count(",");
					float min = 0, max = 100, step = p.type == Variant::REAL ? .01 : 1;
					if (c >= 1) {

						min = p.hint_string.get_slice(",", 0).to_double();
					}
					if (c >= 2) {

						max = p.hint_string.get_slice(",", 1).to_double();
					}

					if (p.hint != PROPERTY_HINT_SPRITE_FRAME && c >= 3) {

						step = p.hint_string.get_slice(",", 2).to_double();
					}

					item->set_range_config(1, min, max, step, p.hint == PROPERTY_HINT_EXP_RANGE);
				} else if (p.hint == PROPERTY_HINT_ENUM) {

					item->set_text(1, p.hint_string);
					if (show_type_icons)
						item->set_icon(0, get_icon("Enum", "EditorIcons"));
					item->set_range(1, obj->get(p.name));
					item->set_editable(1, !read_only);
					break;
				} else if (p.hint == PROPERTY_HINT_OBJECT_ID) {

					item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);

					String type = p.hint_string;
					if (type == "")
						type = "Object";

					ObjectID id = obj->get(p.name);
					if (id != 0) {
						item->set_text(1, type + " ID: " + itos(id));
						item->add_button(1, get_icon("EditResource", "EditorIcons"));
					} else {
						item->set_text(1, TTR("[Empty]"));
					}

					if (has_icon(p.hint_string, "EditorIcons")) {
						type = p.hint_string;
					} else {
						type = "Object";
					}

					item->set_icon(0, get_icon(type, "EditorIcons"));

					break;

				} else {
					if (p.type == Variant::REAL) {

						item->set_range_config(1, -16777216, 16777216, 0.001);
					} else {

						item->set_range_config(1, -2147483647, 2147483647, 1);
					}
				};

				if (p.type == Variant::REAL) {
					if (show_type_icons)
						item->set_icon(0, get_icon("float", "EditorIcons"));
					item->set_range(1, obj->get(p.name));

				} else {
					if (show_type_icons)
						item->set_icon(0, get_icon("int", "EditorIcons"));
					item->set_range(1, obj->get(p.name));
				}

				item->set_editable(1, !read_only);

			} break;
			case Variant::STRING: {

				switch (p.hint) {

					case PROPERTY_HINT_DIR:
					case PROPERTY_HINT_FILE:
					case PROPERTY_HINT_GLOBAL_DIR:
					case PROPERTY_HINT_GLOBAL_FILE: {

						item->set_cell_mode(1, TreeItem::CELL_MODE_STRING);
						item->set_editable(1, !read_only);
						if (show_type_icons)
							item->set_icon(0, get_icon("File", "EditorIcons"));
						item->set_text(1, obj->get(p.name));
						item->add_button(1, get_icon("Folder", "EditorIcons"));

					} break;
					case PROPERTY_HINT_ENUM: {

						item->set_cell_mode(1, TreeItem::CELL_MODE_RANGE);
						Vector<String> strings = p.hint_string.split(",");
						String current = obj->get(p.name);
						int idx = 0;
						for (int x = 0; x < strings.size(); x++) {
							if (strings[x] == current) {
								idx = x;
								break;
							}
						}
						item->set_text(1, p.hint_string);
						item->set_range(1, idx);
						item->set_editable(1, !read_only);
						if (show_type_icons)
							item->set_icon(0, get_icon("Enum", "EditorIcons"));

					} break;
					case PROPERTY_HINT_METHOD_OF_VARIANT_TYPE: ///< a property of a type
					case PROPERTY_HINT_METHOD_OF_BASE_TYPE: ///< a method of a base type
					case PROPERTY_HINT_METHOD_OF_INSTANCE: ///< a method of an instance
					case PROPERTY_HINT_METHOD_OF_SCRIPT: ///< a method of a script & base
					case PROPERTY_HINT_PROPERTY_OF_VARIANT_TYPE: ///< a property of a type
					case PROPERTY_HINT_PROPERTY_OF_BASE_TYPE: ///< a property of a base type
					case PROPERTY_HINT_PROPERTY_OF_INSTANCE: ///< a property of an instance
					case PROPERTY_HINT_PROPERTY_OF_SCRIPT: ///< a property of a script & base
					case PROPERTY_HINT_TYPE_STRING: {

						item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
						item->set_editable(1, !read_only);
						if (show_type_icons)
							item->set_icon(0, get_icon("String", "EditorIcons"));
						item->set_text(1, obj->get(p.name));

					} break;

					default: {

						item->set_cell_mode(1, TreeItem::CELL_MODE_STRING);
						item->set_editable(1, !read_only);
						if (show_type_icons)
							item->set_icon(0, get_icon("String", "EditorIcons"));
						item->set_text(1, obj->get(p.name));
						if (p.hint == PROPERTY_HINT_MULTILINE_TEXT)
							item->add_button(1, get_icon("MultiLine", "EditorIcons"));

					} break;
				}

			} break;
			case Variant::ARRAY: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->add_button(1, get_icon("EditResource", "EditorIcons"));

				Variant v = obj->get(p.name);
				String type_name = "Array";
				String type_name_suffix = "";

				String hint = p.hint_string;
				while (hint.begins_with(itos(Variant::ARRAY) + ":")) {
					type_name += "<Array";
					type_name_suffix += ">";
					hint = hint.substr(2, hint.size() - 2);
				}
				if (hint.find(":") >= 0) {
					hint = hint.substr(0, hint.find(":"));
					if (hint.find("/") >= 0) {
						hint = hint.substr(0, hint.find("/"));
					}
					type_name += "<" + Variant::get_type_name(Variant::Type(hint.to_int()));
					type_name_suffix += ">";
				}
				type_name += type_name_suffix;

				if (v.is_array())
					item->set_text(1, type_name + "[" + itos(v.call("size")) + "]");
				else
					item->set_text(1, type_name + "[]");

				if (show_type_icons)
					item->set_icon(0, get_icon("PoolByteArray", "EditorIcons"));

			} break;
			case Variant::DICTIONARY: {

				Variant v = obj->get(p.name);

				item->set_cell_mode(1, TreeItem::CELL_MODE_STRING);
				item->set_text(1, String("Dictionary{") + itos(v.call("size")) + "}");
				item->add_button(1, get_icon("EditResource", "EditorIcons"));

				if (show_type_icons)
					item->set_icon(0, get_icon("Dictionary", "EditorIcons"));

			} break;

			case Variant::POOL_INT_ARRAY: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->add_button(1, get_icon("EditResource", "EditorIcons"));

				Variant v = obj->get(p.name);
				if (v.is_array())
					item->set_text(1, "IntArray[" + itos(v.call("size")) + "]");
				else
					item->set_text(1, "IntArray[]");
				if (show_type_icons)
					item->set_icon(0, get_icon("PoolIntArray", "EditorIcons"));

			} break;
			case Variant::POOL_REAL_ARRAY: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->add_button(1, get_icon("EditResource", "EditorIcons"));

				Variant v = obj->get(p.name);
				if (v.is_array())
					item->set_text(1, "FloatArray[" + itos(v.call("size")) + "]");
				else
					item->set_text(1, "FloatArray[]");
				if (show_type_icons)
					item->set_icon(0, get_icon("PoolRealArray", "EditorIcons"));

			} break;
			case Variant::POOL_STRING_ARRAY: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->add_button(1, get_icon("EditResource", "EditorIcons"));

				Variant v = obj->get(p.name);
				if (v.is_array())
					item->set_text(1, "String[" + itos(v.call("size")) + "]");
				else
					item->set_text(1, "String[]");
				if (show_type_icons)
					item->set_icon(0, get_icon("PoolStringArray", "EditorIcons"));

			} break;
			case Variant::POOL_BYTE_ARRAY: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->add_button(1, get_icon("EditResource", "EditorIcons"));

				Variant v = obj->get(p.name);
				if (v.is_array())
					item->set_text(1, "Byte[" + itos(v.call("size")) + "]");
				else
					item->set_text(1, "Byte[]");
				if (show_type_icons)
					item->set_icon(0, get_icon("PoolByteArray", "EditorIcons"));

			} break;
			case Variant::POOL_VECTOR2_ARRAY: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->add_button(1, get_icon("EditResource", "EditorIcons"));

				Variant v = obj->get(p.name);
				if (v.is_array())
					item->set_text(1, "Vector2[" + itos(v.call("size")) + "]");
				else
					item->set_text(1, "Vector2[]");
				if (show_type_icons)
					item->set_icon(0, get_icon("Vector2", "EditorIcons"));

			} break;
			case Variant::POOL_VECTOR3_ARRAY: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->add_button(1, get_icon("EditResource", "EditorIcons"));

				Variant v = obj->get(p.name);
				if (v.is_array())
					item->set_text(1, "Vector3[" + itos(v.call("size")) + "]");
				else
					item->set_text(1, "Vector3[]");
				if (show_type_icons)
					item->set_icon(0, get_icon("Vector3", "EditorIcons"));

			} break;
			case Variant::POOL_COLOR_ARRAY: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->add_button(1, get_icon("EditResource", "EditorIcons"));

				Variant v = obj->get(p.name);
				if (v.is_array())
					item->set_text(1, "Color[" + itos(v.call("size")) + "]");
				else
					item->set_text(1, "Color[]");
				if (show_type_icons)
					item->set_icon(0, get_icon("Color", "EditorIcons"));

			} break;
			case Variant::VECTOR2: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->set_editable(1, true);
				item->set_text(1, obj->get(p.name));
				if (show_type_icons)
					item->set_icon(0, get_icon("Vector2", "EditorIcons"));

			} break;
			case Variant::RECT2: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->set_editable(1, true);
				item->set_text(1, obj->get(p.name));
				if (show_type_icons)
					item->set_icon(0, get_icon("Rect2", "EditorIcons"));

			} break;
			case Variant::VECTOR3: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->set_editable(1, true);
				item->set_text(1, obj->get(p.name));
				if (show_type_icons)
					item->set_icon(0, get_icon("Vector3", "EditorIcons"));

			} break;
			case Variant::TRANSFORM2D:
			case Variant::BASIS: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->set_editable(1, true);
				item->set_text(1, obj->get(p.name));

			} break;
			case Variant::TRANSFORM: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->set_editable(1, true);
				item->set_text(1, obj->get(p.name));
				if (show_type_icons)
					item->set_icon(0, get_icon("Transform", "EditorIcons"));

			} break;
			case Variant::PLANE: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->set_editable(1, true);
				item->set_text(1, obj->get(p.name));
				if (show_type_icons)
					item->set_icon(0, get_icon("Plane", "EditorIcons"));

			} break;
			case Variant::AABB: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->set_editable(1, true);
				item->set_text(1, "AABB");
				if (show_type_icons)
					item->set_icon(0, get_icon("AABB", "EditorIcons"));

			} break;

			case Variant::QUAT: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->set_editable(1, true);
				item->set_text(1, obj->get(p.name));
				if (show_type_icons)
					item->set_icon(0, get_icon("Quat", "EditorIcons"));

			} break;
			case Variant::COLOR: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->set_editable(1, !read_only);
				item->set_custom_draw(1, this, "_draw_transparency");
				if (show_type_icons)
					item->set_icon(0, get_icon("Color", "EditorIcons"));

			} break;

			case Variant::NODE_PATH: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_STRING);
				item->set_editable(1, !read_only);
				item->set_text(1, obj->get(p.name));
				item->add_button(1, get_icon("CopyNodePath", "EditorIcons"));
				if (show_type_icons)
					item->set_icon(0, get_icon("NodePath", "EditorIcons"));

			} break;
			case Variant::OBJECT: {

				item->set_cell_mode(1, TreeItem::CELL_MODE_CUSTOM);
				item->set_editable(1, !read_only);
				String type;
				if (p.hint == PROPERTY_HINT_RESOURCE_TYPE)
					type = p.hint_string;

				RES res = obj->get(p.name).operator RefPtr();
				if (type.begins_with("RES:") && type != "RES:") { // Remote resources
					res = ResourceLoader::load(type.substr(4, type.length()));
				}
				Ref<EncodedObjectAsID> encoded = obj->get(p.name); //for debugger and remote tools

				if (encoded.is_valid()) {

					item->set_text(1, "Object: " + itos(encoded->get_object_id()));
					item->set_icon(1, Ref<Texture>());
					item->set_custom_as_button(1, true);
					item->set_editable(1, true);

				} else if (obj->get(p.name).get_type() == Variant::NIL || res.is_null()) {

					item->set_text(1, "<null>");
					item->set_icon(1, Ref<Texture>());
					item->set_custom_as_button(1, false);

				} else if (res.is_valid()) {

					item->set_custom_as_button(1, true);

					if (res->is_class("Texture")) {
						int tw = EditorSettings::get_singleton()->get("docks/property_editor/texture_preview_width");
						Vector2 size(res->call("get_width"), res->call("get_height"));
						if (size.width < size.height) {
							tw = MAX((size.width / size.height) * tw, 1);
						}
						item->set_icon_max_width(1, tw);
						item->set_icon(1, res);
						item->set_text(1, "");

					} else if (res->get_name() != "") {

						item->set_text(1, res->get_name());
					} else if (res->get_path() != "" && !res->get_path().begins_with("local://")) {
						item->set_text(1, res->get_path().get_file());

					} else {
						item->set_text(1, "<" + res->get_class() + ">");
					}

					if (has_icon(res->get_class(), "EditorIcons")) {
						type = res->get_class();
					}

					if (res.is_valid() && res->get_path().is_resource_file()) {
						item->set_tooltip(1, res->get_path());
					} else if (res.is_valid()) {
						item->set_tooltip(1, res->get_name() + " (" + res->get_class() + ")");
					}
					if (res->is_class("Script")) {
						item->set_text(1, res->get_path().get_file());
					} else if (!res->is_class("Texture")) {
						//texture already previews via itself
						EditorResourcePreview::get_singleton()->queue_edited_resource_preview(res, this, "_resource_preview_done", item->get_instance_id());
					}
				}

				if (type != String()) {
					if (type.find(",") != -1)
						type = type.get_slice(",", 0);
					if (has_icon(type, "EditorIcons"))
						item->set_icon(0, get_icon(type, "EditorIcons"));
					else
						item->set_icon(0, get_icon("Object", "EditorIcons"));
				}

			} break;
			default: {};
		}

		if (keying) {

			if (p.hint == PROPERTY_HINT_SPRITE_FRAME) {

				item->add_button(1, get_icon("KeyNext", "EditorIcons"), 5);
			} else {
				item->add_button(1, get_icon("Key", "EditorIcons"), 2);
			}
		}

		bool has_reload = false;

		if (_is_instanced_node_with_original_property_different(p.name, item)) {
			item->add_button(1, get_icon("ReloadSmall", "EditorIcons"), 3);
			has_reload = true;
		}

		if (obj->call("property_can_revert", p.name).operator bool()) {

			item->add_button(1, get_icon("ReloadSmall", "EditorIcons"), 3);
			has_reload = true;
		}

		if (!has_reload && !obj->get_script().is_null()) {
			Ref<Script> scr = obj->get_script();
			Variant orig_value;
			if (scr->get_property_default_value(p.name, orig_value)) {
				if (orig_value != obj->get(p.name)) {
					item->add_button(1, get_icon("ReloadSmall", "EditorIcons"), 3);
					has_reload = true;
				}
			}
		}

		if (_might_be_in_instance() && !has_reload && item->get_cell_mode(1) == TreeItem::CELL_MODE_RANGE && item->get_text(1) == String()) {
			item->add_button(1, get_icon("ReloadEmpty", "EditorIcons"), 3, true);
		}
	}
}

void PropertyEditor::_draw_transparency(Object *t, const Rect2 &p_rect) {

	TreeItem *ti = Object::cast_to<TreeItem>(t);
	if (!ti)
		return;

	Color color = obj->get(ti->get_metadata(1));
	Ref<Texture> arrow = tree->get_icon("select_option");

	// make a little space between consecutive color fields
	Rect2 area = p_rect;
	area.position.y += 1;
	area.size.height -= 2;
	area.size.width -= arrow->get_size().width + 5;
	tree->draw_texture_rect(get_icon("GuiMiniCheckerboard", "EditorIcons"), area, true);
	tree->draw_rect(area, color);
}

void PropertyEditor::_item_folded(Object *item_obj) {

	if (updating_folding)
		return;

	TreeItem *item = Object::cast_to<TreeItem>(item_obj);

	obj->editor_set_section_unfold(item->get_metadata(0), !item->is_collapsed());
}

void PropertyEditor::_item_selected() {

	TreeItem *item = tree->get_selected();
	ERR_FAIL_COND(!item);
	selected_property = item->get_metadata(1);
}

void PropertyEditor::_item_rmb_edited() {
	_custom_editor_request(true);
}

void PropertyEditor::_edit_set(const String &p_name, const Variant &p_value, bool p_refresh_all, const String &p_changed_field) {

	if (autoclear) {
		TreeItem *item = tree->get_selected();
		if (item && item->get_cell_mode(0) == TreeItem::CELL_MODE_CHECK) {

			item->set_checked(0, true);
		}
	}

	if (!undo_redo || Object::cast_to<ArrayPropertyEdit>(obj) || Object::cast_to<DictionaryPropertyEdit>(obj)) { //kind of hacky

		obj->set(p_name, p_value);
		if (p_refresh_all)
			_changed_callbacks(obj, "");
		else
			_changed_callbacks(obj, p_name);

		emit_signal(_prop_edited, p_name);

	} else if (Object::cast_to<MultiNodeEdit>(obj)) {

		Object::cast_to<MultiNodeEdit>(obj)->set_property_field(p_name, p_value, p_changed_field);
		_changed_callbacks(obj, p_name);
		emit_signal(_prop_edited, p_name);
	} else {

		undo_redo->create_action(TTR("Set") + " " + p_name, UndoRedo::MERGE_ENDS);
		undo_redo->add_do_property(obj, p_name, p_value);
		undo_redo->add_undo_property(obj, p_name, obj->get(p_name));

		if (p_refresh_all) {
			undo_redo->add_do_method(this, "_changed_callback", obj, "");
			undo_redo->add_undo_method(this, "_changed_callback", obj, "");
		} else {

			undo_redo->add_do_method(this, "_changed_callback", obj, p_name);
			undo_redo->add_undo_method(this, "_changed_callback", obj, p_name);
		}

		Resource *r = Object::cast_to<Resource>(obj);
		if (r) {
			if (!r->is_edited() && String(p_name) != "resource/edited") {
				undo_redo->add_do_method(r, "set_edited", true);
				undo_redo->add_undo_method(r, "set_edited", false);
			}

			if (String(p_name) == "resource_local_to_scene") {
				bool prev = obj->get(p_name);
				bool next = p_value;
				if (next) {
					undo_redo->add_do_method(this, "setup_local_to_scene");
				}
				if (prev) {
					undo_redo->add_undo_method(this, "setup_local_to_scene");
				}
			}
		}
		undo_redo->add_do_method(this, "emit_signal", _prop_edited, p_name);
		undo_redo->add_undo_method(this, "emit_signal", _prop_edited, p_name);
		undo_redo->commit_action();
	}
}

void PropertyEditor::_item_edited() {

	TreeItem *item = tree->get_edited();
	if (!item)
		return; //it all happened too fast..

	Dictionary d = item->get_metadata(0);

	String name = d["name"];

	if (tree->get_edited_column() == 0) {
		//property checked
		if (autoclear) {
			if (!item->is_checked(0)) {
				obj->set(name, Variant());
				update_property(name);
			} else {
				Variant::CallError ce;
				obj->set(name, Variant::construct(Variant::Type(int(d["type"])), NULL, 0, ce));
			}
		} else {
			emit_signal("property_toggled", name, item->is_checked(0));
		}
		return;
	}

	if (autoclear && item->get_cell_mode(0) == TreeItem::CELL_MODE_CHECK && item->get_cell_mode(1) != TreeItem::CELL_MODE_CUSTOM) {
		item->set_checked(0, true);
	}

	int type = d["type"];
	int hint = d["hint"];
	int usage = d["usage"];
	bool refresh_all = usage & PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED;

	String hint_text = d["hint_text"];
	switch (type) {

		case Variant::NIL: {

		} break;
		case Variant::BOOL: {

			item->set_tooltip(1, item->is_checked(1) ? "True" : "False");
			_edit_set(name, item->is_checked(1), refresh_all);
		} break;
		case Variant::INT:
		case Variant::REAL: {

			if (hint == PROPERTY_HINT_LAYERS_2D_PHYSICS || hint == PROPERTY_HINT_LAYERS_2D_RENDER || hint == PROPERTY_HINT_LAYERS_3D_PHYSICS || hint == PROPERTY_HINT_LAYERS_3D_RENDER)
				break;
			if (hint == PROPERTY_HINT_EXP_EASING)
				break;
			if (hint == PROPERTY_HINT_FLAGS)
				break;

			if (type == Variant::INT)
				_edit_set(name, int64_t(round(item->get_range(1))), refresh_all);
			else
				_edit_set(name, item->get_range(1), refresh_all);
		} break;
		case Variant::STRING: {

			if (hint == PROPERTY_HINT_ENUM) {

				int idx = item->get_range(1);

				Vector<String> strings = hint_text.split(",");
				String txt;
				if (idx >= 0 && idx < strings.size()) {

					txt = strings[idx];
				}

				_edit_set(name, txt, refresh_all);
			} else {
				_edit_set(name, item->get_text(1), refresh_all);
			}
		} break;

		// math types
		case Variant::VECTOR3: {

		} break;
		case Variant::PLANE: {

		} break;
		case Variant::QUAT: {

		} break;
		case Variant::AABB: {

		} break;
		case Variant::BASIS: {

		} break;
		case Variant::TRANSFORM: {

		} break;
		case Variant::COLOR: {

		} break;

		case Variant::NODE_PATH: {
			_edit_set(name, NodePath(item->get_text(1)), refresh_all);

		} break;
		case Variant::OBJECT: {
			if (!item->is_custom_set_as_button(1))
				break;

			Ref<EncodedObjectAsID> encoded = obj->get(name); //for debugger and remote tools

			if (encoded.is_valid()) {

				emit_signal("object_id_selected", encoded->get_object_id());
			}

			RES res = obj->get(name);
			if (res.is_valid()) {
				emit_signal("resource_selected", res.get_ref_ptr(), name);
			}

		} break;

		case Variant::DICTIONARY: {

		} break;

		// arrays
		case Variant::POOL_BYTE_ARRAY: {

		} break;
		case Variant::POOL_INT_ARRAY: {

		} break;
		case Variant::POOL_REAL_ARRAY: {

		} break;
		case Variant::POOL_STRING_ARRAY: {

		} break;
		case Variant::POOL_VECTOR3_ARRAY: {

		} break;
		case Variant::POOL_COLOR_ARRAY: {

		} break;
	};
}

void PropertyEditor::_resource_edit_request() {

	RES res = custom_editor->get_variant();
	if (res.is_null())
		return;

	String name = custom_editor->get_name();

	emit_signal("resource_selected", res.get_ref_ptr(), name);
}

void PropertyEditor::_custom_editor_edited() {

	if (!obj)
		return;

	_edit_set(custom_editor->get_name(), custom_editor->get_variant());
}

void PropertyEditor::_custom_editor_edited_field(const String &p_field_name) {

	ERR_FAIL_COND(p_field_name == "");

	if (!obj)
		return;

	_edit_set(custom_editor->get_name(), custom_editor->get_variant(), false, p_field_name);
}

void PropertyEditor::_custom_editor_request(bool p_arrow) {

	TreeItem *item = tree->get_edited();
	ERR_FAIL_COND(!item);
	Dictionary d = item->get_metadata(0);

	String name = d["name"];
	Variant::Type type = Variant::NIL;
	if (d.has("type"))
		type = (Variant::Type)((int)(d["type"]));

	Variant v = obj->get(name);
	int hint = d.has("hint") ? d["hint"].operator int() : -1;
	String hint_text = d.has("hint_text") ? d["hint_text"] : "";
	Rect2 where = tree->get_custom_popup_rect();
	custom_editor->set_position(where.position);

	if (custom_editor->edit(obj, name, type, v, hint, hint_text)) {
		custom_editor->popup();
	}
}

void PropertyEditor::edit(Object *p_object) {

	if (obj == p_object)
		return;
	if (obj) {

		obj->remove_change_receptor(this);
	}

	obj = p_object;

	evaluator->edit(p_object);

	update_tree();

	if (obj) {

		obj->add_change_receptor(this);
	}
}

void PropertyEditor::_set_range_def(Object *p_item, String prop, float p_frame) {

	TreeItem *ti = Object::cast_to<TreeItem>(p_item);
	ERR_FAIL_COND(!ti);

	ti->call_deferred("set_range", 1, p_frame);
	obj->call_deferred("set", prop, p_frame);
}

void PropertyEditor::_edit_button(Object *p_item, int p_column, int p_button) {

	TreeItem *ti = Object::cast_to<TreeItem>(p_item);
	ERR_FAIL_COND(!ti);

	Dictionary d = ti->get_metadata(0);

	if (p_button == 2) {

		if (!d.has("name"))
			return;
		String prop = d["name"];
		emit_signal("property_keyed", prop, obj->get(prop), false);
	} else if (p_button == 5) {
		print_line("PB5");
		if (!d.has("name"))
			return;
		String prop = d["name"];
		emit_signal("property_keyed", prop, obj->get(prop), true);
		call_deferred("_set_range_def", ti, prop, ti->get_range(p_column) + 1.0);
	} else if (p_button == 3) {

		if (!d.has("name"))
			return;

		String prop = d["name"];

		Variant vorig;

		if (_might_be_in_instance() && _get_instanced_node_original_property(prop, vorig)) {

			_edit_set(prop, vorig);
			return;
		}

		if (obj->call("property_can_revert", prop).operator bool()) {
			Variant rev = obj->call("property_get_revert", prop);
			_edit_set(prop, rev);
		}

		if (!obj->get_script().is_null()) {
			Ref<Script> scr = obj->get_script();
			Variant orig_value;
			if (scr->get_property_default_value(prop, orig_value)) {
				_edit_set(prop, orig_value);
			}
		}

	} else {

		Dictionary d = ti->get_metadata(0);
		if (!d.has("type"))
			return;
		if (!d.has("hint"))
			return;
		if (!d.has("name"))
			return;
		if (!d.has("hint_text"))
			return;

		int t = d["type"];
		int h = d["hint"];
		String n = d["name"];
		String ht = d["hint_text"];

		if (t == Variant::NODE_PATH) {

			Variant v = obj->get(n);
			Rect2 where = tree->get_item_rect(ti, 1);
			where.position -= tree->get_scroll();
			where.position += tree->get_global_position() + Point2(where.size.width, 0);
			for (int i = ti->get_button_count(p_column) - 1; i >= p_button; i--)
				where.position.x -= ti->get_button(p_column, i)->get_width();
			custom_editor->set_position(where.position);
			custom_editor->edit(obj, n, (Variant::Type)t, v, h, ht);
			custom_editor->popup();

		} else if (t == Variant::STRING) {

			Variant v = obj->get(n);
			custom_editor->edit(obj, n, (Variant::Type)t, v, h, ht);
			if (h == PROPERTY_HINT_FILE || h == PROPERTY_HINT_DIR || h == PROPERTY_HINT_GLOBAL_DIR || h == PROPERTY_HINT_GLOBAL_FILE) {

				Rect2 where = tree->get_item_rect(ti, 1);
				where.position -= tree->get_scroll();
				where.position += tree->get_global_position() + Point2(where.size.width, 0);
				for (int i = ti->get_button_count(p_column) - 1; i >= p_button; i--)
					where.position.x -= ti->get_button(p_column, i)->get_width();
				custom_editor->set_position(where.position);
				custom_editor->popup();
			} else {
				custom_editor->popup_centered_ratio();
			}

		} else if (t == Variant::OBJECT) {

			RES r = obj->get(n);
			if (r.is_valid()) {

				emit_signal("resource_selected", r, n);
			}
		} else if (t == Variant::INT && h == PROPERTY_HINT_OBJECT_ID) {

			emit_signal("object_id_selected", obj->get(n));

		} else if (t == Variant::ARRAY || t == Variant::POOL_INT_ARRAY || t == Variant::POOL_REAL_ARRAY || t == Variant::POOL_STRING_ARRAY || t == Variant::POOL_VECTOR2_ARRAY || t == Variant::POOL_VECTOR3_ARRAY || t == Variant::POOL_COLOR_ARRAY || t == Variant::POOL_BYTE_ARRAY) {

			Variant v = obj->get(n);

			if (v.get_type() != t) {
				Variant::CallError ce;
				v = Variant::construct(Variant::Type(t), NULL, 0, ce);
			}

			Ref<ArrayPropertyEdit> ape = memnew(ArrayPropertyEdit);
			ape->edit(obj, n, ht, Variant::Type(t));
			EditorNode::get_singleton()->push_item(ape.ptr());

		} else if (t == Variant::DICTIONARY) {

			Variant v = obj->get(n);

			if (v.get_type() != t) {
				Variant::CallError ce;
				v = Variant::construct(Variant::Type(t), NULL, 0, ce);
			}

			Ref<DictionaryPropertyEdit> dpe = memnew(DictionaryPropertyEdit);
			dpe->edit(obj, n);
			EditorNode::get_singleton()->push_item(dpe.ptr());
		}
	}
}

void PropertyEditor::_node_removed(Node *p_node) {

	if (p_node == obj) {
		edit(NULL);
	}
}

void PropertyEditor::set_keying(bool p_active) {

	if (keying == p_active)
		return;

	keying = p_active;
	update_tree();
}

void PropertyEditor::_draw_flags(Object *p_object, const Rect2 &p_rect) {

	TreeItem *ti = Object::cast_to<TreeItem>(p_object);
	if (!ti)
		return;

	Dictionary d = ti->get_metadata(0);

	if (!d.has("name"))
		return;

	uint32_t f = obj->get(d["name"]);

	int bsize = (p_rect.size.height * 80 / 100) / 2;

	int h = bsize * 2 + 1;
	int vofs = (p_rect.size.height - h) / 2;

	for (int i = 0; i < 2; i++) {

		Point2 ofs(4, vofs);
		if (i == 1)
			ofs.y += bsize + 1;

		ofs += p_rect.position;
		for (int j = 0; j < 10; j++) {

			Point2 o = ofs + Point2(j * (bsize + 1), 0);
			if (j >= 5)
				o.x += 1;

			uint32_t idx = i * 10 + j;
			bool on = f & (1 << idx);
			tree->draw_rect(Rect2(o, Size2(bsize, bsize)), Color(0, 0, 0, on ? 0.8 : 0.3));
		}
	}
}

void PropertyEditor::_filter_changed(const String &p_text) {

	update_tree();
}

void PropertyEditor::_resource_preview_done(const String &p_path, const Ref<Texture> &p_preview, Variant p_ud) {

	if (p_preview.is_null())
		return; //don't bother with empty preview

	ObjectID id = p_ud;
	Object *obj = ObjectDB::get_instance(id);

	if (!obj)
		return;

	TreeItem *ti = Object::cast_to<TreeItem>(obj);

	ERR_FAIL_COND(!ti);

	int tw = EditorSettings::get_singleton()->get("docks/property_editor/texture_preview_width");

	ti->set_icon(1, p_preview); //should be scaled I think?
	ti->set_icon_max_width(1, tw);
	ti->set_text(1, "");
}
void PropertyEditor::_bind_methods() {

	ClassDB::bind_method("_item_edited", &PropertyEditor::_item_edited);
	ClassDB::bind_method("_item_selected", &PropertyEditor::_item_selected);
	ClassDB::bind_method("_item_rmb_edited", &PropertyEditor::_item_rmb_edited);
	ClassDB::bind_method("_item_folded", &PropertyEditor::_item_folded);
	ClassDB::bind_method("_custom_editor_request", &PropertyEditor::_custom_editor_request);
	ClassDB::bind_method("_custom_editor_edited", &PropertyEditor::_custom_editor_edited);
	ClassDB::bind_method("_custom_editor_edited_field", &PropertyEditor::_custom_editor_edited_field, DEFVAL(""));
	ClassDB::bind_method("_resource_edit_request", &PropertyEditor::_resource_edit_request);
	ClassDB::bind_method("_node_removed", &PropertyEditor::_node_removed);
	ClassDB::bind_method("_edit_button", &PropertyEditor::_edit_button);
	ClassDB::bind_method("_changed_callback", &PropertyEditor::_changed_callbacks);
	ClassDB::bind_method("_draw_flags", &PropertyEditor::_draw_flags);
	ClassDB::bind_method("_set_range_def", &PropertyEditor::_set_range_def);
	ClassDB::bind_method("_filter_changed", &PropertyEditor::_filter_changed);
	ClassDB::bind_method("update_tree", &PropertyEditor::update_tree);
	ClassDB::bind_method("_resource_preview_done", &PropertyEditor::_resource_preview_done);
	ClassDB::bind_method("refresh", &PropertyEditor::refresh);
	ClassDB::bind_method("_draw_transparency", &PropertyEditor::_draw_transparency);
	ClassDB::bind_method("edit", &PropertyEditor::edit);

	ClassDB::bind_method(D_METHOD("get_drag_data_fw"), &PropertyEditor::get_drag_data_fw);
	ClassDB::bind_method(D_METHOD("can_drop_data_fw"), &PropertyEditor::can_drop_data_fw);
	ClassDB::bind_method(D_METHOD("drop_data_fw"), &PropertyEditor::drop_data_fw);

	ADD_SIGNAL(MethodInfo("property_toggled", PropertyInfo(Variant::STRING, "property"), PropertyInfo(Variant::BOOL, "value")));
	ADD_SIGNAL(MethodInfo("resource_selected", PropertyInfo(Variant::OBJECT, "res"), PropertyInfo(Variant::STRING, "prop")));
	ADD_SIGNAL(MethodInfo("object_id_selected", PropertyInfo(Variant::INT, "id")));
	ADD_SIGNAL(MethodInfo("property_keyed", PropertyInfo(Variant::STRING, "property")));
	ADD_SIGNAL(MethodInfo("property_edited", PropertyInfo(Variant::STRING, "property")));
}

Tree *PropertyEditor::get_scene_tree() {

	return tree;
}

Label *PropertyEditor::get_top_label() {

	return top_label;
}

void PropertyEditor::hide_top_label() {

	top_label->hide();
	tree->set_begin(Point2(0, 0));
}

String PropertyEditor::get_selected_path() const {

	TreeItem *ti = tree->get_selected();
	if (!ti)
		return "";

	Dictionary d = ti->get_metadata(0);

	if (d.has("name"))
		return d["name"];
	else
		return "";
}

bool PropertyEditor::is_capitalize_paths_enabled() const {

	return capitalize_paths;
}

void PropertyEditor::set_enable_capitalize_paths(bool p_capitalize) {

	capitalize_paths = p_capitalize;
	update_tree_pending = true;
}

void PropertyEditor::set_autoclear(bool p_enable) {

	autoclear = p_enable;
}

void PropertyEditor::set_show_categories(bool p_show) {

	show_categories = p_show;
	update_tree();
}

void PropertyEditor::set_use_filter(bool p_use) {

	if (p_use == use_filter)
		return;

	use_filter = p_use;
	update_tree();
}

void PropertyEditor::register_text_enter(Node *p_line_edit) {

	ERR_FAIL_NULL(p_line_edit);
	search_box = Object::cast_to<LineEdit>(p_line_edit);

	if (search_box)
		search_box->connect("text_changed", this, "_filter_changed");
}

void PropertyEditor::set_property_selectable(bool p_selectable) {
	property_selectable = p_selectable;
	update_tree();
}

void PropertyEditor::set_subsection_selectable(bool p_selectable) {

	if (p_selectable == subsection_selectable)
		return;

	subsection_selectable = p_selectable;
	update_tree();
}

void PropertyEditor::set_use_folding(bool p_enable) {

	use_folding = p_enable;
	tree->set_hide_folding(false);
}

void PropertyEditor::collapse_all_folding() {
	if (!obj)
		return;
	for (List<String>::Element *E = foldable_property_cache.front(); E; E = E->next()) {
		obj->editor_set_section_unfold(E->get(), false);
	}
	update_tree();
}

void PropertyEditor::expand_all_folding() {

	if (!obj)
		return;
	for (List<String>::Element *E = foldable_property_cache.front(); E; E = E->next()) {
		obj->editor_set_section_unfold(E->get(), true);
	}
	update_tree();
}

PropertyEditor::PropertyEditor() {

	_prop_edited = "property_edited";

	hide_script = true;
	use_folding = false;

	undo_redo = NULL;
	obj = NULL;
	search_box = NULL;
	changing = false;
	update_tree_pending = false;

	top_label = memnew(Label);
	top_label->set_text(TTR("Properties:"));
	top_label->set_anchor(MARGIN_RIGHT, ANCHOR_END);
	top_label->set_begin(Point2(10, 0));
	top_label->set_end(Point2(0, 12));

	add_child(top_label);

	tree = memnew(Tree);
	tree->set_anchor(MARGIN_RIGHT, ANCHOR_END);
	tree->set_anchor(MARGIN_BOTTOM, ANCHOR_END);
	tree->set_begin(Point2(0, 19));
	tree->set_end(Point2(0, 0));

	tree->set_columns(2);
	tree->set_column_expand(0, true);
	tree->set_column_min_width(0, 30);
	tree->set_column_expand(1, true);
	tree->set_column_min_width(1, 18);
	add_child(tree);

	tree->connect("item_edited", this, "_item_edited", varray(), CONNECT_DEFERRED);
	tree->connect("item_rmb_edited", this, "_item_rmb_edited");
	tree->connect("cell_selected", this, "_item_selected");
	tree->connect("item_collapsed", this, "_item_folded");

	tree->set_drag_forwarding(this);

	set_physics_process(true);

	custom_editor = memnew(CustomPropertyEditor);
	custom_editor->set_pass_on_modal_close_click(false);
	add_child(custom_editor);

	tree->connect("custom_popup_edited", this, "_custom_editor_request");
	tree->connect("button_pressed", this, "_edit_button");
	custom_editor->connect("variant_changed", this, "_custom_editor_edited");
	custom_editor->connect("variant_field_changed", this, "_custom_editor_edited_field");
	custom_editor->connect("resource_edit_request", this, "_resource_edit_request", make_binds(), CONNECT_DEFERRED);
	tree->set_hide_folding(true);

	evaluator = memnew(PropertyValueEvaluator);
	tree->set_value_evaluator(evaluator);
	custom_editor->set_value_evaluator(evaluator);

	capitalize_paths = true;
	autoclear = false;
	tree->set_column_titles_visible(false);
	tree->add_constant_override("button_margin", 0);

	keying = false;
	read_only = false;
	show_categories = false;
	refresh_countdown = 0;
	use_doc_hints = false;
	updating_folding = true;
	use_filter = false;
	subsection_selectable = false;
	property_selectable = false;
	show_type_icons = EDITOR_DEF("interface/editor/show_type_icons", false);
}

PropertyEditor::~PropertyEditor() {
	memdelete(evaluator);
}

/////////////////////////////

class SectionedPropertyEditorFilter : public Object {

	GDCLASS(SectionedPropertyEditorFilter, Object);

	Object *edited;
	String section;
	bool allow_sub;

	bool _set(const StringName &p_name, const Variant &p_value) {

		if (!edited)
			return false;

		String name = p_name;
		if (section != "") {
			name = section + "/" + name;
		}

		bool valid;
		edited->set(name, p_value, &valid);
		return valid;
	}

	bool _get(const StringName &p_name, Variant &r_ret) const {

		if (!edited)
			return false;

		String name = p_name;
		if (section != "") {
			name = section + "/" + name;
		}

		bool valid = false;

		r_ret = edited->get(name, &valid);
		return valid;
	}
	void _get_property_list(List<PropertyInfo> *p_list) const {

		if (!edited)
			return;

		List<PropertyInfo> pinfo;
		edited->get_property_list(&pinfo);
		for (List<PropertyInfo>::Element *E = pinfo.front(); E; E = E->next()) {

			PropertyInfo pi = E->get();
			int sp = pi.name.find("/");

			if (pi.name == "resource_path" || pi.name == "resource_name" || pi.name == "resource_local_to_scene" || pi.name.begins_with("script/")) //skip resource stuff
				continue;

			if (sp == -1) {
				pi.name = "global/" + pi.name;
			}

			if (pi.name.begins_with(section + "/")) {
				pi.name = pi.name.replace_first(section + "/", "");
				if (!allow_sub && pi.name.find("/") != -1)
					continue;
				p_list->push_back(pi);
			}
		}
	}

	bool property_can_revert(const String &p_name) {

		return edited->call("property_can_revert", section + "/" + p_name);
	}

	Variant property_get_revert(const String &p_name) {

		return edited->call("property_get_revert", section + "/" + p_name);
	}

protected:
	static void _bind_methods() {

		ClassDB::bind_method("property_can_revert", &SectionedPropertyEditorFilter::property_can_revert);
		ClassDB::bind_method("property_get_revert", &SectionedPropertyEditorFilter::property_get_revert);
	}

public:
	void set_section(const String &p_section, bool p_allow_sub) {

		section = p_section;
		allow_sub = p_allow_sub;
		_change_notify();
	}

	void set_edited(Object *p_edited) {
		edited = p_edited;
		_change_notify();
	}

	SectionedPropertyEditorFilter() {
		edited = NULL;
	}
};

void SectionedPropertyEditor::_bind_methods() {

	ClassDB::bind_method("_section_selected", &SectionedPropertyEditor::_section_selected);
	ClassDB::bind_method("_search_changed", &SectionedPropertyEditor::_search_changed);

	ClassDB::bind_method("update_category_list", &SectionedPropertyEditor::update_category_list);
}

void SectionedPropertyEditor::_section_selected() {

	if (!sections->get_selected())
		return;

	filter->set_section(sections->get_selected()->get_metadata(0), sections->get_selected()->get_children() == NULL);
}

void SectionedPropertyEditor::set_current_section(const String &p_section) {

	if (section_map.has(p_section)) {
		section_map[p_section]->select(0);
	}
}

String SectionedPropertyEditor::get_current_section() const {

	if (sections->get_selected())
		return sections->get_selected()->get_metadata(0);
	else
		return "";
}

String SectionedPropertyEditor::get_full_item_path(const String &p_item) {

	String base = get_current_section();

	if (base != "")
		return base + "/" + p_item;
	else
		return p_item;
}

void SectionedPropertyEditor::edit(Object *p_object) {

	if (!p_object) {
		obj = -1;
		sections->clear();

		filter->set_edited(NULL);
		editor->edit(NULL);

		return;
	}

	ObjectID id = p_object->get_instance_id();

	if (obj != id) {

		obj = id;
		update_category_list();

		filter->set_edited(p_object);
		editor->edit(filter);

		if (sections->get_root()->get_children()) {
			sections->get_root()->get_children()->select(0);
		}
	} else {

		update_category_list();
	}
}

void SectionedPropertyEditor::update_category_list() {

	String selected_category = get_current_section();
	sections->clear();

	Object *o = ObjectDB::get_instance(obj);

	if (!o)
		return;

	List<PropertyInfo> pinfo;
	o->get_property_list(&pinfo);

	section_map.clear();

	TreeItem *root = sections->create_item();
	section_map[""] = root;

	for (List<PropertyInfo>::Element *E = pinfo.front(); E; E = E->next()) {

		PropertyInfo pi = E->get();

		if (pi.usage & PROPERTY_USAGE_CATEGORY)
			continue;
		else if (!(pi.usage & PROPERTY_USAGE_EDITOR))
			continue;

		if (pi.name.find(":") != -1 || pi.name == "script" || pi.name == "resource_name" || pi.name == "resource_path" || pi.name == "resource_local_to_scene")
			continue;

		if (search_box && search_box->get_text() != String() && pi.name.findn(search_box->get_text()) == -1)
			continue;

		int sp = pi.name.find("/");
		if (sp == -1)
			pi.name = "Global/" + pi.name;

		Vector<String> sectionarr = pi.name.split("/");
		String metasection;

		int sc = MIN(2, sectionarr.size() - 1);

		for (int i = 0; i < sc; i++) {

			TreeItem *parent = section_map[metasection];
			parent->set_custom_bg_color(0, get_color("prop_subsection", "Editor"));

			if (i > 0) {
				metasection += "/" + sectionarr[i];
			} else {
				metasection = sectionarr[i];
			}

			if (!section_map.has(metasection)) {
				TreeItem *ms = sections->create_item(parent);
				section_map[metasection] = ms;
				ms->set_text(0, sectionarr[i].capitalize());
				ms->set_metadata(0, metasection);
				ms->set_selectable(0, false);
			}

			if (i == sc - 1) {
				//if it has children, make selectable
				section_map[metasection]->set_selectable(0, true);
			}
		}
	}

	if (section_map.has(selected_category)) {
		section_map[selected_category]->select(0);
	}

	editor->update_tree();
}

void SectionedPropertyEditor::register_search_box(LineEdit *p_box) {

	search_box = p_box;
	editor->register_text_enter(p_box);
	search_box->connect("text_changed", this, "_search_changed");
}

void SectionedPropertyEditor::_search_changed(const String &p_what) {

	update_category_list();
}

PropertyEditor *SectionedPropertyEditor::get_property_editor() {

	return editor;
}

SectionedPropertyEditor::SectionedPropertyEditor() {

	obj = -1;

	search_box = NULL;

	add_constant_override("autohide", 1); // Fixes the dragger always showing up

	VBoxContainer *left_vb = memnew(VBoxContainer);
	left_vb->set_custom_minimum_size(Size2(170, 0) * EDSCALE);
	add_child(left_vb);

	sections = memnew(Tree);
	sections->set_v_size_flags(SIZE_EXPAND_FILL);
	sections->set_hide_root(true);

	left_vb->add_child(sections, true);

	VBoxContainer *right_vb = memnew(VBoxContainer);
	right_vb->set_custom_minimum_size(Size2(300, 0) * EDSCALE);
	right_vb->set_h_size_flags(SIZE_EXPAND_FILL);
	add_child(right_vb);

	filter = memnew(SectionedPropertyEditorFilter);
	editor = memnew(PropertyEditor);
	editor->set_v_size_flags(SIZE_EXPAND_FILL);
	right_vb->add_child(editor, true);

	editor->get_scene_tree()->set_column_titles_visible(false);

	editor->hide_top_label();

	sections->connect("cell_selected", this, "_section_selected");
}

SectionedPropertyEditor::~SectionedPropertyEditor() {

	memdelete(filter);
}

double PropertyValueEvaluator::eval(const String &p_text) {

	// If range value contains a comma replace it with dot (issue #6028)
	const String &p_new_text = p_text.replace(",", ".");

	if (!obj || !script_language)
		return _default_eval(p_new_text);

	Ref<Script> script = Ref<Script>(script_language->create_script());
	script->set_source_code(_build_script(p_new_text));
	Error err = script->reload();
	if (err) {
		print_line("[PropertyValueEvaluator] Error loading script for expression: " + p_new_text);
		return _default_eval(p_new_text);
	}

	Object dummy;
	ScriptInstance *script_instance = script->instance_create(&dummy);
	if (!script_instance)
		return _default_eval(p_new_text);

	Variant::CallError call_err;
	Variant arg = obj;
	const Variant *args[] = { &arg };
	double result = script_instance->call("eval", args, 1, call_err);
	if (call_err.error == Variant::CallError::CALL_OK) {
		return result;
	}
	print_line("[PropertyValueEvaluator]: Error eval! Error code: " + itos(call_err.error));

	return _default_eval(p_new_text);
}

void PropertyValueEvaluator::edit(Object *p_obj) {
	obj = p_obj;
}

String PropertyValueEvaluator::_build_script(const String &p_text) {
	String script_text = "tool\nextends Object\nfunc eval(s):\n\tself = s\n\treturn " + p_text.strip_edges() + "\n";
	return script_text;
}

PropertyValueEvaluator::PropertyValueEvaluator() {
	script_language = NULL;

	for (int i = 0; i < ScriptServer::get_language_count(); i++) {
		if (ScriptServer::get_language(i)->get_name() == "GDScript") {
			script_language = ScriptServer::get_language(i);
		}
	}
}

PropertyValueEvaluator::~PropertyValueEvaluator() {
}
