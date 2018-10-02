/*************************************************************************/
/*  script_editor_debugger.cpp                                           */
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

#include "script_editor_debugger.h"

#include "editor_node.h"
#include "editor_profiler.h"
#include "editor_settings.h"
#include "main/performance.h"
#include "project_settings.h"
#include "property_editor.h"
#include "scene/gui/dialogs.h"
#include "scene/gui/label.h"
#include "scene/gui/line_edit.h"
#include "scene/gui/margin_container.h"
#include "scene/gui/rich_text_label.h"
#include "scene/gui/separator.h"
#include "scene/gui/split_container.h"
#include "scene/gui/tab_container.h"
#include "scene/gui/texture_button.h"
#include "scene/gui/tree.h"
#include "ustring.h"

class ScriptEditorDebuggerVariables : public Object {

	GDCLASS(ScriptEditorDebuggerVariables, Object);

	List<PropertyInfo> props;
	Map<StringName, Variant> values;

protected:
	bool _set(const StringName &p_name, const Variant &p_value) {

		return false;
	}

	bool _get(const StringName &p_name, Variant &r_ret) const {

		if (!values.has(p_name))
			return false;
		r_ret = values[p_name];
		return true;
	}
	void _get_property_list(List<PropertyInfo> *p_list) const {

		for (const List<PropertyInfo>::Element *E = props.front(); E; E = E->next())
			p_list->push_back(E->get());
	}

public:
	void clear() {

		props.clear();
		values.clear();
	}

	String get_var_value(const String &p_var) const {

		for (Map<StringName, Variant>::Element *E = values.front(); E; E = E->next()) {
			String v = E->key().operator String().get_slice("/", 1);
			if (v == p_var)
				return E->get();
		}

		return "";
	}

	void add_property(const String &p_name, const Variant &p_value, const PropertyHint &p_hint, const String p_hint_string) {

		PropertyInfo pinfo;
		pinfo.name = p_name;
		pinfo.type = p_value.get_type();
		pinfo.hint = p_hint;
		pinfo.hint_string = p_hint_string;
		props.push_back(pinfo);
		values[p_name] = p_value;
	}

	void update() {
		_change_notify();
	}

	ScriptEditorDebuggerVariables() {
	}
};

class ScriptEditorDebuggerInspectedObject : public Object {

	GDCLASS(ScriptEditorDebuggerInspectedObject, Object);

protected:
	bool _set(const StringName &p_name, const Variant &p_value) {

		if (!prop_values.has(p_name) || String(p_name).begins_with("Constants/"))
			return false;

		emit_signal("value_edited", p_name, p_value);
		prop_values[p_name] = p_value;
		return true;
	}

	bool _get(const StringName &p_name, Variant &r_ret) const {

		if (!prop_values.has(p_name))
			return false;

		r_ret = prop_values[p_name];
		return true;
	}

	void _get_property_list(List<PropertyInfo> *p_list) const {

		p_list->clear(); //sorry, no want category
		for (const List<PropertyInfo>::Element *E = prop_list.front(); E; E = E->next()) {
			p_list->push_back(E->get());
		}
	}

	static void _bind_methods() {

		ClassDB::bind_method(D_METHOD("get_title"), &ScriptEditorDebuggerInspectedObject::get_title);
		ClassDB::bind_method(D_METHOD("get_variant"), &ScriptEditorDebuggerInspectedObject::get_variant);
		ClassDB::bind_method(D_METHOD("clear"), &ScriptEditorDebuggerInspectedObject::clear);
		ClassDB::bind_method(D_METHOD("get_remote_object_id"), &ScriptEditorDebuggerInspectedObject::get_remote_object_id);

		ADD_SIGNAL(MethodInfo("value_edited"));
	}

public:
	String type_name;
	ObjectID remote_object_id;
	List<PropertyInfo> prop_list;
	Map<StringName, Variant> prop_values;

	ObjectID get_remote_object_id() {
		return remote_object_id;
	}

	String get_title() {
		if (remote_object_id)
			return TTR("Remote ") + String(type_name) + ": " + itos(remote_object_id);
		else
			return "<null>";
	}
	Variant get_variant(const StringName &p_name) {

		Variant var;
		_get(p_name, var);
		return var;
	}

	void clear() {

		prop_list.clear();
		prop_values.clear();
	}
	void update() {
		_change_notify();
	}
	void update_single(const char *p_prop) {
		_change_notify(p_prop);
	}

	ScriptEditorDebuggerInspectedObject() {
		remote_object_id = 0;
	}
};

void ScriptEditorDebugger::debug_copy() {
	String msg = reason->get_text();
	if (msg == "") return;
	OS::get_singleton()->set_clipboard(msg);
}

void ScriptEditorDebugger::debug_next() {

	ERR_FAIL_COND(!breaked);
	ERR_FAIL_COND(connection.is_null());
	ERR_FAIL_COND(!connection->is_connected_to_host());
	Array msg;
	msg.push_back("next");
	ppeer->put_var(msg);
	stack_dump->clear();
	inspector->edit(NULL);
}
void ScriptEditorDebugger::debug_step() {

	ERR_FAIL_COND(!breaked);
	ERR_FAIL_COND(connection.is_null());
	ERR_FAIL_COND(!connection->is_connected_to_host());

	Array msg;
	msg.push_back("step");
	ppeer->put_var(msg);
	stack_dump->clear();
	inspector->edit(NULL);
}

void ScriptEditorDebugger::debug_break() {

	ERR_FAIL_COND(breaked);
	ERR_FAIL_COND(connection.is_null());
	ERR_FAIL_COND(!connection->is_connected_to_host());

	Array msg;
	msg.push_back("break");
	ppeer->put_var(msg);
}

void ScriptEditorDebugger::debug_continue() {

	ERR_FAIL_COND(!breaked);
	ERR_FAIL_COND(connection.is_null());
	ERR_FAIL_COND(!connection->is_connected_to_host());

	OS::get_singleton()->enable_for_stealing_focus(EditorNode::get_singleton()->get_child_process_id());

	Array msg;
	msg.push_back("continue");
	ppeer->put_var(msg);
}

void ScriptEditorDebugger::_scene_tree_folded(Object *obj) {

	if (updating_scene_tree) {

		return;
	}
	TreeItem *item = Object::cast_to<TreeItem>(obj);

	if (!item)
		return;

	ObjectID id = item->get_metadata(0);
	if (item->is_collapsed()) {
		unfold_cache.erase(id);
	} else {
		unfold_cache.insert(id);
	}
}

void ScriptEditorDebugger::_scene_tree_selected() {

	if (updating_scene_tree) {

		return;
	}
	TreeItem *item = inspect_scene_tree->get_selected();
	if (!item) {

		return;
	}

	inspected_object_id = item->get_metadata(0);

	Array msg;
	msg.push_back("inspect_object");
	msg.push_back(inspected_object_id);
	ppeer->put_var(msg);
}

void ScriptEditorDebugger::_scene_tree_property_value_edited(const String &p_prop, const Variant &p_value) {

	Array msg;
	msg.push_back("set_object_property");
	msg.push_back(inspected_object_id);
	msg.push_back(p_prop);
	msg.push_back(p_value);
	ppeer->put_var(msg);
	inspect_edited_object_timeout = 0.7; //avoid annoyance, don't request soon after editing
}

void ScriptEditorDebugger::_scene_tree_property_select_object(ObjectID p_object) {

	inspected_object_id = p_object;
	Array msg;
	msg.push_back("inspect_object");
	msg.push_back(inspected_object_id);
	ppeer->put_var(msg);
}

void ScriptEditorDebugger::_scene_tree_request() {

	ERR_FAIL_COND(connection.is_null());
	ERR_FAIL_COND(!connection->is_connected_to_host());

	Array msg;
	msg.push_back("request_scene_tree");
	ppeer->put_var(msg);
}

void ScriptEditorDebugger::_video_mem_request() {

	ERR_FAIL_COND(connection.is_null());
	ERR_FAIL_COND(!connection->is_connected_to_host());

	Array msg;
	msg.push_back("request_video_mem");
	ppeer->put_var(msg);
}

