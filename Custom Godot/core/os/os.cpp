/*************************************************************************/
/*  os.cpp                                                               */
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

#include "os.h"

#include "dir_access.h"
#include "input.h"
#include "os/file_access.h"
#include "project_settings.h"
#include "version_generated.gen.h"

#include <stdarg.h>

OS *OS::singleton = NULL;

OS *OS::get_singleton() {

	return singleton;
}

uint32_t OS::get_ticks_msec() const {
	return get_ticks_usec() / 1000;
}

uint64_t OS::get_splash_tick_msec() const {
	return _msec_splash;
}
uint64_t OS::get_unix_time() const {

	return 0;
};
uint64_t OS::get_system_time_secs() const {
	return 0;
}
void OS::debug_break(){

	// something
};

void OS::_set_logger(CompositeLogger *p_logger) {
	if (_logger) {
		memdelete(_logger);
	}
	_logger = p_logger;
}

void OS::add_logger(Logger *p_logger) {
	if (!_logger) {
		Vector<Logger *> loggers;
		loggers.push_back(p_logger);
		_logger = memnew(CompositeLogger(loggers));
	} else {
		_logger->add_logger(p_logger);
	}
}

void OS::print_error(const char *p_function, const char *p_file, int p_line, const char *p_code, const char *p_rationale, Logger::ErrorType p_type) {

	_logger->log_error(p_function, p_file, p_line, p_code, p_rationale, p_type);
}

void OS::print(const char *p_format, ...) {

	va_list argp;
	va_start(argp, p_format);

	_logger->logv(p_format, argp, false);

	va_end(argp);
};

void OS::printerr(const char *p_format, ...) {
	va_list argp;
	va_start(argp, p_format);

	_logger->logv(p_format, argp, true);

	va_end(argp);
};

void OS::set_keep_screen_on(bool p_enabled) {
	_keep_screen_on = p_enabled;
}

bool OS::is_keep_screen_on() const {
	return _keep_screen_on;
}

void OS::set_low_processor_usage_mode(bool p_enabled) {

	low_processor_usage_mode = p_enabled;
}

bool OS::is_in_low_processor_usage_mode() const {

	return low_processor_usage_mode;
}

void OS::set_low_processor_usage_mode_sleep_usec(int p_usec) {

	low_processor_usage_mode_sleep_usec = p_usec;
}

int OS::get_low_processor_usage_mode_sleep_usec() const {

	return low_processor_usage_mode_sleep_usec;
}

void OS::set_clipboard(const String &p_text) {

	_local_clipboard = p_text;
}
String OS::get_clipboard() const {

	return _local_clipboard;
}

String OS::get_executable_path() const {

	return _execpath;
}

int OS::get_process_id() const {

	return -1;
};

bool OS::is_stdout_verbose() const {

	return _verbose_stdout;
}

void OS::set_last_error(const char *p_error) {

	GLOBAL_LOCK_FUNCTION
	if (p_error == NULL)
		p_error = "Unknown Error";

	if (last_error)
		memfree(last_error);
	last_error = NULL;
	int len = 0;
	while (p_error[len++])
		;

	last_error = (char *)memalloc(len);
	for (int i = 0; i < len; i++)
		last_error[i] = p_error[i];
}

const char *OS::get_last_error() const {
	GLOBAL_LOCK_FUNCTION
	return last_error ? last_error : "";
}

void OS::dump_memory_to_file(const char *p_file) {

	//Memory::dump_static_mem_to_file(p_file);
}

static FileAccess *_OSPRF = NULL;

static void _OS_printres(Object *p_obj) {

	Resource *res = Object::cast_to<Resource>(p_obj);
	if (!res)
		return;

	String str = itos(res->get_instance_id()) + String(res->get_class()) + ":" + String(res->get_name()) + " - " + res->get_path();
	if (_OSPRF)
		_OSPRF->store_line(str);
	else
		print_line(str);
}

bool OS::has_virtual_keyboard() const {

	return false;
}

void OS::show_virtual_keyboard(const String &p_existing_text, const Rect2 &p_screen_rect) {
}

void OS::hide_virtual_keyboard() {
}

int OS::get_virtual_keyboard_height() const {
	return 0;
}

void OS::print_all_resources(String p_to_file) {

	ERR_FAIL_COND(p_to_file != "" && _OSPRF);
	if (p_to_file != "") {

		Error err;
		_OSPRF = FileAccess::open(p_to_file, FileAccess::WRITE, &err);
		if (err != OK) {
			_OSPRF = NULL;
			ERR_FAIL_COND(err != OK);
		}
	}

	ObjectDB::debug_objects(_OS_printres);

	if (p_to_file != "") {

		if (_OSPRF)
			memdelete(_OSPRF);
		_OSPRF = NULL;
	}
}

void OS::print_resources_in_use(bool p_short) {

	ResourceCache::dump(NULL, p_short);
}

