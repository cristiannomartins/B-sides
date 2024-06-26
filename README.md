# B-Sides - Battle Team Manager
Welcome to B-Sides: an extended approach to tapes management from your usual "favorites" list on Cassette Beasts. In here, you will be able to create your own teams based on your choice of setup, share these creations using the import / export feature, and more.

As you advance through the game, you will notice more and more features and battle options being unlocked. You'll soon realize, for some of them, you could apply different strategies, requiring you to keeping switching between different tapes' setups. Moreover, when on multiplayer, there is the pressing issue of not wanting to take too much time setting up a team to play with your friends while they wait.

Also, giving the rarity of certain tapes, more often than not that tape is used with one unique setup, which doesn't play well for different teams when you use it on them, but having to manually select up to 16 stickers for each of the 6 tapes that are part of a team (without even considering later on rearranging them for other team setups) can be a hustle.

B-Sides, as a mod to the game, tries to minimize the time taken to switch teams, reassign stickers to tapes, and having to find important tapes for a team formation on storage when you need them.

## Battle teams
On this mod, tapes from saved battle teams are referred to simply as B-Sides (or mixtapes, when referring to the combination tape + stickers). Trying to keep alive the theme of cassette tapes and music from the original game, this is based on the idea that, as cassette tapes in real life, the ones on the game have a- and b-sides to them. When you have any setup of tapes with stickers in hand, you can request to record them as a Playlist (which would be equivalent to a team), name that collection of tapes, and save it for later use. Whenever you feel like it, you could load a certain Playlist as the b-side of the tapes currently on your party, and use them to battle NPCs, wild encounters, raids, bosses, and even friends. 

![New buttons added to Party Menu to give access to the mod options](/.screenshots/party_menu.png)

In order to access the mods options, two new buttons are present at the bottom of the party menu: the left one allows for saving the current party configuration of tapes as a B-Sides Playlist, and the middle one is used for switching between any saved Playlists and the current party.

![Party shown as an option for one of the teams to be loaded](/.screenshots/bt_selection_menu_party.png)

While checking the list of B-Sides Playlists available, two main options can be seen: one for using your original party tapes, giving the option to unload any current playlist in use and go back to using the party, and another one for importing external playlists. For a playlist to be available for importing, the respective exported file needs to be placed inside `user://battle_teams/sharing` folder. If multiple files are found when importing, the game will give the option to select from them individually, or importing them all at once. Imported files can be imported again, resulting on a copy of that Playlist: in order to avoid having to select from a big list every time, any successfully imported files will be automatically moved into the `user://battle_teams/sharing/imported` folder. If any of these folders don't already exist, the mod will create them once loaded.

![Mixtape's set selection UI](/.screenshots/bt_selection_menu.png)

When checking a battle team on this menu, though, you notice a couple basic differences: first, the title of the screen went from a white "Party" text to the name of the current playlist being shown in yellow; second, two extra buttons appear at the bottom, one allowing to permanently erase the playlist show at the screen, and another one for exporting it to a file; and third, tapes from a B-Sides Playlist will always have 5 stars on them, even if the original tapes from the team used when creating it were not at 5 stars at the point of recording them as a playlist. This last one is done because mixtapes will not gain EXP from battles, and any battles that grant EXP will apply them directly to the current party of tapes, not their B-Sides. As basic tape stats increase until they reach 5 stars, mixtapes will always be able to rely upon using their best possible stats.

> [!TIP]
> As B-Sides Playlists are saved on a shared folder inside `user://` domain, they are auto-shared between savefiles on the same machine. Thus, you can create a playlist on the first savefile, and access it from a second savefile. Moreover, each savefile can have its individual playlist assigned to them, even though the list of teams is shared. Erasing a playlist in any of them is safe even when different savefiles are using different teams as, when loading a savefile, if the latest playlist loaded to that file is not available anymore, the party will default to unloading the team and going back to the A-side party tapes.

![B-Sides loaded into Party Menu](/.screenshots/party_menu_loaded_bsides.png)

To indicate a B-Sides Playlist is loaded, a couple of UI cues were included to the party menu: the name of the loaded team can be seen on the bottom left corner of the screen, the recording B-Sides button is now used for renaming the Playlist and saving any changes done to the current loaded team (although changes to Mixtape sets are autosaved whenever switching teams), and b-sides of tapes are yellow colored, with a "side: B" stamp on them. This change is useful to identify tapes from battle teams when accessing them from other menus, such as the inventory menu when using healing items. The tape jam icon, also included as a sticker on these tapes, indicate there are some limitations to what can be edited on them, as discussed on the next section.

> [!IMPORTANT]
> Menus are context aware when using a B-Sides Playlist. This means whenever a playlist is loaded, inventory items that can interact with party tapes should react different depending on its purpose. E.g., from the Consumables tab, healing items will be applied to the currently loaded playlist's tapes, while upgrapes will give you the option of selecting tapes from your A-sides, as B-side tapes won't ever need to gain stars.

## Mixtapes limitations
Mixtapes' set are not real tapes: they are a simplified version of tapes used for convinience. As such, they are not considered for completion of quests that require holding a tape (like some of Hoylake's side quests), or for registering new tapes into your bestiary. Furthermore, they have some limitations to them, and unsupported options should appear hidden or disabled on the UI whenever a Playlist is loaded. These include the ability to move a tape between the party and tape storage while on the Party Menu, and adding or peeling stickers from B-side tapes. You can still rename Mixtapes separate from their original A-Side tapes, and mark them as favorites, although the favorite mark to B-Sides are just aesthetic, as these tapes should never leave your Party -- and the favorites tab on tape storage only serves the purpose of showing marked tapes that are not in the current Party. A shortcut for the tape's bestiary entry also only appears on the Tape Menu after you've battled against or recorded that monster species, being hidden if you've only encountered it while using a Mixtape set.