Size2 ScriptEditorDebugger::get_minimum_size() const {

	Size2 ms = Control::get_minimum_size();
	ms.y = MAX(ms.y, 250);
	return ms;
}
void ScriptEditorDebugger::_parse_message(const String &p_msg, const Array &p_data) {

	if (p_msg == "debug_enter") {
		Array msg;
		msg.push_back("get_stack_dump");
		ppeer->put_var(msg);
		ERR_FAIL_COND(p_data.size() != 2);
		bool can_continue = p_data[0];
		String error = p_data[1];
		step->set_disabled(!can_continue);
		next->set_disabled(!can_continue);
		_set_reason_text(error, MESSAGE_ERROR);
		copy->set_disabled(false);
		breaked = true;
		dobreak->set_disabled(true);
		docontinue->set_disabled(false);
		emit_signal("breaked", true, can_continue);
		OS::get_singleton()->move_window_to_foreground();
		if (error != "") {
			tabs->set_current_tab(0);
		}
		profiler->set_enabled(false);
		EditorNode::get_singleton()->get_pause_button()->set_pressed(true);
		EditorNode::get_singleton()->make_bottom_panel_item_visible(this);
		_clear_remote_objects();

	} else if (p_msg == "debug_exit") {

		breaked = false;
		copy->set_disabled(true);
		step->set_disabled(true);
		next->set_disabled(true);
		reason->set_text("");
		reason->set_tooltip("");
		back->set_disabled(true);
		forward->set_disabled(true);
		dobreak->set_disabled(false);
		docontinue->set_disabled(true);
		emit_signal("breaked", false, false, Variant());
		//tabs->set_current_tab(0);
		profiler->set_enabled(true);
		profiler->disable_seeking();
		inspector->edit(NULL);
		EditorNode::get_singleton()->get_pause_button()->set_pressed(false);
	} else if (p_msg == "message:click_ctrl") {

		clicked_ctrl->set_text(p_data[0]);
		clicked_ctrl_type->set_text(p_data[1]);

	} else if (p_msg == "message:scene_tree") {

		inspect_scene_tree->clear();
		Map<int, TreeItem *> lv;

		updating_scene_tree = true;

		for (int i = 0; i < p_data.size(); i += 4) {

			TreeItem *p;
			int level = p_data[i];
			if (level == 0) {
				p = NULL;
			} else {
				ERR_CONTINUE(!lv.has(level - 1));
				p = lv[level - 1];
			}

			TreeItem *it = inspect_scene_tree->create_item(p);

			ObjectID id = ObjectID(p_data[i + 3]);

			it->set_text(0, p_data[i + 1]);
			if (has_icon(p_data[i + 2], "EditorIcons"))
				it->set_icon(0, get_icon(p_data[i + 2], "EditorIcons"));
			it->set_metadata(0, id);

			if (id == inspected_object_id) {
				TreeItem *cti = it->get_parent(); //ensure selected is always uncollapsed
				while (cti) {
					cti->set_collapsed(false);
					cti = cti->get_parent();
				}
				it->select(0);
			}

			if (p) {
				if (!unfold_cache.has(id)) {
					it->set_collapsed(true);
				}
			} else {
				if (unfold_cache.has(id)) { //reverse for root
					it->set_collapsed(true);
				}
			}

			lv[level] = it;
		}
		updating_scene_tree = false;

		le_clear->set_disabled(false);
		le_set->set_disabled(false);
	} else if (p_msg == "message:inspect_object") {

		ScriptEditorDebuggerInspectedObject *debugObj = NULL;

		ObjectID id = p_data[0];
		String type = p_data[1];
		Array properties = p_data[2];

		bool is_new_object = false;
		if (remote_objects.has(id)) {
			debugObj = remote_objects[id];
		} else {
			debugObj = memnew(ScriptEditorDebuggerInspectedObject);
			debugObj->remote_object_id = id;
			debugObj->type_name = type;
			remote_objects[id] = debugObj;
			is_new_object = true;
			debugObj->connect("value_edited", this, "_scene_tree_property_value_edited");
		}

		for (int i = 0; i < properties.size(); i++) {

			Array prop = properties[i];
			if (prop.size() != 6)
				continue;

			PropertyInfo pinfo;
			pinfo.name = prop[0];
			pinfo.type = Variant::Type(int(prop[1]));
			pinfo.hint = PropertyHint(int(prop[2]));
			pinfo.hint_string = prop[3];
			pinfo.usage = PropertyUsageFlags(int(prop[4]));
			Variant var = prop[5];

			String hint_string = pinfo.hint_string;
			if (hint_string.begins_with("RES:") && hint_string != "RES:") {
				String path = hint_string.substr(4, hint_string.length());
				var = ResourceLoader::load(path);
			}

			if (is_new_object) {
				//don't update.. it's the same, instead refresh
				debugObj->prop_list.push_back(pinfo);
			}

			debugObj->prop_values[pinfo.name] = var;
		}

		if (editor->get_editor_history()->get_current() != debugObj->get_instance_id()) {
			editor->push_item(debugObj, "");
		} else {
			debugObj->update();
		}
	} else if (p_msg == "message:video_mem") {

		vmem_tree->clear();
		TreeItem *root = vmem_tree->create_item();

		int total = 0;

		for (int i = 0; i < p_data.size(); i += 4) {

			TreeItem *it = vmem_tree->create_item(root);
			String type = p_data[i + 1];
			int bytes = p_data[i + 3].operator int();
			it->set_text(0, p_data[i + 0]); //path
			it->set_text(1, type); //type
			it->set_text(2, p_data[i + 2]); //type
			it->set_text(3, String::humanize_size(bytes)); //type
			total += bytes;

			if (has_icon(type, "EditorIcons"))
				it->set_icon(0, get_icon(type, "EditorIcons"));
		}

		vmem_total->set_tooltip(TTR("Bytes:") + " " + itos(total));
		vmem_total->set_text(String::humanize_size(total));

	} else if (p_msg == "stack_dump") {

		stack_dump->clear();
		TreeItem *r = stack_dump->create_item();

		for (int i = 0; i < p_data.size(); i++) {

			Dictionary d = p_data[i];
			ERR_CONTINUE(!d.has("function"));
			ERR_CONTINUE(!d.has("file"));
			ERR_CONTINUE(!d.has("line"));
			ERR_CONTINUE(!d.has("id"));
			TreeItem *s = stack_dump->create_item(r);
			d["frame"] = i;
			s->set_metadata(0, d);

			//String line = itos(i)+" - "+String(d["file"])+":"+itos(d["line"])+" - at func: "+d["function"];
			String line = itos(i) + " - " + String(d["file"]) + ":" + itos(d["line"]);
			s->set_text(0, line);

			if (i == 0)
				s->select(0);
		}
	} else if (p_msg == "stack_frame_vars") {

		variables->clear();

		int ofs = 0;
		int mcount = p_data[ofs];
		ofs++;
		for (int i = 0; i < mcount; i++) {

			String n = p_data[ofs + i * 2 + 0];
			Variant v = p_data[ofs + i * 2 + 1];
			PropertyHint h = PROPERTY_HINT_NONE;
			String hs = String();

			if (n.begins_with("*")) {

				n = n.substr(1, n.length());
				h = PROPERTY_HINT_OBJECT_ID;
				String s = v;
				s = s.replace("[", "");
				hs = s.get_slice(":", 0);
				v = s.get_slice(":", 1).to_int();
			}

			variables->add_property("Locals/" + n, v, h, hs);
		}

		ofs += mcount * 2;
		mcount = p_data[ofs];
		ofs++;
		for (int i = 0; i < mcount; i++) {

			String n = p_data[ofs + i * 2 + 0];
			Variant v = p_data[ofs + i * 2 + 1];
			PropertyHint h = PROPERTY_HINT_NONE;
			String hs = String();

			if (n.begins_with("*")) {

				n = n.substr(1, n.length());
				h = PROPERTY_HINT_OBJECT_ID;
				String s = v;
				s = s.replace("[", "");
				hs = s.get_slice(":", 0);
				v = s.get_slice(":", 1).to_int();
			}

			variables->add_property("Members/" + n, v, h, hs);
		}

		ofs += mcount * 2;
		mcount = p_data[ofs];
		ofs++;
		for (int i = 0; i < mcount; i++) {

			String n = p_data[ofs + i * 2 + 0];
			Variant v = p_data[ofs + i * 2 + 1];
			PropertyHint h = PROPERTY_HINT_NONE;
			String hs = String();

			if (n.begins_with("*")) {

				n = n.substr(1, n.length());
				h = PROPERTY_HINT_OBJECT_ID;
				String s = v;
				s = s.replace("[", "");
				hs = s.get_slice(":", 0);
				v = s.get_slice(":", 1).to_int();
			}

			variables->add_property("Globals/" + n, v, h, hs);
		}

		variables->update();
		inspector->edit(variables);

	} else if (p_msg == "output") {

		//OUT
		for (int i = 0; i < p_data.size(); i++) {

			String t = p_data[i];
			//LOG

			if (!EditorNode::get_log()->is_visible()) {
				if (EditorNode::get_singleton()->are_bottom_panels_hidden()) {
					if (EDITOR_GET("run/output/always_open_output_on_play")) {
						EditorNode::get_singleton()->make_bottom_panel_item_visible(EditorNode::get_log());
					}
				}
			}
			EditorNode::get_log()->add_message(t);
		}

	} else if (p_msg == "performance") {
		Array arr = p_data[0];
		Vector<float> p;
		p.resize(arr.size());
		for (int i = 0; i < arr.size(); i++) {
			p[i] = arr[i];
			if (i < perf_items.size()) {

				float v = p[i];
				String vs = rtos(v);
				String tt = vs;
				switch (Performance::MonitorType((int)perf_items[i]->get_metadata(1))) {
					case Performance::MONITOR_TYPE_MEMORY: {
						// for the time being, going above GBs is a bad sign.
						String unit = "B";
						if ((int)v > 1073741824) {
							unit = "GB";
							v /= 1073741824.0;
						} else if ((int)v > 1048576) {
							unit = "MB";
							v /= 1048576.0;
						} else if ((int)v > 1024) {
							unit = "KB";
							v /= 1024.0;
						}
						tt += " bytes";
						vs = String::num(v, 2) + " " + unit;
					} break;
					case Performance::MONITOR_TYPE_TIME: {
						tt += " seconds";
						vs += " s";
					} break;
					default: {
						tt += " " + perf_items[i]->get_text(0);
					} break;
				}

				perf_items[i]->set_text(1, vs);
				perf_items[i]->set_tooltip(1, tt);
				if (p[i] > perf_max[i])
					perf_max[i] = p[i];
			}
		}
		perf_history.push_front(p);
		perf_draw->update();

	} else if (p_msg == "error") {

		Array err = p_data[0];

		Array vals;
		vals.push_back(err[0]);
		vals.push_back(err[1]);
		vals.push_back(err[2]);
		vals.push_back(err[3]);

		bool warning = err[9];
		bool e;
		String time = String("%d:%02d:%02d:%04d").sprintf(vals, &e);
		String txt = time + " - " + (err[8].is_zero() ? String(err[7]) : String(err[8]));

		String tooltip = TTR("Type:") + String(warning ? TTR("Warning") : TTR("Error"));
		tooltip += "\n" + TTR("Description:") + " " + String(err[8]);
		tooltip += "\n" + TTR("Time:") + " " + time;
		tooltip += "\nC " + TTR("Error:") + " " + String(err[7]);
		tooltip += "\nC " + TTR("Source:") + " " + String(err[5]) + ":" + String(err[6]);
		tooltip += "\nC " + TTR("Function:") + " " + String(err[4]);

		error_list->add_item(txt, EditorNode::get_singleton()->get_gui_base()->get_icon(warning ? "Warning" : "Error", "EditorIcons"));
		error_list->set_item_tooltip(error_list->get_item_count() - 1, tooltip);

		int scc = p_data[1];

		Array stack;
		stack.resize(scc);
		for (int i = 0; i < scc; i++) {
			stack[i] = p_data[2 + i];
		}

		error_list->set_item_metadata(error_list->get_item_count() - 1, stack);

		error_count++;
		/*
		int count = p_data[1];

		Array cstack;

		OutputError oe = errors.front()->get();

		packet_peer_stream->put_var(oe.hr);
		packet_peer_stream->put_var(oe.min);
		packet_peer_stream->put_var(oe.sec);
		packet_peer_stream->put_var(oe.msec);
		packet_peer_stream->put_var(oe.source_func);
		packet_peer_stream->put_var(oe.source_file);
		packet_peer_stream->put_var(oe.source_line);
		packet_peer_stream->put_var(oe.error);
		packet_peer_stream->put_var(oe.error_descr);
		packet_peer_stream->put_var(oe.warning);
		packet_peer_stream->put_var(oe.callstack);
		*/

	} else if (p_msg == "profile_sig") {
		//cache a signature
		profiler_signature[p_data[1]] = p_data[0];

	} else if (p_msg == "profile_frame" || p_msg == "profile_total") {

		EditorProfiler::Metric metric;
		metric.valid = true;
		metric.frame_number = p_data[0];
		metric.frame_time = p_data[1];
		metric.idle_time = p_data[2];
		metric.physics_time = p_data[3];
		metric.physics_frame_time = p_data[4];
		int frame_data_amount = p_data[6];
		int frame_function_amount = p_data[7];

		if (frame_data_amount) {
			EditorProfiler::Metric::Category frame_time;
			frame_time.signature = "category_frame_time";
			frame_time.name = "Frame Time";
			frame_time.total_time = metric.frame_time;

			EditorProfiler::Metric::Category::Item item;
			item.calls = 1;
			item.line = 0;
			item.name = "Physics Time";
			item.total = metric.physics_time;
			item.self = item.total;
			item.signature = "physics_time";

			frame_time.items.push_back(item);

			item.name = "Idle Time";
			item.total = metric.idle_time;
			item.self = item.total;
			item.signature = "idle_time";

			frame_time.items.push_back(item);

			item.name = "Physics Frame Time";
			item.total = metric.physics_frame_time;
			item.self = item.total;
			item.signature = "physics_frame_time";

			frame_time.items.push_back(item);

			metric.categories.push_back(frame_time);
		}

		int idx = 8;
		for (int i = 0; i < frame_data_amount; i++) {

			EditorProfiler::Metric::Category c;
			String name = p_data[idx++];
			Array values = p_data[idx++];
			c.name = name.capitalize();
			c.items.resize(values.size() / 2);
			c.total_time = 0;
			c.signature = "categ::" + name;
			for (int i = 0; i < values.size(); i += 2) {

				EditorProfiler::Metric::Category::Item item;
				item.name = values[i];
				item.calls = 1;
				item.self = values[i + 1];
				item.total = item.self;
				item.signature = "categ::" + name + "::" + item.name;
				item.name = item.name.capitalize();
				c.total_time += item.total;
				c.items[i / 2] = item;
			}
			metric.categories.push_back(c);
		}

		EditorProfiler::Metric::Category funcs;
		funcs.total_time = p_data[5]; //script time
		funcs.items.resize(frame_function_amount);
		funcs.name = "Script Functions";
		funcs.signature = "script_functions";
		for (int i = 0; i < frame_function_amount; i++) {

			int signature = p_data[idx++];
			int calls = p_data[idx++];
			float total = p_data[idx++];
			float self = p_data[idx++];

			EditorProfiler::Metric::Category::Item item;
			if (profiler_signature.has(signature)) {

				item.signature = profiler_signature[signature];

				String name = profiler_signature[signature];
				Vector<String> strings = name.split("::");
				if (strings.size() == 3) {
					item.name = strings[2];
					item.script = strings[0];
					item.line = strings[1].to_int();
				}

			} else {
				item.name = "SigErr " + itos(signature);
			}

			item.calls = calls;
			item.self = self;
			item.total = total;
			funcs.items[i] = item;
		}

		metric.categories.push_back(funcs);

		if (p_msg == "profile_frame")
			profiler->add_frame_metric(metric, false);
		else
			profiler->add_frame_metric(metric, true);

	} else if (p_msg == "kill_me") {

		editor->call_deferred("stop_child_process");
	}
}

