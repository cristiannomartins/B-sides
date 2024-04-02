extends "res://mods/B-sides/scripts/Base_Patcher.gd"


class_name NetRequestAbstractBattle_patch


func _get_script_path():
	return "res://global/network/NetRequestAbstractBattle.gd"

#func keep_state():
	#return true

func _add_changes():
	var success = true
	
	# adding change in party before multiplayer sync
	success = insert_before(
		snippet.find_set_party_use,
		snippet.add_before_set_party
	) and success
		
	return success


func _save_snippets():
	add_snippet("find_set_party_use", "\tset_party()")
	add_snippet("add_before_set_party","\tSaveState.party._prepare_for_battle()")


###################################
# Debug methods

func run_tests():
	var split_code = .run_tests()
	if not split_code:
		print("Skipping tests for %s!" % _get_script_name())
		return
	assert(has_substring_within_strings(split_code, snippet.add_before_set_party))
	print ("%s passed tests!" % _get_script_name())
