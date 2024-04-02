extends Node

class_name Base_Patcher


# @needs_override
func _get_script_path():
	assert(false)
	return ""


# @needs_override this is useful for filling codeblocks below
func _save_snippets():
	assert(false)


# @needs_override as this can be useful to organize the code snippets
var snippet:Dictionary = {}

# @needs_override only if cannot apply changes due to already_in_use (22) error
func keep_state():
	return false


func add_snippet(key, value):
	snippet.keys().push_back(key)
	snippet[key] = str(value)


func get_snippet(key):
	return snippet[key]


# @needs_override as this is the main method changing the script
func _add_changes() -> bool:
	assert(false)
	return false


func load_src_code(script_path, patched_script):
	var file : File = File.new()
	var err = file.open(script_path, File.READ)
	if err != OK:
		print("Check that %s is included in Modified Files"% script_path)
		return false
	patched_script.source_code = file.get_as_text()
	file.close()
	return true


var _print_script = false
var _should_test = true
var code_lines:Array = []
func patch():
	var script_name = _get_script_name()
	print(">> Trying to patch %s!" % script_name)
	_save_snippets()
	
	var script_path = _get_script_path()
	#var patching_script : GDScript = load(script_path)
	var patching_script = load(script_path)

	if not patching_script.has_source_code():
		if not load_src_code(script_path, patching_script):
			return

	code_lines = patching_script.source_code.split("\n")

	# custom method to apply changes
	if not _add_changes():
		return

	# applying changes to script
	var err = _apply_changes(patching_script)
	if err != OK:
		print("Failed to patch %s." % script_path)
		# if error is "already_in_use", need to set "true" as third arg of apply_changes
		print("Error code %s." % str(err))
		return
	
	print("<< Patched %s!" % script_name)


func _get_script_name():
	return _get_script_path().get_file().get_basename()


func _error_not_found(var what: String):
	var tag = _get_script_name() + ": "
	print(tag + ("Couldn't find following code in %s:" % _get_script_path()))
	print(tag + ("\t\"%s\"" % what))


func _insert(where, what, increment) -> bool:
	var code_index = code_lines.find(where)
	if code_index == -1:
		_error_not_found(where)
		return false
	
	code_lines.insert(code_index+increment, what)
	return true


func insert_after(where, what) -> bool:
	return _insert(where, what, 1)

	
func insert_before(where, what) -> bool:
	return _insert(where, what, 0)


# steps: stride for line deletion; negative means to start deletion before the
#        place of the found line, while positive means after
func delete_lines(where, how_many=1, steps=0) -> bool:
	assert(how_many > 0)
	
	var code_index = code_lines.find(where)
	if code_index == -1:
		_error_not_found(where)
		return false
	
	# all lines to remove need to be within the file
	if code_index + steps < 0 or code_index + steps >= code_lines.size():
		_error_not_found(where + (" (steps: %d)" % steps))
		return false
	
	for i in how_many:
		code_lines.remove(code_index + steps)

	return true


func insert_at_the_end(what) -> bool:
	code_lines.insert(code_lines.size()-1, what)
	return true

func replace_first_occurrence(what, what_for, allow_error = true) -> bool:
	for i in code_lines.size():
		if what in code_lines[i]:
			code_lines[i] = code_lines[i].replace(what, what_for)
			return true
	
	if allow_error:
		_error_not_found(what)
		
	return false

func replace_all_occurrences(what: String, what_for: String) -> bool:
	# will loop forever if "what_for" has "what" as its substring
	assert(what_for.find(what) == -1)
	
	var total = 0
	while replace_first_occurrence(what, what_for, false):
		total = total + 1
	
	if total == 0:
		_error_not_found(what)
		return false
		
	return true


func _apply_changes(script):
	script.source_code = ""
	for line in code_lines:
		script.source_code += line + "\n"
	
	# if error is already_in_use, set keep_state to true
	return script.reload(keep_state())
	
func enable_print_final_script():
	_print_script = true

func disable_run_tests():
	_should_test = false

func run_tests() -> Array:
	#var script = load(_get_script_path()).new().script
	# assert(script.has_source_code())
		#print(script.source_code)
	#return script.source_code.split("\n")
	
	if _print_script:
		print("\n".join(code_lines))
	if disable_run_tests():
		return []
		
	return code_lines

func has_substring_within_strings(array: Array, what: String) -> bool:
	for element in array:
		if what in element: return true
	return false