void ScriptEditorDebugger::_set_reason_text(const String &p_reason, MessageType p_type) {
	switch (p_type) {
		case MESSAGE_ERROR:
			reason->add_color_override("font_color", get_color("error_color", "Editor"));
			break;
		case MESSAGE_WARNING:
			reason->add_color_override("font_color", get_color("warning_color", "Editor"));
			break;
		default:
			reason->add_color_override("font_color", get_color("success_color", "Editor"));
	}
	reason->set_text(p_reason);
	reason->set_tooltip(p_reason);
}

void ScriptEditorDebugger::_performance_select() {

	perf_draw->update();
}

void ScriptEditorDebugger::_performance_draw() {

	Vector<int> which;
	for (int i = 0; i < perf_items.size(); i++) {

		if (perf_items[i]->is_checked(0))
			which.push_back(i);
	}

	Ref<Font> graph_font = get_font("font", "TextEdit");

	if (which.empty()) {
		perf_draw->draw_string(graph_font, Point2(0, graph_font->get_ascent()), TTR("Pick one or more items from the list to display the graph."), get_color("font_color", "Label"), perf_draw->get_size().x);
		return;
	}

	Ref<StyleBox> graph_sb = get_stylebox("normal", "TextEdit");

	int cols = Math::ceil(Math::sqrt((float)which.size()));
	int rows = Math::ceil((float)which.size() / cols);
	if (which.size() == 1)
		rows = 1;

	int margin = 3;
	int point_sep = 5;
	Size2i s = Size2i(perf_draw->get_size()) / Size2i(cols, rows);
	for (int i = 0; i < which.size(); i++) {

		Point2i p(i % cols, i / cols);
		Rect2i r(p * s, s);
		r.position += Point2(margin, margin);
		r.size -= Point2(margin, margin) * 2.0;
		perf_draw->draw_style_box(graph_sb, r);
		r.position += graph_sb->get_offset();
		r.size -= graph_sb->get_minimum_size();
		int pi = which[i];
		Color c = get_color("accent_color", "Editor");
		float h = (float)which[i] / (float)(perf_items.size());
		c.set_hsv(Math::fmod(h + 0.4, 0.9), c.get_s() * 0.9, c.get_v() * 1.4);

		c.a = 0.6;
		perf_draw->draw_string(graph_font, r.position + Point2(0, graph_font->get_ascent()), perf_items[pi]->get_text(0), c, r.size.x);
		c.a = 0.9;
		perf_draw->draw_string(graph_font, r.position + Point2(0, graph_font->get_ascent() + graph_font->get_height()), perf_items[pi]->get_text(1), c, r.size.y);

		float spacing = point_sep / float(cols);
		float from = r.size.width;

		List<Vector<float> >::Element *E = perf_history.front();
		float prev = -1;
		while (from >= 0 && E) {

			float m = perf_max[pi];
			if (m == 0)
				m = 0.00001;
			float h = E->get()[pi] / m;
			h = (1.0 - h) * r.size.y;

			c.a = 0.7;
			if (E != perf_history.front())
				perf_draw->draw_line(r.position + Point2(from, h), r.position + Point2(from + spacing, prev), c, 2.0);
			prev = h;
			E = E->next();
			from -= spacing;
		}
	}
}

