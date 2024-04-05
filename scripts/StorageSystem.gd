extends Node

# Battle team is going to be saved / loaded from gcpf files stored under base_path
# on user path. Each file should contain one whole team of size between 2 and 6.
# Name standards follow the name of the team, and inside the file we can find a
# couple of other information like the name of the creator, ...
# Format:
# /
# |_ current_team: int
# |_ teams: Array
#      |_ team_id:int
#      |_ version:int
#      |_ team_name:String
#      |_ tapes:[ MonsterTape-snapshot ] (2-6)
# Exported teams will be a bit simpler, as only one team per file is shared, and
# team_ids are local to save files. Thus, team ids are not shared with the export.
# Exported format:
# /
# |_ version:int
# |_ team_name:String
# |_ tapes:[ MonsterTape-snapshot ] (2-6)



var base_path = "user://battle_teams/"
var sharing_path = base_path + "shared/"
var imported_path = sharing_path + "imported/"
var save_prefix = "b_sides"
var save_file = base_path + save_prefix + ".json"
var storage = preload("res://global/save_system/SaveSystemStorage.gd").new()

# current team is save specific: the dictionary key is the path to the save file,
# and the content is the team_id (defaults to PARTY_ID)
# "current_teams": {"save_file": <team_id>}
var snapshots = { "teams":[], "current_teams": {}}


# Called when the node enters the scene tree for the first time.
func _init() -> void:
	print("StorageSystem: _ready")
	var dir = Directory.new()
	if not dir.dir_exists(imported_path):
		print("StorageSystem: creating imported_path")
		dir.make_dir_recursive(imported_path)
	else:
		print("StorageSystem: imported_path already exists")

	load_teams()


func get_all_team_ids() -> Array:
	var result = []
	for team in snapshots.teams:
		result.push_back(int(team.team_id))
	return result


func has_any_teams() -> bool:
	return snapshots.teams.size() > 0
	

#func update_tapes_hp_and_save() -> bool:
#	var current_tapes = SaveState.party.get_bt_tapes()
#	var current_team = get_tapes(SaveState.party.current_team)
#	var count = 0
#	for tape in current_tapes:
#		for snap in current_team:
#			if snap.exp_points == tape.exp_points:
#				snap.hp = [tape.hp.numerator, tape.hp.denominator]
#				count += 1
#				break
#
#	assert(count == current_tapes.size())
#	#if count < current_tapes.size(): return false
#
#	return _save_teams_state(save_file, snapshots)


# saves the change in tape and stickers order, and HP from the team into BT
func update_tapes_and_save(team_id: int, tapes: Array) -> bool:
	var team = get_team_by_id(team_id)
	if not team:
		return false
	
	var snaps = []
	
	for tape in tapes:
		snaps.push_back(tape.get_snapshot())
	
	team.tapes = snaps
	return _save_teams_state(save_file, snapshots)


func heal_all_teams() -> bool:
	for team in snapshots.teams:
		for tape in team.tapes:
			tape.erase("hp")
	return _save_teams_state(save_file, snapshots)


# adds a set of tapes with a name onto the team list
func _include_team(team_name: String, tapes: Array,
		version: int = SaveState.CURRENT_VERSION) -> int:
	var next_team_id = snapshots.teams.back().team_id + 1 if not snapshots.teams.empty() else 0
	
#	# set unique ids for the tapes
#	var tape_id = 0
#	for tape in tapes:
#		tape.exp_points = tape_id
#		tape_id += 1
	
	var snap = {
		"team_name": team_name,
		"tapes": tapes,
		"team_id": next_team_id,
		"version": version
	}
	snapshots.teams.push_back(snap)
	return next_team_id


# create a new team from the current set of tapes from player and partner
func create_team(team_name: String) -> bool:
	# need to be creating a team from the party
	assert(not SaveState.party.is_using_bt())
	
	var tapes_snaps = []
	for tape in SaveState.party.get_tapes():
		tapes_snaps.push_back(tape.get_snapshot())
		
	_include_team(team_name, tapes_snaps)
	
	# saving does not emit any signals :(
	# thus, we are going to do the same as settings, and save whenever something
	# new is written to snapshots
	return _save_teams_state(save_file, snapshots)


# remove team with team_id from the snapshots and save the new rooster of teams
func remove_team(team_id: int) -> bool:
	var i = 0
	while i < snapshots.teams.size():
		if snapshots.teams[i].team_id == team_id:
			break
		i = i + 1
	if i == snapshots.teams.size():
		return false
	
	snapshots.teams.remove(i)
	return _save_teams_state(save_file, snapshots)


# helper function for writing snapshots into files
func _save_teams_state(save_file: String, snapshot: Dictionary) -> bool:
	var result = storage.store(save_file, snapshot)
	if result != OK:
		push_error("Saving failed with error code " + str(result))
		return false
	return true


