extends "res://mods/B-sides/scripts/Base_Patcher.gd"


class_name SaveState_patch


func _get_script_path():
	return "res://global/save_state/SaveState.gd"

func keep_state():
	return true

func _add_changes():
	var success = true
	
	# adding patch to set_snapshot in Character
	success = replace_first_occurrence(
		snippet.find_party_load,
		snippet.swap_party_load
	) and success
	
	return success


func _save_snippets():
	add_snippet("find_party_load", "\tparty = load(\"res://global/save_state/Party.tscn\").instance()")
	add_snippet("swap_party_load", "\tparty = preload(\"res://global/save_state/Party.tscn\").instance()")
	

#################################
# Debug methods

func run_tests():
	if not .run_tests():
		print("Skipping tests for %s!" % _get_script_name())
		return
	var split_code = SaveState.get_script().source_code.split("\n")
	assert(split_code.find(snippet.find_party_load) == -1)
	assert(split_code.find(snippet.swap_party_load) != -1)
	print("%s passed tests!" % _get_script_name())