void ScriptEditorDebugger::_notification(int p_what) {

	switch (p_what) {

		case NOTIFICATION_ENTER_TREE: {

			inspector->edit(variables);

			copy->set_icon(get_icon("ActionCopy", "EditorIcons"));

			step->set_icon(get_icon("DebugStep", "EditorIcons"));
			next->set_icon(get_icon("DebugNext", "EditorIcons"));
			back->set_icon(get_icon("Back", "EditorIcons"));
			forward->set_icon(get_icon("Forward", "EditorIcons"));
			dobreak->set_icon(get_icon("Pause", "EditorIcons"));
			docontinue->set_icon(get_icon("DebugContinue", "EditorIcons"));
			//scene_tree_refresh->set_icon( get_icon("Reload","EditorIcons"));
			le_set->connect("pressed", this, "_live_edit_set");
			le_clear->connect("pressed", this, "_live_edit_clear");
			error_list->connect("item_selected", this, "_error_selected");
			error_stack->connect("item_selected", this, "_error_stack_selected");
			vmem_refresh->set_icon(get_icon("Reload", "EditorIcons"));

			reason->add_color_override("font_color", get_color("error_color", "Editor"));

		} break;
		case NOTIFICATION_PROCESS: {

			if (connection.is_valid()) {

				inspect_scene_tree_timeout -= get_process_delta_time();
				if (inspect_scene_tree_timeout < 0) {
					inspect_scene_tree_timeout = EditorSettings::get_singleton()->get("debugger/remote_scene_tree_refresh_interval");
					if (inspect_scene_tree->is_visible_in_tree()) {
						_scene_tree_request();
					}
				}

				inspect_edited_object_timeout -= get_process_delta_time();
				if (inspect_edited_object_timeout < 0) {
					inspect_edited_object_timeout = EditorSettings::get_singleton()->get("debugger/remote_inspect_refresh_interval");
					if (inspected_object_id) {
						if (ScriptEditorDebuggerInspectedObject *obj = Object::cast_to<ScriptEditorDebuggerInspectedObject>(ObjectDB::get_instance(editor->get_editor_history()->get_current()))) {
							if (obj->remote_object_id == inspected_object_id) {
								//take the chance and re-inspect selected object
								Array msg;
								msg.push_back("inspect_object");
								msg.push_back(inspected_object_id);
								ppeer->put_var(msg);
							}
						}
					}
				}
			}

			if (error_count != last_error_count) {

				if (error_count == 0) {
					error_split->set_name(TTR("Errors"));
					debugger_button->set_text(TTR("Debugger"));
					debugger_button->set_icon(Ref<Texture>());
					tabs->set_tab_icon(error_split->get_index(), Ref<Texture>());
				} else {
					error_split->set_name(TTR("Errors") + " (" + itos(error_count) + ")");
					debugger_button->set_text(TTR("Debugger") + " (" + itos(error_count) + ")");
					debugger_button->set_icon(get_icon("Error", "EditorIcons"));
					tabs->set_tab_icon(error_split->get_index(), get_icon("Error", "EditorIcons"));
				}
				last_error_count = error_count;
			}

			if (connection.is_null()) {

				if (server->is_connection_available()) {

					connection = server->take_connection();
					if (connection.is_null())
						break;

					EditorNode::get_log()->add_message("** Debug Process Started **");

					ppeer->set_stream_peer(connection);

					//EditorNode::get_singleton()->make_bottom_panel_item_visible(this);
					//emit_signal("show_debugger",true);

					dobreak->set_disabled(false);
					tabs->set_current_tab(0);

					_set_reason_text(TTR("Child Process Connected"), MESSAGE_SUCCESS);
					profiler->clear();

					inspect_scene_tree->clear();
					le_set->set_disabled(true);
					le_clear->set_disabled(false);
					error_list->clear();
					error_stack->clear();
					error_count = 0;
					profiler_signature.clear();
					//live_edit_root->set_text("/root");

					EditorNode::get_singleton()->get_pause_button()->set_pressed(false);
					EditorNode::get_singleton()->get_pause_button()->set_disabled(false);

					update_live_edit_root();
					if (profiler->is_profiling()) {
						_profiler_activate(true);
					}

				} else {

					break;
				}
			};

			if (!connection->is_connected_to_host()) {
				stop();
				editor->notify_child_process_exited(); //somehow, exited
				break;
			};

			if (ppeer->get_available_packet_count() <= 0) {
				break;
			};

			const uint64_t until = OS::get_singleton()->get_ticks_msec() + 20;

			while (ppeer->get_available_packet_count() > 0) {

				if (pending_in_queue) {

					int todo = MIN(ppeer->get_available_packet_count(), pending_in_queue);

					for (int i = 0; i < todo; i++) {

						Variant cmd;
						Error ret = ppeer->get_var(cmd);
						if (ret != OK) {
							stop();
							ERR_FAIL_COND(ret != OK);
						}

						message.push_back(cmd);
						pending_in_queue--;
					}

					if (pending_in_queue == 0) {
						_parse_message(message_type, message);
						message.clear();
					}

				} else {

					if (ppeer->get_available_packet_count() >= 2) {

						Variant cmd;
						Error ret = ppeer->get_var(cmd);
						if (ret != OK) {
							stop();
							ERR_FAIL_COND(ret != OK);
						}
						if (cmd.get_type() != Variant::STRING) {
							stop();
							ERR_FAIL_COND(cmd.get_type() != Variant::STRING);
						}

						message_type = cmd;
						//print_line("GOT: "+message_type);

						ret = ppeer->get_var(cmd);
						if (ret != OK) {
							stop();
							ERR_FAIL_COND(ret != OK);
						}
						if (cmd.get_type() != Variant::INT) {
							stop();
							ERR_FAIL_COND(cmd.get_type() != Variant::INT);
						}

						pending_in_queue = cmd;

						if (pending_in_queue == 0) {
							_parse_message(message_type, Array());
							message.clear();
						}

					} else {

						break;
					}
				}

				if (OS::get_singleton()->get_ticks_msec() > until)
					break;
			}

		} break;
		case EditorSettings::NOTIFICATION_EDITOR_SETTINGS_CHANGED: {
			tabs->add_style_override("panel", editor->get_gui_base()->get_stylebox("DebuggerPanel", "EditorStyles"));
			tabs->add_style_override("tab_fg", editor->get_gui_base()->get_stylebox("DebuggerTabFG", "EditorStyles"));
			tabs->add_style_override("tab_bg", editor->get_gui_base()->get_stylebox("DebuggerTabBG", "EditorStyles"));
			tabs->set_margin(MARGIN_LEFT, -EditorNode::get_singleton()->get_gui_base()->get_stylebox("BottomPanelDebuggerOverride", "EditorStyles")->get_margin(MARGIN_LEFT));
			tabs->set_margin(MARGIN_RIGHT, EditorNode::get_singleton()->get_gui_base()->get_stylebox("BottomPanelDebuggerOverride", "EditorStyles")->get_margin(MARGIN_RIGHT));

			bool enable_rl = EditorSettings::get_singleton()->get("docks/scene_tree/draw_relationship_lines");
			Color rl_color = EditorSettings::get_singleton()->get("docks/scene_tree/relationship_line_color");

			if (enable_rl) {
				inspect_scene_tree->add_constant_override("draw_relationship_lines", 1);
				inspect_scene_tree->add_color_override("relationship_line_color", rl_color);
			} else
				inspect_scene_tree->add_constant_override("draw_relationship_lines", 0);
		} break;
	}
}