void OS::dump_resources_to_file(const char *p_file) {

	ResourceCache::dump(p_file);
}

void OS::clear_last_error() {

	GLOBAL_LOCK_FUNCTION
	if (last_error)
		memfree(last_error);
	last_error = NULL;
}

void OS::set_no_window_mode(bool p_enable) {

	_no_window = p_enable;
}

bool OS::is_no_window_mode_enabled() const {

	return _no_window;
}

int OS::get_exit_code() const {

	return _exit_code;
}
void OS::set_exit_code(int p_code) {

	_exit_code = p_code;
}

String OS::get_locale() const {

	return "en";
}

// Helper function to ensure that a dir name/path will be valid on the OS
String OS::get_safe_dir_name(const String &p_dir_name, bool p_allow_dir_separator) const {

	Vector<String> invalid_chars = String(": * ? \" < > |").split(" ");
	if (p_allow_dir_separator) {
		// Dir separators are allowed, but disallow ".." to avoid going up the filesystem
		invalid_chars.push_back("..");
	} else {
		invalid_chars.push_back("/");
	}

	String safe_dir_name = p_dir_name.replace("\\", "/").strip_edges();
	for (int i = 0; i < invalid_chars.size(); i++) {
		safe_dir_name = safe_dir_name.replace(invalid_chars[i], "-");
	}
	return safe_dir_name;
}

// Path to data, config, cache, etc. OS-specific folders

// Get properly capitalized engine name for system paths
String OS::get_godot_dir_name() const {

	// Default to lowercase, so only override when different case is needed
	return String(VERSION_SHORT_NAME).to_lower();
}

// OS equivalent of XDG_DATA_HOME
String OS::get_data_path() const {

	return ".";
}

// OS equivalent of XDG_CONFIG_HOME
String OS::get_config_path() const {

	return ".";
}

// OS equivalent of XDG_CACHE_HOME
String OS::get_cache_path() const {

	return ".";
}

// OS specific path for user://
String OS::get_user_data_dir() const {

	return ".";
};

// Absolute path to res://
String OS::get_resource_dir() const {

	return ProjectSettings::get_singleton()->get_resource_path();
}

// Access system-specific dirs like Documents, Downloads, etc.
String OS::get_system_dir(SystemDir p_dir) const {

	return ".";
}

Error OS::shell_open(String p_uri) {
	return ERR_UNAVAILABLE;
};

// implement these with the canvas?
Error OS::dialog_show(String p_title, String p_description, Vector<String> p_buttons, Object *p_obj, String p_callback) {

	while (true) {

		print("%ls\n--------\n%ls\n", p_title.c_str(), p_description.c_str());
		for (int i = 0; i < p_buttons.size(); i++) {
			if (i > 0) print(", ");
			print("%i=%ls", i + 1, p_buttons[i].c_str());
		};
		print("\n");
		String res = get_stdin_string().strip_edges();
		if (!res.is_numeric())
			continue;
		int n = res.to_int();
		if (n < 0 || n >= p_buttons.size())
			continue;
		if (p_obj && p_callback != "")
			p_obj->call_deferred(p_callback, n);
		break;
	};
	return OK;
};

Error OS::dialog_input_text(String p_title, String p_description, String p_partial, Object *p_obj, String p_callback) {

	ERR_FAIL_COND_V(!p_obj, FAILED);
	ERR_FAIL_COND_V(p_callback == "", FAILED);
	print("%ls\n---------\n%ls\n[%ls]:\n", p_title.c_str(), p_description.c_str(), p_partial.c_str());

	String res = get_stdin_string().strip_edges();
	bool success = true;
	if (res == "") {
		res = p_partial;
	};

	p_obj->call_deferred(p_callback, success, res);

	return OK;
};

int OS::get_static_memory_usage() const {

	return Memory::get_mem_usage();
}
int OS::get_dynamic_memory_usage() const {

	return MemoryPool::total_memory;
}

int OS::get_static_memory_peak_usage() const {

	return Memory::get_mem_max_usage();
}

Error OS::set_cwd(const String &p_cwd) {

	return ERR_CANT_OPEN;
}

bool OS::has_touchscreen_ui_hint() const {

	//return false;
	return Input::get_singleton() && Input::get_singleton()->is_emulating_touchscreen();
}

int OS::get_free_static_memory() const {

	return Memory::get_mem_available();
}

void OS::yield() {
}

void OS::set_screen_orientation(ScreenOrientation p_orientation) {

	_orientation = p_orientation;
}

OS::ScreenOrientation OS::get_screen_orientation() const {

	return (OS::ScreenOrientation)_orientation;
}

