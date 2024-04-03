extends ContentInfo

const DEBUG:bool = false

# can check imported teams for invalid params on tapes, avoiding loading teams that have those
#var validator = preload("scripts/Validator.gd").new()
# responsible for managing saves for the mod, and importing/exporting teams as snapshots
#var storage = preload("scripts/StorageSystem.gd").new()
# makes sure the snapshots from storage exist as tapes when needed and loads/unloads teams
var team_loader = preload("scripts/TeamLoader.gd").new()

var patches = {
	# access party directly via characters
	"BattleSpriteLoader.gd": preload("battle/BattleSpriteLoader_patch.gd").new(),
	# need to prepare for battle in multiplayer mode
	"NetRequestAbstractBattle.gd":
							 preload("global/network/NetRequestAbstractBattle_patch.gd").new(),
	# forces party to be preloaded
	"SaveState.gd":          preload("global/save_state/SaveState_patch.gd").new(),
	# includes support for alternative party (overlay)
	"Party.gd":              preload("global/save_state/Party_patch.gd").new(),
	# hides option to put away tapes when using a BT
	"PartyActionButtons.gd": preload("menus/party/PartyActionButtons_patch.gd").new(),
	# adds options to access / update BTs, and also inhibits direct access to character tapes
	"PartyMenu.gd":          preload("menus/party/PartyMenu_patch.gd").new(),
	# adds different images for tapes menus to represent tapes from BTs
	"TapeButton.gd":         preload("menus/party/TapeButton_patch.gd").new(),
	# disable add / remove stickers when using BTs
	"PartyStickerActionButtons.gd":
							 preload("menus/party_tape/PartyStickerActionButtons_patch.gd").new(),
	# remove unsupported options from check tape's UI when using BT
	"PartyTapeUI.gd":        preload("menus/party_tape/PartyTapeUI_patch.gd").new(),
	# remove menus on storage for unsupported options on BTs
	"TapeActionButtons.gd":  preload("menus/tape_storage/TapeActionButtons_patch.gd").new(),
	# replaces PartyMenu to allow editing BackButtonPanel, send recorded tapes to storage and hides
	# stickers from inventory when BT is in use
	"MenuHelper.gd":         preload("menus/MenuHelper_patch.gd").new(),
	
	# need to verify can_warp some other way
	# "WarpRegion.gd":         preload("nodes/warp_region/WarpRegion_patch.gd").new(),
}

var extensions = {
	# considers BT tapes when any are loaded
	"res://nodes/actions/PartyHas2TapesAction.gd":
		preload("nodes/actions/PartyHas2TapesActionExt.gd"),
	# removes overlay after battle and apply EXP to the real party, instead
	"res://menus/gain_exp/GainExpMenu.gd":
		preload("menus/gain_exp/GainExpMenuExt.gd"),
	# allows using healing items on BT from inventory when any loaded
	"res://data/item_scripts/TapeHealingItem.gd":
		preload("data/item_scripts/TapeHealingItemExt.gd"),
	# shows HP on minimap for tapes from BT, if any loaded
	"res://world/ui/WorldUIOverlay.gd":
		preload("world/ui/WorldUIOverlayExt.gd")
	#"res://nodes/warp_region/WarpRegion.gd":
	#	preload("nodes/warp_region/WarpRegionExt.gd")
}



func _init():
	# applies all patches added above
	for patch in patches:
		patches[patch].patch()
	
	# any final patched script can be printed on output by running this before run_tests
	#patches["Party.gd"].enable_print_final_script()
	
	# validator and storage tests don't depend on a save being loaded, so they can be tested here
	#team_loader.storage.validator.run_tests()
	#team_loader.storage.run_tests()
	
	# replaces classes with extensions of them as defined above
	for ext in extensions:
		extensions[ext].take_over_path(ext)
	
	# registers events we use through the mod
	SaveSystem.connect("file_loaded", self, "_on_file_loaded")
	SceneManager.connect("scene_change_starting", team_loader, "_on_scene_change_starting")
	SceneManager.connect("scene_change_ending", team_loader, "_on_scene_change_ending")
	



func _on_file_loaded():
	for patch in patches:
		patches[patch].delayed_patch()
		
	if DEBUG:
		for patch in patches:
			patches[patch].run_tests()
	
	team_loader._on_file_loaded()
	
	