void ScriptEditorDebugger::start() {

	stop();

	if (is_visible_in_tree()) {
		EditorNode::get_singleton()->make_bottom_panel_item_visible(this);
	}

	perf_history.clear();
	for (int i = 0; i < Performance::MONITOR_MAX; i++) {

		perf_max[i] = 0;
	}

	int remote_port = (int)EditorSettings::get_singleton()->get("network/debug/remote_port");
	if (server->listen(remote_port) != OK) {
		EditorNode::get_log()->add_message(String("Error listening on port ") + itos(remote_port), true);
		return;
	}

	EditorNode::get_singleton()->get_scene_tree_dock()->show_tab_buttons();
	auto_switch_remote_scene_tree = (bool)EditorSettings::get_singleton()->get("debugger/auto_switch_to_remote_scene_tree");
	if (auto_switch_remote_scene_tree) {
		EditorNode::get_singleton()->get_scene_tree_dock()->show_remote_tree();
	}

	set_process(true);
	breaked = false;
}

void ScriptEditorDebugger::pause() {
}

void ScriptEditorDebugger::unpause() {
}

void ScriptEditorDebugger::stop() {

	set_process(false);
	breaked = false;

	server->stop();

	ppeer->set_stream_peer(Ref<StreamPeer>());

	if (connection.is_valid()) {
		EditorNode::get_log()->add_message("** Debug Process Stopped **");
		connection.unref();
	}

	pending_in_queue = 0;
	message.clear();

	node_path_cache.clear();
	res_path_cache.clear();
	profiler_signature.clear();
	le_clear->set_disabled(false);
	le_set->set_disabled(true);
	profiler->set_enabled(true);

	inspect_scene_tree->clear();

	EditorNode::get_singleton()->get_pause_button()->set_pressed(false);
	EditorNode::get_singleton()->get_pause_button()->set_disabled(true);
	EditorNode::get_singleton()->get_scene_tree_dock()->hide_remote_tree();
	EditorNode::get_singleton()->get_scene_tree_dock()->hide_tab_buttons();

	if (hide_on_stop) {
		if (is_visible_in_tree())
			EditorNode::get_singleton()->hide_bottom_panel();
		emit_signal("show_debugger", false);
	}
}

void ScriptEditorDebugger::_profiler_activate(bool p_enable) {

	if (!connection.is_valid())
		return;

	if (p_enable) {
		profiler_signature.clear();
		Array msg;
		msg.push_back("start_profiling");
		int max_funcs = EditorSettings::get_singleton()->get("debugger/profiler_frame_max_functions");
		max_funcs = CLAMP(max_funcs, 16, 512);
		msg.push_back(max_funcs);
		ppeer->put_var(msg);

		print_line("BEGIN PROFILING!");

	} else {
		Array msg;
		msg.push_back("stop_profiling");
		ppeer->put_var(msg);

		print_line("END PROFILING!");
	}
}

void ScriptEditorDebugger::_profiler_seeked() {

	if (!connection.is_valid() || !connection->is_connected_to_host())
		return;

	if (breaked)
		return;
	debug_break();
}

void ScriptEditorDebugger::_stack_dump_frame_selected() {

	TreeItem *ti = stack_dump->get_selected();
	if (!ti)
		return;

	Dictionary d = ti->get_metadata(0);

	stack_script = ResourceLoader::load(d["file"]);
	emit_signal("goto_script_line", stack_script, int(d["line"]) - 1);
	stack_script.unref();

	if (connection.is_valid() && connection->is_connected_to_host()) {
		Array msg;
		msg.push_back("get_stack_frame_vars");
		msg.push_back(d["frame"]);
		ppeer->put_var(msg);
	} else {
		inspector->edit(NULL);
	}
}

void ScriptEditorDebugger::_output_clear() {

	//output->clear();
	//output->push_color(Color(0,0,0));
}

String ScriptEditorDebugger::get_var_value(const String &p_var) const {
	if (!breaked)
		return String();
	return variables->get_var_value(p_var);
}

int ScriptEditorDebugger::_get_node_path_cache(const NodePath &p_path) {

	const int *r = node_path_cache.getptr(p_path);
	if (r)
		return *r;

	last_path_id++;

	node_path_cache[p_path] = last_path_id;
	Array msg;
	msg.push_back("live_node_path");
	msg.push_back(p_path);
	msg.push_back(last_path_id);
	ppeer->put_var(msg);

	return last_path_id;
}

int ScriptEditorDebugger::_get_res_path_cache(const String &p_path) {

	Map<String, int>::Element *E = res_path_cache.find(p_path);

	if (E)
		return E->get();

	last_path_id++;

	res_path_cache[p_path] = last_path_id;
	Array msg;
	msg.push_back("live_res_path");
	msg.push_back(p_path);
	msg.push_back(last_path_id);
	ppeer->put_var(msg);

	return last_path_id;
}

void ScriptEditorDebugger::_method_changed(Object *p_base, const StringName &p_name, VARIANT_ARG_DECLARE) {

	if (!p_base || !live_debug || !connection.is_valid() || !editor->get_edited_scene())
		return;

	Node *node = Object::cast_to<Node>(p_base);

	VARIANT_ARGPTRS

	for (int i = 0; i < VARIANT_ARG_MAX; i++) {
		//no pointers, sorry
		if (argptr[i] && (argptr[i]->get_type() == Variant::OBJECT || argptr[i]->get_type() == Variant::_RID))
			return;
	}

	if (node) {

		NodePath path = editor->get_edited_scene()->get_path_to(node);
		int pathid = _get_node_path_cache(path);

		Array msg;
		msg.push_back("live_node_call");
		msg.push_back(pathid);
		msg.push_back(p_name);
		for (int i = 0; i < VARIANT_ARG_MAX; i++) {
			//no pointers, sorry
			msg.push_back(*argptr[i]);
		}
		ppeer->put_var(msg);

		return;
	}

	Resource *res = Object::cast_to<Resource>(p_base);

	if (res && res->get_path() != String()) {

		String respath = res->get_path();
		int pathid = _get_res_path_cache(respath);

		Array msg;
		msg.push_back("live_res_call");
		msg.push_back(pathid);
		msg.push_back(p_name);
		for (int i = 0; i < VARIANT_ARG_MAX; i++) {
			//no pointers, sorry
			msg.push_back(*argptr[i]);
		}
		ppeer->put_var(msg);

		return;
	}

	//print_line("method");
}

void ScriptEditorDebugger::_property_changed(Object *p_base, const StringName &p_property, const Variant &p_value) {

	if (!p_base || !live_debug || !connection.is_valid() || !editor->get_edited_scene())
		return;

	Node *node = Object::cast_to<Node>(p_base);

	if (node) {

		NodePath path = editor->get_edited_scene()->get_path_to(node);
		int pathid = _get_node_path_cache(path);

		if (p_value.is_ref()) {
			Ref<Resource> res = p_value;
			if (res.is_valid() && res->get_path() != String()) {

				Array msg;
				msg.push_back("live_node_prop_res");
				msg.push_back(pathid);
				msg.push_back(p_property);
				msg.push_back(res->get_path());
				ppeer->put_var(msg);
			}
		} else {

			Array msg;
			msg.push_back("live_node_prop");
			msg.push_back(pathid);
			msg.push_back(p_property);
			msg.push_back(p_value);
			ppeer->put_var(msg);
		}

		return;
	}

	Resource *res = Object::cast_to<Resource>(p_base);

	if (res && res->get_path() != String()) {

		String respath = res->get_path();
		int pathid = _get_res_path_cache(respath);

		if (p_value.is_ref()) {
			Ref<Resource> res = p_value;
			if (res.is_valid() && res->get_path() != String()) {

				Array msg;
				msg.push_back("live_res_prop_res");
				msg.push_back(pathid);
				msg.push_back(p_property);
				msg.push_back(res->get_path());
				ppeer->put_var(msg);
			}
		} else {

			Array msg;
			msg.push_back("live_res_prop");
			msg.push_back(pathid);
			msg.push_back(p_property);
			msg.push_back(p_value);
			ppeer->put_var(msg);
		}

		return;
	}

	//print_line("prop");
}

void ScriptEditorDebugger::_method_changeds(void *p_ud, Object *p_base, const StringName &p_name, VARIANT_ARG_DECLARE) {

	ScriptEditorDebugger *sed = (ScriptEditorDebugger *)p_ud;
	sed->_method_changed(p_base, p_name, VARIANT_ARG_PASS);
}

void ScriptEditorDebugger::_property_changeds(void *p_ud, Object *p_base, const StringName &p_property, const Variant &p_value) {

	ScriptEditorDebugger *sed = (ScriptEditorDebugger *)p_ud;
	sed->_property_changed(p_base, p_property, p_value);
}

void ScriptEditorDebugger::set_live_debugging(bool p_enable) {

	live_debug = p_enable;
}

