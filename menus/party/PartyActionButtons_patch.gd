extends "res://mods/B-sides/scripts/Base_Patcher.gd"


class_name PartyActionButtons_patch


func _get_script_path():
	return "res://menus/party/PartyActionButtons.gd"


func _add_changes():
	var success = true
	
	# adding patch to disable put_away_btn on Party when is_using_bt
	success = replace_first_occurrence(
		snippet.find_on_ready,
		snippet.swap_buttons_disable
	) and success
		
	return success


func _save_snippets():
	add_snippet("find_on_ready", "\tif battle or tape == null or character != null:")
	add_snippet("swap_buttons_disable",
		"\tif battle or tape == null or character != null or SaveState.party.is_using_bt():"
	)

###################################
# Debug methods

func run_tests():
	var split_code = .run_tests()
	if not split_code:
		print("Skipping tests for %s!" % _get_script_name())
		return

	assert(has_substring_within_strings(split_code, "SaveState.party.is_using_bt()"))
	print ("%s passed tests!" % _get_script_name())
