extends "res://mods/B-sides/scripts/Base_Patcher.gd"


class_name PartyStickerActionButtons_patch


func _get_script_path():
	return "res://menus/party_tape/PartyStickerActionButtons.gd"


func _add_changes():
	var success = true
	
	# disabling apply and peel sticker options when is_using_bt from party
	success = insert_after(
		snippet.find_on_ready,
		snippet.add_buttons_disable
	) and success
		
	return success


func _save_snippets():
	add_snippet("find_on_ready", "func _ready():")
	add_snippet("add_buttons_disable","""
	var tape_strg_menu = get_node('/root/MenuHelper/TapeStorageMenu')
	var found_bt_list = tape_strg_menu and tape_strg_menu.has_method('_get_team_tapes')
	var tape_party_menu = get_node('/root/MenuHelper/PartyMenu')
	var found_party = tape_party_menu and SaveState.party.is_using_bt()
	apply_sticker_btn.disabled = found_bt_list or found_party
	peel_sticker_btn.disabled = found_bt_list or found_party
"""
	)
	


func keep_state():
	return true

###################################
# Debug methods

func run_tests():
	var split_code = .run_tests()
	if not split_code:
		print("Skipping tests for %s!" % _get_script_name())
		return
	assert(has_substring_within_strings(split_code, "SaveState.party.is_using_bt()"))
	print ("%s passed tests!" % _get_script_name())
