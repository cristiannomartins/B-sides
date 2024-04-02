extends "res://mods/B-sides/scripts/Base_Patcher.gd"


class_name TapeActionButtons_patch


func _get_script_path():
	return "res://menus/tape_storage/TapeActionButtons.gd"


func _add_changes():
	var success = true
	
	# disabling several buttons to edit tapes / party from storage when is_using_bt
	success = insert_before(
		snippet.find_on_ready,
		snippet.add_buttons_disable
	) and success
		
	return success


func _save_snippets():
	add_snippet("find_on_ready", "\tbuttons.setup_focus()")
	add_snippet("add_buttons_disable","""
	var tape_strg_menu = get_node('/root/MenuHelper/TapeStorageMenu')
	var found_bt_list = tape_strg_menu and tape_strg_menu.has_method('_get_team_tapes')
	var tape_party_menu = get_node('/root/MenuHelper/PartyMenu')
	var found_party = tape_party_menu and SaveState.party.is_using_bt()
	if found_bt_list or found_party:
		if not SaveState.species_collection.has_obtained_species(tape.form):
			if bestiary_btn:
				buttons.remove_child(bestiary_btn)
				bestiary_btn.queue_free()
				bestiary_btn = null
		var btn_list = [put_away_btn, add_to_party_btn, favorite_btn, peel_stickers_btn, recycle_btn, trade_btn]
		for btn in btn_list:
			if btn:
				buttons.remove_child(btn)
				btn.queue_free()
		put_away_btn = null
		add_to_party_btn = null
		favorite_btn = null
		peel_stickers_btn = null
		recycle_btn = null
		trade_btn = null
"""
	)
	
	
	
###################################
# Debug methods

func run_tests():
	var split_code = .run_tests()
	assert(has_substring_within_strings(split_code, "SaveState.party.is_using_bt()"))
	print ("%s passed tests!" % _get_script_name())