void ScriptEditorDebugger::_live_edit_set() {

	if (!connection.is_valid())
		return;

	TreeItem *ti = inspect_scene_tree->get_selected();
	if (!ti)
		return;
	String path;

	while (ti) {
		String lp = ti->get_text(0);
		path = "/" + lp + path;
		ti = ti->get_parent();
	}

	NodePath np = path;

	editor->get_editor_data().set_edited_scene_live_edit_root(np);

	update_live_edit_root();
}

void ScriptEditorDebugger::_live_edit_clear() {

	NodePath np = NodePath("/root");
	editor->get_editor_data().set_edited_scene_live_edit_root(np);

	update_live_edit_root();
}

void ScriptEditorDebugger::update_live_edit_root() {

	NodePath np = editor->get_editor_data().get_edited_scene_live_edit_root();

	if (connection.is_valid()) {
		Array msg;
		msg.push_back("live_set_root");
		msg.push_back(np);
		if (editor->get_edited_scene())
			msg.push_back(editor->get_edited_scene()->get_filename());
		else
			msg.push_back("");
		ppeer->put_var(msg);
	}
	live_edit_root->set_text(np);
}

void ScriptEditorDebugger::live_debug_create_node(const NodePath &p_parent, const String &p_type, const String &p_name) {

	if (live_debug && connection.is_valid()) {
		Array msg;
		msg.push_back("live_create_node");
		msg.push_back(p_parent);
		msg.push_back(p_type);
		msg.push_back(p_name);
		ppeer->put_var(msg);
	}
}

void ScriptEditorDebugger::live_debug_instance_node(const NodePath &p_parent, const String &p_path, const String &p_name) {

	if (live_debug && connection.is_valid()) {
		Array msg;
		msg.push_back("live_instance_node");
		msg.push_back(p_parent);
		msg.push_back(p_path);
		msg.push_back(p_name);
		ppeer->put_var(msg);
	}
}
void ScriptEditorDebugger::live_debug_remove_node(const NodePath &p_at) {

	if (live_debug && connection.is_valid()) {
		Array msg;
		msg.push_back("live_remove_node");
		msg.push_back(p_at);
		ppeer->put_var(msg);
	}
}
void ScriptEditorDebugger::live_debug_remove_and_keep_node(const NodePath &p_at, ObjectID p_keep_id) {

	if (live_debug && connection.is_valid()) {
		Array msg;
		msg.push_back("live_remove_and_keep_node");
		msg.push_back(p_at);
		msg.push_back(p_keep_id);
		ppeer->put_var(msg);
	}
}
void ScriptEditorDebugger::live_debug_restore_node(ObjectID p_id, const NodePath &p_at, int p_at_pos) {

	if (live_debug && connection.is_valid()) {
		Array msg;
		msg.push_back("live_restore_node");
		msg.push_back(p_id);
		msg.push_back(p_at);
		msg.push_back(p_at_pos);
		ppeer->put_var(msg);
	}
}
void ScriptEditorDebugger::live_debug_duplicate_node(const NodePath &p_at, const String &p_new_name) {

	if (live_debug && connection.is_valid()) {
		Array msg;
		msg.push_back("live_duplicate_node");
		msg.push_back(p_at);
		msg.push_back(p_new_name);
		ppeer->put_var(msg);
	}
}
void ScriptEditorDebugger::live_debug_reparent_node(const NodePath &p_at, const NodePath &p_new_place, const String &p_new_name, int p_at_pos) {

	if (live_debug && connection.is_valid()) {
		Array msg;
		msg.push_back("live_reparent_node");
		msg.push_back(p_at);
		msg.push_back(p_new_place);
		msg.push_back(p_new_name);
		msg.push_back(p_at_pos);
		ppeer->put_var(msg);
	}
}

void ScriptEditorDebugger::set_breakpoint(const String &p_path, int p_line, bool p_enabled) {

	if (connection.is_valid()) {
		Array msg;
		msg.push_back("breakpoint");
		msg.push_back(p_path);
		msg.push_back(p_line);
		msg.push_back(p_enabled);
		ppeer->put_var(msg);
	}
}

void ScriptEditorDebugger::reload_scripts() {

	if (connection.is_valid()) {
		Array msg;
		msg.push_back("reload_scripts");
		ppeer->put_var(msg);
	}
}

void ScriptEditorDebugger::_error_selected(int p_idx) {

	error_stack->clear();
	Array st = error_list->get_item_metadata(p_idx);
	for (int i = 0; i < st.size(); i += 3) {

		String script = st[i];
		String func = st[i + 1];
		int line = st[i + 2];
		Array md;
		md.push_back(st[i]);
		md.push_back(st[i + 1]);
		md.push_back(st[i + 2]);

		String str = func;
		String tooltip_str = TTR("Function:") + " " + func;
		if (script.length() > 0) {
			str += " in " + script.get_file();
			tooltip_str = TTR("File:") + " " + script + "\n" + tooltip_str;
			if (line > 0) {
				str += ":line " + itos(line);
				tooltip_str += "\n" + TTR("Line:") + " " + itos(line);
			}
		}

		error_stack->add_item(str);
		error_stack->set_item_metadata(error_stack->get_item_count() - 1, md);
		error_stack->set_item_tooltip(error_stack->get_item_count() - 1, tooltip_str);
	}
}

void ScriptEditorDebugger::_error_stack_selected(int p_idx) {

	Array arr = error_stack->get_item_metadata(p_idx);
	if (arr.size() != 3)
		return;

	Ref<Script> s = ResourceLoader::load(arr[0]);
	emit_signal("goto_script_line", s, int(arr[2]) - 1);
}

void ScriptEditorDebugger::set_hide_on_stop(bool p_hide) {

	hide_on_stop = p_hide;
}

bool ScriptEditorDebugger::get_debug_with_external_editor() const {

	return enable_external_editor;
}

void ScriptEditorDebugger::set_debug_with_external_editor(bool p_enabled) {

	enable_external_editor = p_enabled;
}

Ref<Script> ScriptEditorDebugger::get_dump_stack_script() const {

	return stack_script;
}

void ScriptEditorDebugger::_paused() {

	ERR_FAIL_COND(connection.is_null());
	ERR_FAIL_COND(!connection->is_connected_to_host());

	if (!breaked && EditorNode::get_singleton()->get_pause_button()->is_pressed()) {
		debug_break();
	}

	if (breaked && !EditorNode::get_singleton()->get_pause_button()->is_pressed()) {
		debug_continue();
	}
}

void ScriptEditorDebugger::_set_remote_object(ObjectID p_id, ScriptEditorDebuggerInspectedObject *p_obj) {

	if (remote_objects.has(p_id))
		memdelete(remote_objects[p_id]);
	remote_objects[p_id] = p_obj;
}

void ScriptEditorDebugger::_clear_remote_objects() {

	for (Map<ObjectID, ScriptEditorDebuggerInspectedObject *>::Element *E = remote_objects.front(); E; E = E->next()) {
		if (editor->get_editor_history()->get_current() == E->value()->get_instance_id()) {
			editor->push_item(NULL);
		}
		memdelete(E->value());
	}
	remote_objects.clear();
}

void ScriptEditorDebugger::_clear_errors_list() {

	error_list->clear();
	error_count = 0;
	_notification(NOTIFICATION_PROCESS);
}

// Right click on specific file(s) or folder(s).
void ScriptEditorDebugger::_error_list_item_rmb_selected(int p_item, const Vector2 &p_pos) {

	item_menu->clear();
	item_menu->set_size(Size2(1, 1));

	// Allow specific actions only on one item.
	bool single_item_selected = error_list->get_selected_items().size() == 1;

	if (single_item_selected) {
		item_menu->add_icon_item(get_icon("ActionCopy", "EditorIcons"), TTR("Copy Error"), ITEM_MENU_COPY_ERROR);
	}

	if (item_menu->get_item_count() > 0) {
		item_menu->set_position(error_list->get_global_position() + p_pos);
		item_menu->popup();
	}
}

void ScriptEditorDebugger::_item_menu_id_pressed(int p_option) {

	switch (p_option) {

		case ITEM_MENU_COPY_ERROR: {
			String title = error_list->get_item_text(error_list->get_current());
			String desc = error_list->get_item_tooltip(error_list->get_current());

			OS::get_singleton()->set_clipboard(title + "\n----------\n" + desc);
		} break;
	}
}

