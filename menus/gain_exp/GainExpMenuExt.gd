extends "res://menus/gain_exp/GainExpMenu.gd"

class_name GainExpMenuExt

func _init():
	._init()
	SaveState.party._return_from_battle()
	reset_party()


func add_character(character:Character, tape:MonsterTape):
	assert (character != null)
	if tape == null:
		for alt_tape in character.tapes:
			if not active_tapes.has(alt_tape):
				tape = alt_tape
				break
	
	var member = [character, tape]
	party.push_back(member)
	characters.push_back(character)
	if tape != null and not active_tapes.has(tape):
		active_tapes.push_back(tape)
		inactive_tapes.erase(tape)

	for alt_tape in character.tapes:
		add_tape(alt_tape)
	
	fusion_unlocked = fusion_unlocked or character.is_fusion_unlocked()
