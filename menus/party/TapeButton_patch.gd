extends "res://mods/B-sides/scripts/Base_Patcher.gd"


class_name TapeButton_patch



func _get_script_path():
	return "res://menus/party/TapeButton.gd"


func _add_changes():
	var success = true
	
	# changing party tape buttons to represent b-side tapes
	success = insert_after(
		snippet.find_texture_place,
		snippet.add_replace_texture
	) and success
	
	success = delete_lines(snippet.find_texture_place) and success
	
	# adding new global variables to the end of the code
	success = insert_at_the_end(snippet.new_variables) and success
	
	return success

func _save_snippets():
	add_snippet("find_texture_place", "\t\ttexture_normal = NORMAL_TEXTURE if not tape.is_bootleg() else BOOTLEG_TEXTURE")
	add_snippet("add_replace_texture", """
		if SaveState.party.is_using_bt_or_backup() and (get_path().get_name(2) == 'PartyMenu' or get_path().get_name(2) == 'ChooseTapeMenu'):
			texture_normal = B_SIDES_NORMAL_TEXTURE if not tape.is_bootleg() else B_SIDES_BOOTLEG_TEXTURE
		else:
			texture_normal = NORMAL_TEXTURE if not tape.is_bootleg() else BOOTLEG_TEXTURE
"""
	)
			
	add_snippet("new_variables","""
const B_SIDES_NORMAL_TEXTURE = preload('res://mods/B-sides/assets/tape.png')
const B_SIDES_BOOTLEG_TEXTURE = preload('res://mods/B-sides/assets/tape_bootleg.png')
"""
	)


##########################################
# Debug methods

func run_tests():
	if not .run_tests():
		print("Skipping tests for %s!" % _get_script_name())
		return
	
#	var storage = preload("res://global/save_system/SaveSystemStorage.gd").new()
#	var storage_system = preload("res://mods/B-sides/scripts/StorageSystem.gd").new()
#	var save_file_name = storage_system.save_file
#	assert(storage.exists(save_file_name + ".gz.gcpf")
#		or storage.exists(save_file_name)
#	)
	
	var menu = preload("res://menus/party/PartyMenu.tscn").instance()
	
	var tape_button = menu.find_node("TapeButton1")
	var split_code = tape_button.script.source_code.split("\n")
	assert(split_code.find(snippet.new_variables.split("\n")[0]) != -1)
	assert(split_code.find(snippet.add_replace_texture.split("\n")[-1]) != -1)
	assert(split_code.find(snippet.find_texture_place) == -1)
	
	print ("%s passed tests!" % _get_script_name())