void ScriptEditorDebugger::_bind_methods() {

	ClassDB::bind_method(D_METHOD("_stack_dump_frame_selected"), &ScriptEditorDebugger::_stack_dump_frame_selected);

	ClassDB::bind_method(D_METHOD("debug_copy"), &ScriptEditorDebugger::debug_copy);

	ClassDB::bind_method(D_METHOD("debug_next"), &ScriptEditorDebugger::debug_next);
	ClassDB::bind_method(D_METHOD("debug_step"), &ScriptEditorDebugger::debug_step);
	ClassDB::bind_method(D_METHOD("debug_break"), &ScriptEditorDebugger::debug_break);
	ClassDB::bind_method(D_METHOD("debug_continue"), &ScriptEditorDebugger::debug_continue);
	ClassDB::bind_method(D_METHOD("_output_clear"), &ScriptEditorDebugger::_output_clear);
	ClassDB::bind_method(D_METHOD("_performance_draw"), &ScriptEditorDebugger::_performance_draw);
	ClassDB::bind_method(D_METHOD("_performance_select"), &ScriptEditorDebugger::_performance_select);
	ClassDB::bind_method(D_METHOD("_scene_tree_request"), &ScriptEditorDebugger::_scene_tree_request);
	ClassDB::bind_method(D_METHOD("_video_mem_request"), &ScriptEditorDebugger::_video_mem_request);
	ClassDB::bind_method(D_METHOD("_live_edit_set"), &ScriptEditorDebugger::_live_edit_set);
	ClassDB::bind_method(D_METHOD("_live_edit_clear"), &ScriptEditorDebugger::_live_edit_clear);

	ClassDB::bind_method(D_METHOD("_error_selected"), &ScriptEditorDebugger::_error_selected);
	ClassDB::bind_method(D_METHOD("_error_stack_selected"), &ScriptEditorDebugger::_error_stack_selected);
	ClassDB::bind_method(D_METHOD("_profiler_activate"), &ScriptEditorDebugger::_profiler_activate);
	ClassDB::bind_method(D_METHOD("_profiler_seeked"), &ScriptEditorDebugger::_profiler_seeked);
	ClassDB::bind_method(D_METHOD("_clear_errors_list"), &ScriptEditorDebugger::_clear_errors_list);

	ClassDB::bind_method(D_METHOD("_error_list_item_rmb_selected"), &ScriptEditorDebugger::_error_list_item_rmb_selected);
	ClassDB::bind_method(D_METHOD("_item_menu_id_pressed"), &ScriptEditorDebugger::_item_menu_id_pressed);

	ClassDB::bind_method(D_METHOD("_paused"), &ScriptEditorDebugger::_paused);

	ClassDB::bind_method(D_METHOD("_scene_tree_selected"), &ScriptEditorDebugger::_scene_tree_selected);
	ClassDB::bind_method(D_METHOD("_scene_tree_folded"), &ScriptEditorDebugger::_scene_tree_folded);

	ClassDB::bind_method(D_METHOD("live_debug_create_node"), &ScriptEditorDebugger::live_debug_create_node);
	ClassDB::bind_method(D_METHOD("live_debug_instance_node"), &ScriptEditorDebugger::live_debug_instance_node);
	ClassDB::bind_method(D_METHOD("live_debug_remove_node"), &ScriptEditorDebugger::live_debug_remove_node);
	ClassDB::bind_method(D_METHOD("live_debug_remove_and_keep_node"), &ScriptEditorDebugger::live_debug_remove_and_keep_node);
	ClassDB::bind_method(D_METHOD("live_debug_restore_node"), &ScriptEditorDebugger::live_debug_restore_node);
	ClassDB::bind_method(D_METHOD("live_debug_duplicate_node"), &ScriptEditorDebugger::live_debug_duplicate_node);
	ClassDB::bind_method(D_METHOD("live_debug_reparent_node"), &ScriptEditorDebugger::live_debug_reparent_node);
	ClassDB::bind_method(D_METHOD("_scene_tree_property_select_object"), &ScriptEditorDebugger::_scene_tree_property_select_object);
	ClassDB::bind_method(D_METHOD("_scene_tree_property_value_edited"), &ScriptEditorDebugger::_scene_tree_property_value_edited);

	ADD_SIGNAL(MethodInfo("goto_script_line"));
	ADD_SIGNAL(MethodInfo("breaked", PropertyInfo(Variant::BOOL, "reallydid"), PropertyInfo(Variant::BOOL, "can_debug")));
	ADD_SIGNAL(MethodInfo("show_debugger", PropertyInfo(Variant::BOOL, "reallydid")));
}