# loads all teams previously saved by the player
func load_teams() -> void:
	if not storage.exists(save_file):
		_save_teams_state(save_file, snapshots)
		print("new teams file created")
	else:
		var _result = storage.read(save_file)
		if _result.error == ERR_FILE_NOT_FOUND:
			print("load_teams: ERR_FILE_NOT_FOUND")
			return
		elif _result.error == OK and _result.versions.size() > 0:
			snapshots = _result.versions[0]
		else:
			print("load_teams: GENERIC ERROR: " + str(_result.error))
			return
		print("teams loaded from file")

# will return the names of files with full extension (.json.gz.gcpf)
func list_files_to_import() -> Array:
	var list = []
	var dir = Directory.new()
	var result = dir.open(sharing_path)
	if result != OK:
		push_error("Import failed while opening path with error code " + str(result))
		return list
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			list.push_back(file_name)
		file_name = dir.get_next()

	return list


# expects file_name to contain full extention (.json.gz.gcpf)
func _read_team_from_file(file_name: String) -> Dictionary:
	# need to remove compressed extension from name
	file_name = file_name.replace(".gz.gcpf", "")
	
	var _result = storage.read(sharing_path + file_name)
	if _result.error == ERR_FILE_NOT_FOUND:
		print("import_team: ERR_FILE_NOT_FOUND")
		return {}
	elif _result.error == OK and _result.versions.size() > 0:
		return _result.versions[0]
	print("import_team: GENERIC ERROR: " + str(_result.error))
	return {}


# file_name has to have full extension
func get_team_name_from_file(file_name: String) -> String:
	var contents = _read_team_from_file(file_name)
	if contents:
		return contents.team_name
	
	return ""


var validator = preload("res://mods/B-sides/scripts/Validator.gd").new()
func _validate_team(var version:int, var tapes: Array) -> bool:
	for tape in tapes:
		var tmp = MonsterTape.new()
		tmp.set_snapshot(tape, version)
		upgrade_to_five_stars(tmp)
		if not validator.validate_tape(tmp):
			return false

	return true

func upgrade_to_five_stars(tape: MonsterTape) -> void:
	var stickers_bck = tape.stickers
	tape.stickers = []
	var rand = Random.new()
	tape.upgrade_to(1, rand)
	tape.upgrade_to(2, rand)
	tape.upgrade_to(3, rand)
	tape.upgrade_to(4, rand)
	tape.upgrade_to(5, rand)
	tape.stickers = stickers_bck


# reads a file from sharing folder and include the team from there into the savefile
func import_team(file_name: String) -> int:
	var contents = _read_team_from_file(file_name)
	if not contents:
		return -1
	
	if not _validate_team(contents.version, contents.tapes):
		print("invalid team found!!")
		return -1
		
	var team_id = _include_team(contents.team_name, contents.tapes, contents.version)
	_save_teams_state(save_file, snapshots)
	
	var file_path = sharing_path + file_name
	var dir = Directory.new()
	#dir.rename(file_path, imported_path + file_path.split("/")[-1])
	dir.rename(file_path, imported_path + file_name)
	return team_id


# return a battle team based on id, if the id exists. If it doesn't exist, returns null instead
func get_team_by_id(id: int) -> String:
	for team in snapshots.teams:
		if team.team_id == id:
			return team
	return ""


func get_exporting_filename(id: int) -> String:
	var team_name = get_team_name(id)
	if team_name:
		# get rid of non-alphanumeric characters on filename
		team_name = team_name.replace(" ", "_").percent_encode().replace("%", "_")
		return sharing_path + str(id) + "-" + save_prefix + "_" + team_name + ".json"
	return ""

func check_exporting_team_filename(filename: String, should_erase:bool = false) -> bool:
	var exists = File.new().file_exists(filename + ".gz.gcpf")
	if exists and should_erase:
		storage.erase(filename + ".gz.gcpf")
	return exists
		

# saves a team of given id onto a file for sharing
func export_team(id: int) -> bool:
	var team = get_team_by_id(id)
	if team:
		var exporting = {
			"team_name": team.team_name,
			"version": team.version,
			"tapes": team.tapes
		}
		var filename = get_exporting_filename(id)
		check_exporting_team_filename(filename, true)
		_save_teams_state(filename, exporting)
		return true
	return false


func get_tapes(team_id) -> Array:
	var team = get_team_by_id(team_id)
	if team:
		return team.tapes
	else:
		return []
		

func get_current_team() -> int:
	if snapshots.current_teams.has(SaveSystem.save_path):
		return snapshots.current_teams[SaveSystem.save_path]
	return SaveState.party.PARTY_ID


