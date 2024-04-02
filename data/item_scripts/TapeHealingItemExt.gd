extends "res://data/item_scripts/TapeHealingItem.gd"

class_name TapeHealingItemExt

func custom_use_menu(_node, context_kind:int, context, arg = null):
	if arg != null:
		return arg
	var tapes = SaveState.party.get_bt_tapes()
	if context_kind == ContextKind.CONTEXT_BATTLE:
		tapes = tapes.duplicate()
		var battle = context.battle
		var i = 0
		for f in battle.get_teams(true, false)[context.team]:
			for c in f.get_characters():
				if c.current_tape in tapes:
					tapes.erase(c.current_tape)
					tapes.insert(i, c.current_tape)
					i += 1
				elif not f.status.dead and Character.is_human(c.character.character_kind):
					
					tapes.push_back(c.current_tape)
	
	return MenuHelper.show_choose_tape_menu(tapes, Bind.new(self, "_tape_filter"), Bind.new(self, "_tape_menu_callback", [context_kind, context]))