> [!NOTE]
> While having a mixtape set loaded, changes to the party's A-side tapes can only be done via the tape storage menu. Also, be aware that any newly added tapes to your team (when recording a new tape, for example) will default to go directly to the tape storage, even if the A-side party still has empty slots available. 

> [!WARNING]
> The inventory Stickers tab will be completely hidden while any Mixtape set is being used as you should not be able to add or peel stickers from B-side tapes, although it is still possible to access them and add or peel stickers from your own tapes directly from the tape storage menu.

Moreover, tapes from mixtapes' set and their aplied stickers can have their order changed on the team, nicknames changed, and favorite status modified, but this is pretty much what can be done to edit a loaded team from the Party Menu. Currently, there are no plans to include any other features (as most of them, like moving tapes to storage, are purposely removed to avoid introducing duplication glitches to the game via this mod).

All Mixtapes sets and user preferences related to this mod are saved at `user://battle_teams`. The main file is named `b_sides.json.gz.gcpf`, and should not be renamed or moved. When exporting a team, a special file will be created per team inside `user://battle_teams/sharing`. The name of exported files is unimportant, except for its extension (anything before the `.json.gz.gcpf` is fair game to be changed by the player). The only purpose of the created name is to identify when a team was already exported, and ask the user if they want to overwrite the exported file. Thus, if you want to backup your favorite teams individually, you can export them, rename the created files, and save them somewhere else.

> [!NOTE]
> All and all, battle teams are implemented as overlays to the real tapes in the party. As such, certain menus will still refer to the original tapes set to your party (the tapes' "A-sides"), such as the trading and tape storage menus.

## Community mods compatibility
This mod is autosuficcient and doesn't have any dependences for it to work. That being said, if you have modutils installed, it can indicate on the title screen whenever an update is available to download.

Besides that, as of now, most mods present on modworkshop for the game are compatible with this mod. The only two mods I had to specifically write code to avoid having issues with were:
(1) Battle Arena, for reasons related to not wanting to ignore the rules of the arena, and allow players to enter it with tapes that were incompatible with some arena restricted mode, and
(2) Recycle Sticker Bonus, as they add extra options to the sticker management menu, and B-side tapes should not allow their stickers to be edited.

Other than that I did not encounter any real issues (yet!). If you like the mod and want to help, feel free to clone the repo and submit pull requests :)

> [!CAUTION]
> B-Sides does not edit or add information to the game's main savefile, as all information needed is stored on a separate file inside `user://battle_teams`. However, any mods should not be considered completely safe for the game, as they are not guaranteed to continue to work after oficial updates from the devs' team. That being said, remember to backup your saves to prevent any data losses or save file corruption of any kind before trying mods out.

## License
The source icons are Bytten Studio / Raw Fury.

Everything else is licensed under the terms of the MIT license.
