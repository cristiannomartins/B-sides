extends "res://nodes/actions/PartyHas2TapesAction.gd"

class_name PartyHas2TapesActionExt

func _run():
	var count = 0
	for tape in SaveState.party.get_bt_tapes():
		if not tape.is_broken():
			count += 1
	return count >= 2