func set_current_team(team_id):
	snapshots.current_teams[SaveSystem.save_path] = team_id
	_save_teams_state(save_file, snapshots)


func get_version(team_id: int) -> int:
	var team = get_team_by_id(team_id)
	if team:
		return team.version
	else:
		return SaveState.CURRENT_VERSION


func get_team_name(team_id: int) -> String:
	var team = get_team_by_id(team_id)
	if team:
		return team.team_name
	else:
		return ""


func set_team_name(team_id: int, new_name: String):
	var team = get_team_by_id(team_id)
	if team:
		team.team_name = new_name



##########################################
# DEBUG functions

func _test_import(dir, filename):
	print("_test_import")
	
	import_team(filename)
	
	wait_file(imported_path + filename)
	assert(dir.file_exists(imported_path + filename))
	assert(not dir.file_exists(sharing_path + filename))
	
	
func _test_export(dir, name: String, id: int):
	print("_test_export")
	export_team(id)
	var filename = sharing_path + name
	wait_file(filename)
	assert(dir.file_exists(filename))

func wait_file(filename: String):
	var dir = Directory.new()
	var i = 0
	while not dir.file_exists(filename):
		i = i+1
		if i > 999999: assert (false)
	
func _test_save_teams(dir, team_name: String, partner_tape: Array, player_tapes: Array) -> void:
	print("_test_save_teams")
	var snaps = []
	snaps.push_back(player_tapes[0].get_snapshot())
	snaps.push_back(partner_tape[0].get_snapshot())
	for index in range(1, player_tapes.size()):
		snaps.push_back(player_tapes[index].get_snapshot())
	
	_include_team(team_name, snaps)
	_save_teams_state(save_file, snapshots)
	wait_file(save_file + ".gz.gcpf")
	#var i = 0
	#while not dir.file_exists(save_file + ".json.gz.gcpf"):
	#	i = i+1
	#	if i > 999999: break
	#yield(get_tree().create_timer(1.0), "timeout")
	assert(dir.file_exists(save_file + ".gz.gcpf"))
	

func run_tests() -> void:
	print("StorageSystem: starting tests...")
	var snapshots_bck = snapshots
	snapshots = { "teams":[], "current_teams": {}}
	var dir = Directory.new()
	var partner_tape = [ _test_create_tape("arkidd") ]
	var player_tapes = [
		_test_create_tape("anathema"),
		_test_create_tape("traffikrab"),
		_test_create_tape("bansheep"),
		_test_create_tape("zombleat"),
		_test_create_tape("ramtasm")
	]
	
	_test_save_teams(dir, "team1", partner_tape, player_tapes)
	_test_save_teams(dir, "team2", partner_tape, player_tapes)
	
	_test_export(dir, "0-b_sides_team1.json.gz.gcpf", 0)
	_test_export(dir, "1-b_sides_team2.json.gz.gcpf", 1)
	
	snapshots = { "teams":[], "current_teams": {}}
	
	_test_import(dir, "0-b_sides_team1.json.gz.gcpf")
	_test_import(dir, "1-b_sides_team2.json.gz.gcpf")
	
	assert (snapshots.teams.size() == 2)
	return
	# TODO: assert tapes in snapshots are the same as in player and partner's tapes
	print("partner_tape:      " + str(partner_tape[0].get_snapshot()))
	print("imported partner1: " + str(snapshots.teams[0].partner_tape[0]))
	print("imported partner2: " + str(snapshots.teams[1].partner_tape[0]))
	
	print("player_tapes:")
	for tape in player_tapes:
		print("\t" + str(tape.get_snapshot()))
	print("imported player1:")
	for tape in snapshots.teams[0].player_tapes:
		print("\t" + str(tape))
	print("imported player2:")
	for tape in snapshots.teams[1].player_tapes:
		print("\t" + str(tape))
	
	# discards snapshots and reloads it from file
	load_teams()
	
	print("loaded partner1: " + str(snapshots.teams[0].partner_tape[0]))
	print("loaded partner2: " + str(snapshots.teams[1].partner_tape[0]))
	print("loaded player1:")
	for tape in snapshots.teams[0].player_tapes:
		print("\t" + str(tape))
	print("loaded player2:")
	for tape in snapshots.teams[1].player_tapes:
		print("\t" + str(tape))
	
	snapshots = snapshots_bck
	print("StorageSystem: tests finished")


func _test_create_tape(form: String) -> MonsterTape:
	var tape = MonsterTape.new()
	if not form.begins_with("res://"):
		form = "res://data/monster_forms/" + form + ".tres"
	if not ResourceLoader.exists(form):
		return null
	tape.set_form(load(form))
	tape.assign_initial_stickers(true, Random.new())
	return tape
