extends "res://menus/tape_storage/TapeStorageMenu.gd"



var team_loader = preload("res://mods/B-sides/scripts/TeamLoader.gd").new()


# Called when the node enters the scene tree for the first time.
func _ready():
	categories = []
	
	categories.push_back(Category.new("UI_TAPE_COLLECTION_CATEGORY_PARTY", Bind.new(self, "_get_party_tapes")))
	
	for id in team_loader.storage.get_all_team_ids():
		categories.push_back(Category.new("", Bind.new(self, "_get_team_tapes", [id])))
	
	set_category_index(0)
	

func _get_party_tapes() -> Array:
	title_label["custom_colors/font_color"] = Color( 1, 1, 1, 1 )
	$BackButtonPanel/HBoxContainer/Export.hide()
	$BackButtonPanel/HBoxContainer/Delete.hide()
	return ._get_party_tapes()
	
	

func _get_team_tapes(team_id: int) -> Array:
	title_label.text = team_loader.storage.get_team_name(team_id)
	title_label["custom_colors/font_color"] = Color( 0.929412, 0.956863, 0.0156863, 1 )
	$BackButtonPanel/HBoxContainer/Export.show()
	$BackButtonPanel/HBoxContainer/Delete.show()
	
	return team_loader.get_tapes_from_team(team_id)

var party_menu

func _choose_option(message:String, options: Array,
		default_index:int = 1, initial_index:int = 0) -> int:
	GlobalMessageDialog.clear_state()
	yield (GlobalMessageDialog.show_message(message, false, false), "completed")
	var result = yield (GlobalMenuDialog.show_menu(options, options.size()-1, initial_index), "completed")
	yield (GlobalMessageDialog.hide(), "completed")
	return result

func _on_apply_teams_pressed():
	print("Applying team...")
	var team_id = categories[category_index].tapes_getter.args
	if not team_id:
		team_loader.go_back_to_party()
		party_menu.reset_party()
		party_menu.update_ui()
		cancel()
	elif team_loader.apply_battle_team(team_id[0]):
		party_menu.reset_party()
		party_menu.update_ui()
		cancel()
	else:
		print("Warn user about some issue")
		GlobalMessageDialog.clear_state()
		GlobalMessageDialog.show_message("MOD_BSIDES_ERROR_APPLYING_TEAM")


func _on_import_teams_pressed():
	print("Importing a team...")
	var found_files = team_loader.storage.list_files_to_import()
	var team_names = []
	var i = 0
	while i < found_files.size():
		var name = team_loader.storage.get_team_name_from_file(found_files[i])
		if not name:
			found_files.pop_at(i)
			continue
		team_names.push_back(name)
		i = i+1
	
	if found_files.size() == 0:
		_show_succ_or_fail_message(true, "MOD_BSIDES_IMPORT_TEAMS_NO_FILE_FOUND")
		return
	
	# add option for all teams, and for none at all
	if team_names.size() > 1:
		team_names.push_back("MOD_BSIDES_IMPORT_TEAMS_ALL")
	team_names.push_back("MOD_BSIDES_IMPORT_TEAMS_NONE")
	
	var option = yield(_choose_option("MOD_BSIDES_IMPORT_TEAMS_CHOICE", team_names), "completed")
	
	# chose 'none'
	if option == found_files.size() + 1:
		return
	
	# some file was selected
	if option < found_files.size():
		var team_id = team_loader.storage.import_team(found_files[option])
		if _show_succ_or_fail_message(team_id != -1,
		"MOD_BSIDES_SUCC_IMPORTING_TEAM", "MOD_BSIDES_ERROR_IMPORTING_TEAM"):
			categories.push_back(Category.new("", Bind.new(self, "_get_team_tapes", [team_id])))
		return
	
	# import all files
	_show_succ_or_fail_message(_import_all_teams(found_files),
		"MOD_BSIDES_SUCC_IMPORTING_ALL_TEAMS", "MOD_BSIDES_ERROR_IMPORTING_SOME_TEAM")


func _import_all_teams(file_list: Array) -> bool:
	var result = true
	for file in file_list:
		var team_id = team_loader.storage.import_team(file)
		if team_id != -1:
			categories.push_back(Category.new("", Bind.new(self, "_get_team_tapes", [team_id])))
		else:
			result = false
		
	return result


func _on_export_teams_pressed():
	# category_index gives me the selected category in category[category_index]
	var team_id = categories[category_index].tapes_getter.args
	if not team_id:
		# this button should be disabled when on party
		return
	
	var filename = team_loader.storage.get_exporting_filename(team_id[0])
	if team_loader.storage.check_exporting_team_filename(filename):
		if not yield(MenuHelper.confirm("MOD_BSIDES_EXPORT_EXISTING"), "completed"):
			grab_focus()
			return
	
	_show_succ_or_fail_message(team_loader.storage.export_team(team_id[0]),
		"MOD_BSIDES_SUCC_EXPORT_TEAM", "")


func _show_succ_or_fail_message(success: bool, succ_msg: String, fail_msg: String = "") -> bool:
	if success:
		GlobalMessageDialog.clear_state()
		GlobalMessageDialog.show_message(succ_msg)
	else:
		GlobalMessageDialog.clear_state()
		GlobalMessageDialog.show_message(fail_msg)
	return success

func _on_Delete_button_pressed():
	var team_id = categories[category_index].tapes_getter.args
	if not team_id:
		# this button should be disabled when on party
		return
	
	if not yield(MenuHelper.confirm("MOD_BSIDES_DELETE_CONFIRM_PROMPT"), "completed"):
		grab_focus()
		return

	_show_succ_or_fail_message(team_loader.storage.remove_team(team_id[0]),
		"MOD_BSIDES_SUCC_DELETE_TEAM", "MOD_BSIDES_ERR_DELETE_TEAM")
	
	# if removing the team assigned right now, need to go back to party
	if SaveState.party.current_team == team_id[0]:
		team_loader.go_back_to_party()
	categories.pop_at(category_index)
	set_category_index(0)
	grab_focus()
	
