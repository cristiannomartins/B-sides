extends "res://mods/B-sides/scripts/Base_Patcher.gd"


class_name MenuHelper_patch


func _get_script_path():
	return "res://menus/MenuHelper.gd"

func keep_state():
	return true

func _add_changes():
	var success = true
	
	# changing PartyMenu scene to allow editing BackButtonPanel
	success = replace_first_occurrence(
		snippet.find_party_menu,
		snippet.swap_party_menu
	) and success
	
	# saves any newly recorded tapes to inventory if a BT is loaded
	success = replace_first_occurrence(
		snippet.find_give_tape,
		snippet.swap_give_tape
	) and success
	
	# hides stickers tab from the inventory when BT is loaded
	success = insert_after(
		snippet.find_show_inventory,
		snippet.add_to_show_inventory
	) and success
	
	return success


func _save_snippets():
	add_snippet("find_party_menu",
		"\tscenes.PartyMenu = load(\"res://menus/party/PartyMenu.tscn\")"
	)
	add_snippet("swap_party_menu",
		"\tscenes.PartyMenu = load('res://mods/B-sides/menus/party/PartyMenu.tscn')"
	)
	
	add_snippet("find_give_tape",
		"\t\tif SaveState.party.count_tapes() < SaveState.party.max_tapes:"
	)
	add_snippet("swap_give_tape",
		"\t\tif not SaveState.party.is_using_bt() and SaveState.party.count_tapes() < SaveState.party.max_tapes:"
	)
	
	add_snippet("find_show_inventory", "func show_inventory(context = null, tab_filter = [], immediate_item_use = true):")
	add_snippet("add_to_show_inventory", """
	if SaveState.party.is_using_bt():
		if not tab_filter: tab_filter = ["consumables", "tapes", "resources", "misc"]
		else:              tab_filter.erase("stickers")
"""
	)
		


###################################
# Debug methods

func run_tests():
	var split_code = .run_tests()
	if not split_code:
		print("Skipping tests for %s!" % _get_script_name())
		return
	assert(split_code.find(snippet.find_party_menu) == -1)
	assert(split_code.find(snippet.swap_party_menu) != -1)
	print ("%s passed tests!" % _get_script_name())