void OS::_ensure_user_data_dir() {

	String dd = get_user_data_dir();
	DirAccess *da = DirAccess::open(dd);
	if (da) {
		memdelete(da);
		return;
	}

	da = DirAccess::create(DirAccess::ACCESS_FILESYSTEM);
	Error err = da->make_dir_recursive(dd);
	if (err != OK) {
		ERR_EXPLAIN("Error attempting to create data dir: " + dd);
	}
	ERR_FAIL_COND(err != OK);

	memdelete(da);
}

void OS::set_icon(const Ref<Image> &p_icon) {
}

String OS::get_model_name() const {

	return "GenericDevice";
}

void OS::set_cmdline(const char *p_execpath, const List<String> &p_args) {

	_execpath = p_execpath;
	_cmdline = p_args;
};

void OS::release_rendering_thread() {
}

void OS::make_rendering_thread() {
}

void OS::swap_buffers() {
}

String OS::get_unique_id() const {

	ERR_FAIL_V("");
}

int OS::get_processor_count() const {

	return 1;
}

Error OS::native_video_play(String p_path, float p_volume, String p_audio_track, String p_subtitle_track) {

	return FAILED;
};

bool OS::native_video_is_playing() const {

	return false;
};

void OS::native_video_pause(){

};

void OS::native_video_unpause(){

};

void OS::native_video_stop(){

};

void OS::set_mouse_mode(MouseMode p_mode) {
}

bool OS::can_use_threads() const {

#ifdef NO_THREADS
	return false;
#else
	return true;
#endif
}

OS::MouseMode OS::get_mouse_mode() const {

	return MOUSE_MODE_VISIBLE;
}

OS::LatinKeyboardVariant OS::get_latin_keyboard_variant() const {

	return LATIN_KEYBOARD_QWERTY;
}

bool OS::is_joy_known(int p_device) {
	return true;
}

String OS::get_joy_guid(int p_device) const {
	return "Default Joypad";
}

void OS::set_context(int p_context) {
}

OS::SwitchVSyncCallbackInThread OS::switch_vsync_function = NULL;

void OS::set_use_vsync(bool p_enable) {
	_use_vsync = p_enable;
	if (switch_vsync_function) { //if a function was set, use function
		switch_vsync_function(p_enable);
	} else { //otherwise just call here
		_set_use_vsync(p_enable);
	}
}

bool OS::is_vsync_enabled() const {

	return _use_vsync;
}

OS::PowerState OS::get_power_state() {
	return POWERSTATE_UNKNOWN;
}
int OS::get_power_seconds_left() {
	return -1;
}
int OS::get_power_percent_left() {
	return -1;
}

bool OS::has_feature(const String &p_feature) {

	if (p_feature == get_name())
		return true;
#ifdef DEBUG_ENABLED
	if (p_feature == "debug")
		return true;
#else
	if (p_feature == "release")
		return true;
#endif

	if (sizeof(void *) == 8 && p_feature == "64") {
		return true;
	}
	if (sizeof(void *) == 4 && p_feature == "32") {
		return true;
	}
#if defined(__x86_64) || defined(__x86_64__) || defined(__amd64__)
	if (p_feature == "x86_64") {
		return true;
	}
#elif (defined(__i386) || defined(__i386__))
	if (p_feature == "x86") {
		return true;
	}
#elif defined(__aarch64__)
	if (p_feature == "arm64") {
		return true;
	}
#elif defined(__arm__)
#if defined(__ARM_ARCH_7A__)
	if (p_feature == "armv7a" || p_feature == "armv7") {
		return true;
	}
#endif
#if defined(__ARM_ARCH_7S__)
	if (p_feature == "armv7s" || p_feature == "armv7") {
		return true;
	}
#endif
	if (p_feature == "arm") {
		return true;
	}
#endif

	if (_check_internal_feature_support(p_feature))
		return true;

	return false;
}

void OS::center_window() {

	if (is_window_fullscreen()) return;

	Size2 scr = get_screen_size(get_current_screen());
	Size2 wnd = get_real_window_size();
	int x = scr.width / 2 - wnd.width / 2;
	int y = scr.height / 2 - wnd.height / 2;
	set_window_position(Vector2(x, y));
}

OS::OS() {
	void *volatile stack_bottom;

	last_error = NULL;
	singleton = this;
	_keep_screen_on = true; // set default value to true, because this had been true before godot 2.0.
	low_processor_usage_mode = false;
	low_processor_usage_mode_sleep_usec = 10000;
	_verbose_stdout = false;
	_no_window = false;
	_exit_code = 0;
	_orientation = SCREEN_LANDSCAPE;

	_render_thread_mode = RENDER_THREAD_SAFE;

	_allow_hidpi = false;
	_stack_bottom = (void *)(&stack_bottom);

	_logger = NULL;

	Vector<Logger *> loggers;
	loggers.push_back(memnew(StdLogger));
	_set_logger(memnew(CompositeLogger(loggers)));
}

OS::~OS() {
	memdelete(_logger);
	singleton = NULL;
}
