extends "res://mods/B-sides/scripts/Base_Patcher.gd"


class_name PartyMenu_patch


func _get_script_path():
	return "res://menus/party/PartyMenu.gd"


func _add_changes():
	var success = true
	
	success = insert_before(
		snippet.find_add_chat_w_tape,
		snippet.swap_add_chat_w_tape
	) and success
	
	success = delete_lines(
		snippet.find_add_chat_w_tape,
		2
	) and success
	
	success = replace_first_occurrence(
		snippet.find_add_chat,
		snippet.swap_add_chat
	) and success
	
	success = insert_after(
		snippet.find_on_ready,
		snippet.add_hide_options
	) and success
	
	success = insert_after(
		snippet.find_update_ui,
		snippet.add_team_name
	) and success
	
	success = insert_at_the_end(
		snippet.add_new_methods
	) and success
	
	return success


func _save_snippets():
	add_snippet("find_add_chat_w_tape", "\t\tfor alt_tape in character.tapes:")
	add_snippet("swap_add_chat_w_tape", """
		for alt_tape in SaveState.party.get_tapes_for_character(character):
			if not alt_tape in active_tapes:
"""
	)
	
	add_snippet("find_add_chat", "\tfor alt_tape in character.tapes:")
	add_snippet("swap_add_chat",
		"\tfor alt_tape in SaveState.party.get_tapes_for_character(character):"
	)
	
	add_snippet("find_on_ready", "func _ready():")
	add_snippet("add_hide_options","""
	if get_node_or_null('BackButtonPanel/HBoxContainer/SaveTeam'):
		if battle:
			$BackButtonPanel/HBoxContainer/SaveTeam.hide()
			$BackButtonPanel/HBoxContainer/ListTeam.hide()
		else:
			$BackButtonPanel/HBoxContainer/SaveTeam.show()
			$BackButtonPanel/HBoxContainer/ListTeam.show()
"""
	)
	
	add_snippet("find_update_ui", "func update_ui():")
	add_snippet("add_team_name","""
	if get_node_or_null('Scroller/BSidesContainer'):
		if SaveState.party.is_using_bt() or SaveState.party.current_team_bck != -1:
			$Scroller/BSidesContainer.show()
			var storage = preload('res://mods/B-sides/scripts/StorageSystem.gd').new()
			$Scroller/BSidesContainer/PanelContainer2/TeamNameLabel.text = storage.get_team_name(SaveState.party.current_team)
			$BackButtonPanel/HBoxContainer/SaveTeam.text = "MOD_BSIDES_SAVE_OPTION_WHEN_LOADED"
		else:
			$Scroller/BSidesContainer.hide()
			$BackButtonPanel/HBoxContainer/SaveTeam.text = "MOD_BSIDES_SAVE_OPTION"
"""
	)
	
	add_snippet("add_new_methods","""
func _on_BackButton_pressed():
	cancel()

func _on_SaveTeam_pressed():
	var team_storage = preload("res://mods/B-sides/scripts/StorageSystem.gd").new()
	if SaveState.party.is_using_bt():
		if team_storage.update_tapes_and_save(SaveState.party.current_team, SaveState.party.get_alt_tapes()):
			GlobalMessageDialog.clear_state()
			GlobalMessageDialog.show_message(Loc.tr("MOD_BSIDES_SUCC_UPDATING_TEAM"))
		else:
			GlobalMessageDialog.clear_state()
			GlobalMessageDialog.show_message(Loc.tr("MOD_BSIDES_ERROR_APPLYING_TEAM"))
	else:
		Controls.set_disabled(self, true)
		var title = Loc.tr("MOD_BSIDES_NAME_TEAM_TITLE")
		var def_array = tr("MOD_BSIDES_DEFAULT_TEAM_NAME").split('|')
		var default_text = def_array[ randi() % def_array.size() ]
		var new_name = yield (MenuHelper.show_text_input(title, default_text), "completed")
		Controls.set_disabled(self, false)
		if new_name:
			assert (new_name is String)
			if team_storage.create_team(new_name):
				GlobalMessageDialog.clear_state()
				GlobalMessageDialog.show_message(Loc.tr("MOD_BSIDES_SUCC_ADDING_TEAM"))
			else:
				GlobalMessageDialog.clear_state()
				GlobalMessageDialog.show_message(Loc.tr("MOD_BSIDES_ERROR_APPLYING_TEAM"))
			update_ui()
	
	grab_focus()


func _on_ListTeam_pressed():
	var scene = preload("res://mods/B-sides/menus/party/TeamStorageMenu.tscn")
	var menu = scene.instance()

	MenuHelper.add_child(menu)
	menu.party_menu = self
	var result = yield (menu.run_menu(), "completed")

	menu.queue_free()

"""
	)



##########################################
# Debug methods

func run_tests():
	var split_code = .run_tests()
	if not split_code:
		print("Skipping tests for %s!" % _get_script_name())
		return
	assert(has_substring_within_strings(split_code, "BackButtonPanel/HBoxContainer/SaveTeam"))
	assert(has_substring_within_strings(split_code, "func _on_ListTeam_pressed():"))
	print ("%s passed tests!" % _get_script_name())

