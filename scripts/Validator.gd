extends Resource

func validate_tape(tape: MonsterTape) -> bool:
	if not tape.has_moves():
		dlog("tape without moves is fine")
		return true
		
	var max_stickers = tape.get_max_stickers()
	if max_stickers > MonsterTape.MOVE_SLOTS_HARD_LIMIT:
		dlog("Tape should have at most %d stickers" % MonsterTape.MOVE_SLOTS_HARD_LIMIT)
		return false
	
	var plus_slot_to_max = max_stickers - tape.form.move_slots
	var plus_one_slots = 0
	
	for i in max_stickers:
		# ignore empty slots
		var sticker = tape.get_sticker(i)
		if not sticker:
			continue
		
		# move from sticker must be compatible with tape
		var move = sticker.battle_move
		if not _is_for_any_tape(sticker) and not BattleMoves.is_compatible(tape, move):
			dlog("form: " + str(tape.form.resource_path))
			dlog("move: " + str(move.resource_path))
			dlog("move from sticker must be compatible with tape")
			return false

		# move needs an attribute profile to own attributes
		if not move.attribute_profile:
			continue

		# selects compatible attributes from all rarities
		# note: there is no such thing as a common attribute, but this loop tries
		# to prevent having issues if any new rarities are added to the game
		var attr_list = []
		for value in BaseItem.Rarity.values():
			attr_list += move.attribute_profile.get_applicable_attributes(value, move)
		
		# sticker attributes should be compatible with move
		var max_attributes = ItemFactory.MAX_ATTRIBUTES.duplicate()
		var max_rarity = 0
		for attr in sticker.attributes:
			if not _contains(attr, attr_list):
				dlog("sticker attribute should be compatible with move")
				return false
			if "chance" in attr and (attr.chance > attr.chance_max or attr.chance < attr.chance_min):
				dlog("sticker attribute chance should be between min and max possible values")
				return false
			if "stat_value" in attr and (attr.stat_value > attr.stat_value_max or attr.stat_value < attr.stat_value_min):
				dlog("sticker attribute stat increase should be between min and max possible values")
				return false
			if _is_extra_slot_attribute(attr):
				plus_one_slots += 1
			max_attributes[attr.rarity] -= 1
			if max_attributes[attr.rarity] < 0:
				dlog("sticker has too many attributes of rarity = %d" % attr.rarity)
				return false
			if attr.rarity > max_rarity: max_rarity = attr.rarity
		
		# TODO: is this even a thing?
		if max_rarity > sticker.rarity:
			dlog("sticker has attributes of higher rarity than itself")
			return false

	if plus_one_slots < plus_slot_to_max:
		dlog("There are not enough extra slot attributes to compensate the number of stickers")
		return false
				
	dlog("tape seems fine")
	return true

func _is_extra_slot_attribute(attribute: StickerAttribute) -> bool:
	return attribute.template_path == "res://data/sticker_attributes/extra_slot.tres"
	
func _is_for_any_tape(sticker: StickerItem) -> bool:
	for attribute in sticker.attributes:
		if attribute.template_path == "res://data/sticker_attributes/compatibility.tres":
			return true
	return false

func _contains(attribute, list: Array) -> bool:
	for item in list:
		if item.resource_path == attribute.template_path:
			return true
	return false

func dlog(text: String):
	print("TapeValidator >> " + text)

##########################################
# DEBUG functions

# bad forecast cannot have attributes
func _test_insert_bad_forecast_sticker(tape: MonsterTape):
	var bad_forecast = preload("res://data/battle_moves/bad_forecast.tres")
	var extra_sticker = ItemFactory.create_sticker(bad_forecast, Random.new(), BaseItem.Rarity.RARITY_COMMON)
	tape.stickers.push_back(extra_sticker)

# attributes rarer than sticker
func _test_insert_invalid_rarer_attribute_than_sticker(tape: MonsterTape):
	var sticker:StickerItem = _test_insert_uncommon_sticker(tape)
	_test_add_simple_attribute(sticker, "extra_slot")

# too many rare attributes
func _test_insert_invalid_too_many_attributes_sticker(tape: MonsterTape):
	var sticker:StickerItem = _test_insert_uncommon_sticker(tape)
	_test_add_simple_attribute(sticker, "extra_slot")
	_test_add_simple_attribute(sticker, "destroys_walls")
	
	
# rare attribute is incompatible
func _test_insert_invalid_sticker(tape: MonsterTape):
	_test_add_simple_attribute(_test_insert_uncommon_sticker(tape), "extra_hit")


# add attribute without modifiers
func _test_add_simple_attribute(sticker: StickerItem, attribute: String):
	var attr = load("res://data/sticker_attributes/" + attribute + ".tres")
	attr.template_path = "res://data/sticker_attributes/" + attribute + ".tres"
	sticker.attributes.push_back(attr)

