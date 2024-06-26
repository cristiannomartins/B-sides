extends "res://mods/B-sides/scripts/Base_Patcher.gd"


class_name PartyTapeUI_patch


func _get_script_path():
	return "res://menus/party_tape/PartyTapeUI.gd"


func _add_changes():
	var success = true
	
	# adding patch to disable bestiary button when applicable
	success = insert_after(
		snippet.find_on_ready,
		snippet.add_buttons_disable
	) and success
	
	request_delayed_changes()
	
	return success

func _delayed_changes() -> bool:
	var success = true
	
	# if Sticker_Recycle_Bonus is loaded, I need to disable its menu on Party during this mod's usage
	success = replace_first_occurrence(
		snippet.find_party_stickers,
		snippet.swap_party_stickers
	) and success
	
	return success

func _save_snippets():
	add_snippet("find_on_ready", "func _ready():")
	add_snippet("add_buttons_disable", """
	var tape_strg_menu = get_node('/root/MenuHelper/TapeStorageMenu')
	var found_bt_list = tape_strg_menu and tape_strg_menu.has_method('_get_team_tapes')
	var tape_party_menu = get_node('/root/MenuHelper/PartyMenu')
	var found_party = tape_party_menu and SaveState.party.is_using_bt_or_backup()
	if found_bt_list or found_party:
		if not SaveState.species_collection.has_obtained_species(tape.form):
			buttons.remove_child(bestiary_btn)
			bestiary_btn.queue_free()
			bestiary_btn = null
"""
	)
	
	add_snippet("find_party_stickers", "\tvar buttons = PartyStickerActionButtonsExt.instance()")
	add_snippet("swap_party_stickers", """
	var buttons
	if SaveState.party.is_using_bt():
		buttons = PartyStickerActionButtons.instance()
	else:
		buttons = PartyStickerActionButtonsExt.instance()
"""
	)
	
###################################
# Debug methods

func run_tests():
	if not .run_tests():
		print("Skipping tests for %s!" % _get_script_name())
		return
	var menu = preload("res://menus/party_tape/PartyTapeUI.tscn").instance()
	var split_code = menu.get_script().source_code.split("\n")
	assert(snippet.add_buttons_disable.split("\n")[0] in split_code)
	print ("%s passed tests!" % _get_script_name())
