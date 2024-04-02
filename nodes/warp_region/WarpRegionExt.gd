extends "res://nodes/warp_region/WarpRegion.gd"


class_name WarpRegionExt

func can_warp(_player)->bool:
	if not boss_room_check:
		return true
	
	if boss_room_check_if_partner != "" and SaveState.party.partner.partner_id != boss_room_check_if_partner:
		return true
	
	if SaveState.has_flag(boss_room_completed_flag):
		return true
	
	var tape_count = 0
	for tape in SaveState.party.get_bt_tapes():
		if not tape.is_broken():
			tape_count += 1
	
	if tape_count < 2:
		WorldSystem.push_flags(WorldSystem.WorldFlags.PHYSICS_ENABLED)
		GlobalMessageDialog.clear_state()
		yield (GlobalMessageDialog.show_message("PLATFORM_DIALOG_REQUIRE_2_TAPES"), "completed")
		WorldSystem.pop_flags()
		return false
	
	return true

