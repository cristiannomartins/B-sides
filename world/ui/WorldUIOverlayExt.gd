extends "res://world/ui/WorldUIOverlay.gd"


class_name WorldUIOverlay

func _get_tape_hp(character:Character)->Rational:
	if SaveState.party.is_using_bt():
		if character == SaveState.party.player:
			for tape in SaveState.party.player_alt_tapes:
				return tape.hp
		if character == SaveState.party.partner:
			for tape in SaveState.party.partner_alt_tapes:
				return tape.hp
	return ._get_tape_hp(character)
	

