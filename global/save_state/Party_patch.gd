extends "res://mods/B-sides/scripts/Base_Patcher.gd"


class_name Party_patch


func _get_script_path():
	return "res://global/save_state/Party.gd"

#func keep_state():
	#return true

func _add_changes():
	var success = true
	
	# adding new signal definitions
	success = insert_after(
		snippet.find_tapes_use,
		snippet.swap_tapes_use
	) and success
	
	success = delete_lines(snippet.find_tapes_use) and success
	
	success = replace_first_occurrence(
		snippet.find_heal_char,
		snippet.swap_heal_char
	) and success
	
	success = insert_after(
		snippet.find_heal_all,
		snippet.add_to_heal_all
	) and success
	
	success = insert_after(
		snippet.find_swap_tapes,
		snippet.add_to_swap_tapes
	) and success
	
	success = replace_first_occurrence(
		snippet.find_has_tape,
		snippet.swap_has_tape
	) and success
	
	success = insert_at_the_end(snippet.add_new_defs) and success
		
	return success


func _save_snippets():
	add_snippet("find_tapes_use", "\tfor tape in get_tapes():")
	add_snippet("swap_tapes_use","""
	var all_tapes = get_alt_tapes() if is_using_bt() else get_tapes()
	for tape in all_tapes:
"""
	)

	add_snippet("find_heal_char", "\tfor tape in c.tapes:")
	add_snippet("swap_heal_char", "\tfor tape in get_tapes_for_character(c):")
	
	add_snippet("find_heal_all", "func heal():")
	add_snippet("add_to_heal_all",
		"\tpreload('res://mods/B-sides/scripts/StorageSystem.gd').new().heal_all_teams()"
	)
	
	add_snippet("find_swap_tapes", "\tassert (has_tape(b))")
	add_snippet("add_to_swap_tapes", """
	if is_using_bt():
		for i in player_alt_tapes.size():
			if player_alt_tapes[i] == a:
				player_alt_tapes[i] = b
			elif player_alt_tapes[i] == b:
				player_alt_tapes[i] = a
		for i in partner_alt_tapes.size():
			if partner_alt_tapes[i] == a:
				partner_alt_tapes[i] = b
			elif partner_alt_tapes[i] == b:
				partner_alt_tapes[i] = a
		# dont know if I need to
		emit_signal("tapes_changed")
		return
"""
	)
	
	add_snippet("find_has_tape", "\t\tif character.tapes.has(tape):")
	add_snippet("swap_has_tape", "\t\tif get_tapes_for_character(character).has(tape):")

	add_snippet("add_new_defs","""
func is_using_bt():
	return current_team != PARTY_ID

func is_using_bt_or_backup():
	return is_using_bt() or current_team_bck != PARTY_ID

func get_tapes_for_character(c: Character):
	if is_using_bt():
		if c == get_player():
			return player_alt_tapes
		elif c == get_partner():
			return partner_alt_tapes
	return c.tapes

func get_alt_tapes():
	var tapes = []
	if is_using_bt() and player_alt_tapes.size() > 0:
		tapes.push_back(player_alt_tapes[0])
		tapes.push_back(partner_alt_tapes[0])
		for i in range(1, player_alt_tapes.size()):
			tapes.push_back(player_alt_tapes[i])
	return tapes

# return alternate tapes if is_using_bt, and tapes if not
func get_bt_tapes():
	if is_using_bt():
		return get_alt_tapes()
	return get_tapes()


func _prepare_for_battle():
	if current_team == PARTY_ID:
		return
	print("backuping team")
	# backup team_id
	current_team_bck = current_team
	current_team = PARTY_ID
	
	# swap alt and real tapes
	var tapes = player.tapes
	player.tapes = player_alt_tapes
	player_alt_tapes = tapes

	tapes = partner.tapes
	partner.tapes = partner_alt_tapes
	partner_alt_tapes = tapes

func _return_from_battle():
	if current_team_bck == PARTY_ID:
		return
	print("restoring team")
	#MenuHelper.scenes.PartyMenu.battle = null
	#var menu = preload("res://menus/party/PartyMenu.tscn").instance()
	#menu.battle = null
	# restore team_id
	current_team = current_team_bck
	current_team_bck = PARTY_ID

	# swap alt and real tapes
	var tapes = player.tapes
	player.tapes = player_alt_tapes
	player_alt_tapes = tapes

	tapes = partner.tapes
	partner.tapes = partner_alt_tapes
	partner_alt_tapes = tapes


const PARTY_ID:int = -1
export (int) var current_team_bck = PARTY_ID
export (int) var current_team = PARTY_ID
export (Array, Resource) var player_alt_tapes:Array = []
export (Array, Resource) var partner_alt_tapes:Array = []
"""
	)

###################################
# Debug methods

func run_tests():
	if not .run_tests():
		print("Skipping tests for %s!" % _get_script_name())
		return
	assert(SaveState.party.has_method("_return_from_battle"))
	print ("%s passed tests!" % _get_script_name())
