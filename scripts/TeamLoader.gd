extends Node



var storage = preload("StorageSystem.gd").new()
var pre_loaded_tapes = {}



# after loading party from file, if there was a battle team loaded on the save,
# load it again when starting the game
func _on_file_loaded():
	storage.load_teams()
	print("on_party_loaded")
	SaveState.party.player_alt_tapes = []
	#var player = SaveState.party.get_player()
	SaveState.party.current_team = storage.get_current_team()
	if SaveState.party.is_using_bt():#player.current_team == player.PARTY_ID:
		if apply_battle_team(SaveState.party.current_team):
			print("applied battle team")
		else:
			# could not apply team, it must have been erased;
			# need to default to party
			print("did NOT apply battle team")
			SaveState.party.current_team = SaveState.party.PARTY_ID
	

# returns a copy of an array "partner" and "players" tapes, where the first and second tapes
# are the assigned player and partner tapes, respectively, and the other tapes are
# the inactive tapes from the team
# In case of any errors, will return an empty array instead
func get_tapes_from_team(team_id: int) -> Array:
	if not pre_loaded_tapes.has(team_id):
		var version = storage.get_version(team_id)
		var snaps = storage.get_tapes(team_id)
		# couldn't find the team, or team is corrupted
		if not snaps: return []
		
		var tapes = []
		for tape_snap in snaps:
			var tape = MonsterTape.new()
			if not tape.set_snapshot(tape_snap, version):
				return []
			storage.validator.upgrade_to_five_stars(tape)
			if not storage.validator.validate_tape(tape):
				return []
			tape.exp_points = 0
			tapes.push_back(tape)
		
		pre_loaded_tapes[team_id] = tapes
		
	return pre_loaded_tapes[team_id]


# sets current party to use battle team tapes
func apply_battle_team(id: int) -> bool:
	# team is already applied
	if SaveState.party.current_team == id and SaveState.party.player_alt_tapes:
		return true
	
	# create tapes from battle team and assign them to player and partner
	var all_tapes = get_tapes_from_team(id)
	if all_tapes.size() == 0:
		return false
	
	# saves alternate tapes (for HP purposes) if we have any
	var alt_tapes = SaveState.party.get_alt_tapes()
	if alt_tapes and SaveState.party.is_using_bt():
		storage.update_tapes_and_save(SaveState.party.current_team, alt_tapes)
	
	SaveState.party.current_team = id
	storage.set_current_team(id)
	
	SaveState.party.player_alt_tapes = [ all_tapes[0] ]
	SaveState.party.partner_alt_tapes = [ all_tapes[1] ]
	
	for index in range(2, all_tapes.size()):
		SaveState.party.player_alt_tapes.push_back(all_tapes[index])
	
	return true


func go_back_to_party() -> void:
	var player = SaveState.party.get_player()
	if not SaveState.party.is_using_bt():
		return
	
	storage.update_tapes_and_save(SaveState.party.current_team, SaveState.party.get_alt_tapes())
	storage.set_current_team(SaveState.party.PARTY_ID)
	SaveState.party.current_team = SaveState.party.PARTY_ID
	SaveState.party.player_alt_tapes = []
	SaveState.party.partner_alt_tapes = []

# represents the team_id of BT that was in use when entering Arena, or -2 when not on arena
var inside_battle_arena = -2
func _on_scene_change_starting():
	print("!!scene change start:" + str(SceneManager.current_scene))
	var path = SceneManager.current_scene.get_path()
	var name_index = path.get_name_count() - 1
	
	# avoid overlaing teams when on battle arena
	if inside_battle_arena != -2:
		return
	
	SaveState.party._prepare_for_battle()
	# is getting out of a battle, as currently in one and started changing
	if path.get_name(name_index) == 'Battle' and SaveState.party.is_using_bt_or_backup():
		if SaveState.party.HEAL_TAPES_AFTER_BATTLE:
			for tape in SaveState.party.get_tapes():
				if not tape.is_broken():
					tape.hp.set_to(1, 1)


func _on_scene_change_ending():
	print("!!scene change end:" + str(SceneManager.current_scene))
	var path = SceneManager.current_scene.get_path()
	var name_index = path.get_name_count() - 1
	
	#print("!!full path = %s" % str(SceneManager.current_scene.filename))
	
	# just entered a scene there is not a battle
	if path.get_name(name_index) != 'Battle':
		SaveState.party._return_from_battle()
	
	# avoid overlaing teams when on battle arena
	
	# entering the arena
	if inside_battle_arena == -2 and path.get_name(name_index) == 'Arena':
		inside_battle_arena = SaveState.party.current_team
		go_back_to_party()
	
	# leaving the arena
	if inside_battle_arena != -2 and path.get_name(name_index) == 'TownHall':
		# don't need to go back to party as we already went to party when entering the arena
		if inside_battle_arena != -1:
			apply_battle_team(inside_battle_arena)
		
		inside_battle_arena = -2