ScriptEditorDebugger::ScriptEditorDebugger(EditorNode *p_editor) {

	ppeer = Ref<PacketPeerStream>(memnew(PacketPeerStream));
	ppeer->set_input_buffer_max_size(1024 * 1024 * 8); //8mb should be enough
	editor = p_editor;
	editor->get_property_editor()->connect("object_id_selected", this, "_scene_tree_property_select_object");

	tabs = memnew(TabContainer);
	tabs->set_tab_align(TabContainer::ALIGN_LEFT);
	tabs->add_style_override("panel", editor->get_gui_base()->get_stylebox("DebuggerPanel", "EditorStyles"));
	tabs->add_style_override("tab_fg", editor->get_gui_base()->get_stylebox("DebuggerTabFG", "EditorStyles"));
	tabs->add_style_override("tab_bg", editor->get_gui_base()->get_stylebox("DebuggerTabBG", "EditorStyles"));

	tabs->set_anchors_and_margins_preset(Control::PRESET_WIDE);
	tabs->set_margin(MARGIN_LEFT, -editor->get_gui_base()->get_stylebox("BottomPanelDebuggerOverride", "EditorStyles")->get_margin(MARGIN_LEFT));
	tabs->set_margin(MARGIN_RIGHT, editor->get_gui_base()->get_stylebox("BottomPanelDebuggerOverride", "EditorStyles")->get_margin(MARGIN_RIGHT));
	add_child(tabs);

	{ //debugger
		VBoxContainer *vbc = memnew(VBoxContainer);
		vbc->set_name(TTR("Debugger"));
		//tabs->add_child(vbc);
		Control *dbg = vbc;

		HBoxContainer *hbc = memnew(HBoxContainer);
		vbc->add_child(hbc);

		reason = memnew(Label);
		reason->set_text("");
		hbc->add_child(reason);
		reason->set_h_size_flags(SIZE_EXPAND_FILL);

		hbc->add_child(memnew(VSeparator));

		copy = memnew(ToolButton);
		hbc->add_child(copy);
		copy->set_tooltip(TTR("Copy Error"));
		copy->connect("pressed", this, "debug_copy");

		hbc->add_child(memnew(VSeparator));

		step = memnew(ToolButton);
		hbc->add_child(step);
		step->set_tooltip(TTR("Step Into"));
		step->connect("pressed", this, "debug_step");

		next = memnew(ToolButton);
		hbc->add_child(next);
		next->set_tooltip(TTR("Step Over"));
		next->connect("pressed", this, "debug_next");

		hbc->add_child(memnew(VSeparator));

		dobreak = memnew(ToolButton);
		hbc->add_child(dobreak);
		dobreak->set_tooltip(TTR("Break"));
		dobreak->connect("pressed", this, "debug_break");

		docontinue = memnew(ToolButton);
		hbc->add_child(docontinue);
		docontinue->set_tooltip(TTR("Continue"));
		docontinue->connect("pressed", this, "debug_continue");

		back = memnew(Button);
		hbc->add_child(back);
		back->set_tooltip(TTR("Inspect Previous Instance"));
		back->hide();

		forward = memnew(Button);
		hbc->add_child(forward);
		forward->set_tooltip(TTR("Inspect Next Instance"));
		forward->hide();

		HSplitContainer *sc = memnew(HSplitContainer);
		vbc->add_child(sc);
		sc->set_v_size_flags(SIZE_EXPAND_FILL);

		stack_dump = memnew(Tree);
		stack_dump->set_allow_reselect(true);
		stack_dump->set_columns(1);
		stack_dump->set_column_titles_visible(true);
		stack_dump->set_column_title(0, TTR("Stack Frames"));
		stack_dump->set_h_size_flags(SIZE_EXPAND_FILL);
		stack_dump->set_hide_root(true);
		stack_dump->connect("cell_selected", this, "_stack_dump_frame_selected");
		sc->add_child(stack_dump);

		inspector = memnew(PropertyEditor);
		inspector->set_h_size_flags(SIZE_EXPAND_FILL);
		inspector->hide_top_label();
		inspector->get_scene_tree()->set_column_title(0, TTR("Variable"));
		inspector->set_enable_capitalize_paths(false);
		inspector->set_read_only(true);
		inspector->connect("object_id_selected", this, "_scene_tree_property_select_object");
		sc->add_child(inspector);

		server = TCP_Server::create_ref();

		pending_in_queue = 0;

		variables = memnew(ScriptEditorDebuggerVariables);

		breaked = false;

		tabs->add_child(dbg);
	}

	{ //errors

		error_split = memnew(HSplitContainer);
		VBoxContainer *errvb = memnew(VBoxContainer);
		HBoxContainer *errhb = memnew(HBoxContainer);
		errvb->set_h_size_flags(SIZE_EXPAND_FILL);
		Label *velb = memnew(Label(TTR("Errors:")));
		velb->set_h_size_flags(SIZE_EXPAND_FILL);
		errhb->add_child(velb);

		clearbutton = memnew(Button);
		clearbutton->set_text(TTR("Clear"));
		clearbutton->connect("pressed", this, "_clear_errors_list");
		errhb->add_child(clearbutton);
		errvb->add_child(errhb);

		error_list = memnew(ItemList);
		error_list->set_v_size_flags(SIZE_EXPAND_FILL);
		error_list->set_h_size_flags(SIZE_EXPAND_FILL);
		error_list->connect("item_rmb_selected", this, "_error_list_item_rmb_selected");
		error_list->set_allow_rmb_select(true);
		error_list->set_autoscroll_to_bottom(true);

		item_menu = memnew(PopupMenu);
		item_menu->connect("id_pressed", this, "_item_menu_id_pressed");
		error_list->add_child(item_menu);

		errvb->add_child(error_list);

		error_split->add_child(errvb);

		errvb = memnew(VBoxContainer);
		errvb->set_h_size_flags(SIZE_EXPAND_FILL);
		error_stack = memnew(ItemList);
		errvb->add_margin_child(TTR("Stack Trace (if applicable):"), error_stack, true);
		error_split->add_child(errvb);

		error_split->set_name(TTR("Errors"));
		tabs->add_child(error_split);
	}

	{ // remote scene tree

		inspect_scene_tree = memnew(Tree);
		EditorNode::get_singleton()->get_scene_tree_dock()->add_remote_tree_editor(inspect_scene_tree);
		EditorNode::get_singleton()->get_scene_tree_dock()->connect("remote_tree_selected", this, "_scene_tree_selected");
		inspect_scene_tree->set_v_size_flags(SIZE_EXPAND_FILL);
		inspect_scene_tree->connect("cell_selected", this, "_scene_tree_selected");
		inspect_scene_tree->connect("item_collapsed", this, "_scene_tree_folded");

		auto_switch_remote_scene_tree = EDITOR_DEF("debugger/auto_switch_to_remote_scene_tree", false);
		inspect_scene_tree_timeout = EDITOR_DEF("debugger/remote_scene_tree_refresh_interval", 1.0);
		inspect_edited_object_timeout = EDITOR_DEF("debugger/remote_inspect_refresh_interval", 0.2);
		inspected_object_id = 0;
		updating_scene_tree = false;
	}

	{ //profiler
		profiler = memnew(EditorProfiler);
		profiler->set_name(TTR("Profiler"));
		tabs->add_child(profiler);
		profiler->connect("enable_profiling", this, "_profiler_activate");
		profiler->connect("break_request", this, "_profiler_seeked");
	}

	{ //monitors

		HSplitContainer *hsp = memnew(HSplitContainer);

		perf_monitors = memnew(Tree);
		perf_monitors->set_columns(2);
		perf_monitors->set_column_title(0, TTR("Monitor"));
		perf_monitors->set_column_title(1, TTR("Value"));
		perf_monitors->set_column_titles_visible(true);
		hsp->add_child(perf_monitors);
		perf_monitors->connect("item_edited", this, "_performance_select");
		perf_draw = memnew(Control);
		perf_draw->connect("draw", this, "_performance_draw");
		hsp->add_child(perf_draw);
		hsp->set_name(TTR("Monitors"));
		hsp->set_split_offset(340 * EDSCALE);
		tabs->add_child(hsp);
		perf_max.resize(Performance::MONITOR_MAX);

		Map<String, TreeItem *> bases;
		TreeItem *root = perf_monitors->create_item();
		perf_monitors->set_hide_root(true);
		for (int i = 0; i < Performance::MONITOR_MAX; i++) {

			String n = Performance::get_singleton()->get_monitor_name(Performance::Monitor(i));
			Performance::MonitorType mtype = Performance::get_singleton()->get_monitor_type(Performance::Monitor(i));
			String base = n.get_slice("/", 0);
			String name = n.get_slice("/", 1);
			if (!bases.has(base)) {
				TreeItem *b = perf_monitors->create_item(root);
				b->set_text(0, base.capitalize());
				b->set_editable(0, false);
				b->set_selectable(0, false);
				b->set_expand_right(0, true);
				bases[base] = b;
			}

			TreeItem *it = perf_monitors->create_item(bases[base]);
			it->set_metadata(1, mtype);
			it->set_cell_mode(0, TreeItem::CELL_MODE_CHECK);
			it->set_editable(0, true);
			it->set_selectable(0, false);
			it->set_selectable(1, false);
			it->set_text(0, name.capitalize());
			perf_items.push_back(it);
			perf_max[i] = 0;
		}
	}

	{ //vmem inspect
		VBoxContainer *vmem_vb = memnew(VBoxContainer);
		HBoxContainer *vmem_hb = memnew(HBoxContainer);
		Label *vmlb = memnew(Label(TTR("List of Video Memory Usage by Resource:") + " "));
		vmlb->set_h_size_flags(SIZE_EXPAND_FILL);
		vmem_hb->add_child(vmlb);
		vmem_hb->add_child(memnew(Label(TTR("Total:") + " ")));
		vmem_total = memnew(LineEdit);
		vmem_total->set_editable(false);
		vmem_total->set_custom_minimum_size(Size2(100, 1) * EDSCALE);
		vmem_hb->add_child(vmem_total);
		vmem_refresh = memnew(ToolButton);
		vmem_hb->add_child(vmem_refresh);
		vmem_vb->add_child(vmem_hb);
		vmem_refresh->connect("pressed", this, "_video_mem_request");

		VBoxContainer *vmmc = memnew(VBoxContainer);
		vmem_tree = memnew(Tree);
		vmem_tree->set_v_size_flags(SIZE_EXPAND_FILL);
		vmem_tree->set_h_size_flags(SIZE_EXPAND_FILL);
		vmmc->add_child(vmem_tree);
		vmmc->set_v_size_flags(SIZE_EXPAND_FILL);
		vmem_vb->add_child(vmmc);

		vmem_vb->set_name(TTR("Video Mem"));
		vmem_tree->set_columns(4);
		vmem_tree->set_column_titles_visible(true);
		vmem_tree->set_column_title(0, TTR("Resource Path"));
		vmem_tree->set_column_expand(0, true);
		vmem_tree->set_column_expand(1, false);
		vmem_tree->set_column_title(1, TTR("Type"));
		vmem_tree->set_column_min_width(1, 100);
		vmem_tree->set_column_expand(2, false);
		vmem_tree->set_column_title(2, TTR("Format"));
		vmem_tree->set_column_min_width(2, 150);
		vmem_tree->set_column_expand(3, false);
		vmem_tree->set_column_title(3, TTR("Usage"));
		vmem_tree->set_column_min_width(3, 80);
		vmem_tree->set_hide_root(true);

		tabs->add_child(vmem_vb);
	}

	{ // misc
		GridContainer *info_left = memnew(GridContainer);
		info_left->set_columns(2);
		info_left->set_name(TTR("Misc"));
		tabs->add_child(info_left);
		clicked_ctrl = memnew(LineEdit);
		clicked_ctrl->set_h_size_flags(SIZE_EXPAND_FILL);
		info_left->add_child(memnew(Label(TTR("Clicked Control:"))));
		info_left->add_child(clicked_ctrl);
		clicked_ctrl_type = memnew(LineEdit);
		info_left->add_child(memnew(Label(TTR("Clicked Control Type:"))));
		info_left->add_child(clicked_ctrl_type);

		live_edit_root = memnew(LineEdit);
		live_edit_root->set_h_size_flags(SIZE_EXPAND_FILL);

		{
			HBoxContainer *lehb = memnew(HBoxContainer);
			Label *l = memnew(Label(TTR("Live Edit Root:")));
			info_left->add_child(l);
			lehb->add_child(live_edit_root);
			le_set = memnew(Button(TTR("Set From Tree")));
			lehb->add_child(le_set);
			le_clear = memnew(Button(TTR("Clear")));
			lehb->add_child(le_clear);
			info_left->add_child(lehb);
			le_set->set_disabled(true);
			le_clear->set_disabled(true);
		}
	}

	msgdialog = memnew(AcceptDialog);
	add_child(msgdialog);

	p_editor->get_undo_redo()->set_method_notify_callback(_method_changeds, this);
	p_editor->get_undo_redo()->set_property_notify_callback(_property_changeds, this);
	live_debug = false;
	last_path_id = false;
	error_count = 0;
	hide_on_stop = true;
	enable_external_editor = false;
	last_error_count = 0;

	EditorNode::get_singleton()->get_pause_button()->connect("pressed", this, "_paused");
}

ScriptEditorDebugger::~ScriptEditorDebugger() {

	//inspector->edit(NULL);
	memdelete(variables);

	ppeer->set_stream_peer(Ref<StreamPeer>());

	server->stop();
	_clear_remote_objects();
}
