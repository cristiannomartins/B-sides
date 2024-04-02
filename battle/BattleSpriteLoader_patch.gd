extends "res://mods/B-sides/scripts/Base_Patcher.gd"


class_name BattleSpriteLoader_patch


func _get_script_path():
	return "res://battle/BattleSpriteLoader.gd"


func _add_changes():
	var success = true
	
	# adding new signal definitions
	success = replace_first_occurrence(
		snippet.find_tapes_use,
		snippet.swap_tapes_use
	) and success
	
	return success


func _save_snippets():
	add_snippet("find_tapes_use", "\t\t\tfor tape in c.character.tapes:")
	add_snippet("swap_tapes_use",
		"\t\t\tfor tape in SaveState.party.get_tapes_for_character(c.character):"
	)

###################################
# Debug methods

func run_tests():
	var split_code = .run_tests()
	if not split_code:
		print("Skipping tests for %s!" % _get_script_name())
		return
	assert(not has_substring_within_strings(split_code, snippet.find_tapes_use))
	assert(has_substring_within_strings(split_code, snippet.swap_tapes_use))
	print ("%s passed tests!" % _get_script_name())
