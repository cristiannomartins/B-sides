extends "res://mods/B-sides/scripts/Base_Patcher.gd"


class_name WarpRegion_patch


func _get_script_path():
	return "res://nodes/warp_region/WarpRegion.gd"


func _add_changes():
	var success = true
	
	# starting battle preparations
	success = replace_first_occurrence(
		snippet.find_can_warp,
		snippet.swap_can_warp
	) and success
	
	return success


func _save_snippets():
	add_snippet("find_can_warp", "\tfor tape in SaveState.party.get_tapes():")
	add_snippet("swap_can_warp","\tfor tape in SaveState.party.get_bt_tapes():")

###################################
# Debug methods

func run_tests():
	var split_code = .run_tests()
	if not split_code:
		print("Skipping tests for %s!" % _get_script_name())
		return
	assert(not has_substring_within_strings(split_code, snippet.find_can_warp))
	assert(has_substring_within_strings(split_code, snippet.swap_can_warp))
	print ("%s passed tests!" % _get_script_name())