func _test_add_invalid_stat_boosting_attribute(sticker: StickerItem):
	var attr = load("res://data/sticker_attributes/stat_move_accuracy.tres")
	attr.template_path = "res://data/sticker_attributes/stat_move_accuracy.tres"
	attr.stat_value = attr.stat_value_max + 1
	sticker.attributes.push_back(attr)
	

func _test_insert_rare_sticker(tape: MonsterTape) -> StickerItem:
	var move = preload("res://data/battle_moves/spit.tres")
	var extra_sticker = ItemFactory.create_sticker(move, Random.new(), BaseItem.Rarity.RARITY_RARE)
	tape.stickers.push_back(extra_sticker)
	return extra_sticker


func _test_insert_uncommon_sticker(tape: MonsterTape) -> StickerItem:
	var move = preload("res://data/battle_moves/spit.tres")
	var extra_sticker = ItemFactory.create_sticker(move, Random.new(), BaseItem.Rarity.RARITY_UNCOMMON)
	tape.stickers.push_back(extra_sticker)
	return extra_sticker


func _test_create_tape(form: String) -> MonsterTape:
	var tape = MonsterTape.new()
	if not form.begins_with("res://"):
		form = "res://data/monster_forms/" + form + ".tres"
	if not ResourceLoader.exists(form):
		return null
	tape.set_form(load(form))
	tape.assign_initial_stickers(true, Random.new())
	return tape


func _test_make_tape_invalid(tape: MonsterTape) -> void:
	_test_insert_invalid_sticker(tape)


# TODO: does it make sense to try and create the tapes when loading them from external files
# and see if this guarantees the tapes are valid?
func run_tests() -> void:
	var tape = _test_create_tape("arkidd")
	dlog("Valid tape: %s" % tape.get_snapshot())
	var result = validate_tape(tape)
	dlog("Result: %s" % str(result))
	assert(result == true)
	
	_test_insert_rare_sticker(tape)
	dlog("Rare sticker tape: %s" % tape.get_snapshot())
	result = validate_tape(tape)
	dlog("Result: %s" % str(result))
	assert(result == true)
	
	_test_insert_uncommon_sticker(tape)
	dlog("Rare/Uncommon sticker tape: %s" % tape.get_snapshot())
	result = validate_tape(tape)
	dlog("Result: %s" % str(result))
	assert(result == true)
	
	_test_insert_bad_forecast_sticker(tape)
	dlog("Incompatible sticker tape: %s" % tape.get_snapshot())
	result = validate_tape(tape)
	dlog("Result: %s" % str(result))
	assert(result == false)

	tape.stickers.pop_back()
	
	_test_insert_invalid_sticker(tape)
	dlog("Incompatible attribute on sticker tape: %s" % tape.get_snapshot())
	result = validate_tape(tape)
	dlog("Result: %s" % str(result))
	assert(result == false)
	
	tape.stickers.pop_back()
	
	tape.stickers.push_back(tape.stickers[0].duplicate())
	_test_add_invalid_stat_boosting_attribute(tape.stickers.back())
	dlog("Invalid too high stat boosting attribute on sticker: %s" % tape.get_snapshot())
	result = validate_tape(tape)
	dlog("Result: %s" % str(result))
	assert(result == false)
	
	tape.stickers.pop_back()

	_test_insert_invalid_too_many_attributes_sticker(tape)
	dlog("Too many rare attributes sticker tape: %s" % tape.get_snapshot())
	result = validate_tape(tape)
	dlog("Result: %s" % str(result))
	assert(result == false)
	
	tape.stickers.pop_back()
	
	_test_insert_invalid_rarer_attribute_than_sticker(tape)
	dlog("Sticker with attributes of rarity higher than itself: %s" % tape.get_snapshot())
	result = validate_tape(tape)
	dlog("Result: %s" % str(result))
	assert(result == false)
	
	tape.stickers.pop_back()
	
	for n in range(tape.stickers.size(), MonsterTape.MOVE_SLOTS_HARD_LIMIT):
		tape.stickers.push_back(tape.stickers[0])
	# now we have 16 stickers
	dlog("total of %d stickers" % tape.stickers.size())
	result = validate_tape(tape)
	dlog("Result: %s" % str(result))
	assert(result == false)
	
	tape.stickers.push_back(tape.stickers[0])
	dlog("added one more: total of %d stickers" % tape.stickers.size())
	dlog("Too many stickers tape: %s" % tape.get_snapshot())
	result = validate_tape(tape)
	dlog("Result: %s" % str(result))
	assert(result == false)
	

	
	# TODO: implement tests for attributes rarer than sticker
