# B-Sides - Battle Team Manager
Welcome to B-Sides: an extended approach to tapes management from your usual "favorites" list on Cassette Beasts. In here, you will be able to create your own teams based on your choice of setup, share these creations by the import / export feature, and more.

As you advance through the game, you will notice more and more extra features and battle options being unlocked. You'll soon realize, for some of them, you could apply different strategies, requiring you to keeping switching between different tapes' setups. Moreover, when on multiplayer, there is the pressing issue of not wanting to take too much time setting up a team to play with your friends while they wait.

Also, giving the rarity of certain tapes, more often than not that tape is used with one unique setup, which doesn't play well for different teams when you use it on them, but having to manually select up to 16 stickers for each of the 6 tapes that are part of a team (without even considering later on rearranging them for other team setups) can be a hustle.

B-Sides, as a mod to the game, tries to minimize the time taken to switch teams, reassign stickers to tapes, and having to find important tapes for a team on storage when you need them.

## Battle teams
On this mod, battle teams are referred to simply as B-Sides. Trying to keep alive the theme of cassette tapes and music from the original game, this is based on the idea that, as cassette tapes in real life, the ones on the game have a b-side to them. When you have any setup of tapes with stickers in hand, you can request to save them as mixtapes (which is equivalent to a team), name that collection of tapes, and save it for later. Whenever you feel like it, you could load a certain set of mixtapes as the b-side of the tapes currently on your party, and use them to battle wild encounters, raids, and even friends. 

![New buttons added to Party Menu to give access to the mod options](/screenshots/party_menu.png)

In order to access the mods options, two new buttons are present on the party menu: the first one allows for saving the current party configuration of tapes as a mixtape set, and the second is used for switching between any mixtape sets and the current party.

![Party shown as an option for one of the teams to be loaded](/screenshots/bt_selection_menu_party.png)![Mixtape's set selection UI](/screenshots/bt_selection_menu.png)

While checking the list of B-Sides available, two screens can be seen: one for your current party tapes, giving the options to unload any current mixtapes in use and go back to using the party, and another one for importing external teams. For teams to be available for importing, the respective exported file needs to be placed inside user://battle_teams/sharing folder. If multiple files are present when importing, the game will give the option to select individually or importing all at once. Imported files can be imported again, creating a copy of the mixtapes: in order to avoid having to deal with it every time, any imported files will be moved into user://battle_teams/sharing/imported. If any of these folders don't already exist, the mod will create them once loded.

When checking a mixtapes team on this menu, though, you notice a couple basic differences: first, the title of the screen went from "Party" to the name of the current team being shown in a different color; second, two extra buttons appear, one allowing to permanetly erase the mixtape set, and another one for exporting it to a file; and third, tapes from a mixtape team will always have 5 stars to them, even if the original tapes from the team used to create them was not at 5 stars yet. This last one is done because mixtapes will not gain EXP from battles, and any battles that grant EXP will apply them directly to the current party of tapes, not their B-Sides. As stats increase when reaching 5 stars, mixtapes will always be able to compete with their best possible stats.

> [!TIP]
> As mixtapes are saved on a shared folder inside user:// domain, they can be shared between savefiles on the same machine. Thus, you can create a mixtape set on the first savefile, and use it on the second one. When loading a savefile, if the latest mixtape loaded to that file is not available anymore, the party will default to unloading the team and going back to the party tapes.

![B-Sides loaded into Party Menu](/screenshots/party_menu_loaded_bsides.png)

To indicate a mixtapes set is loaded, a couple of UI cues were included to the party menu: the name of the loaded team can be seen on the bottom left corner of the screen, the recording button is now used for saving changes to the current team on the menu, and b-sides of tapes are yellow colored, with a "side: B" stamp on them. This change is useful to identify tapes from battle teams when accessing them from other menus, such as the inventory when using healing items. The tape jam icon, also included as a sticker on these tapes, indicate there are some limitations to what can be edited on them, as discussed on the next section.

## Mixtapes limitations
Mixtapes' set are not real tapes: they are a simplified version of tapes used for convinience. As such, they have some limitations to them, and unsupported options should appear hidden or disabled on the UI. These include the ability to move a tape from a team to the tape storage, adding or peeling stickers from side-B tapes, and marking them as favorites or renaming them. Certain features, like having them marked as favorites, still can appear if the original tape used as part of the team was marked as such, but this is not an editable feature, as favorite marks only serves a purpose on the storage, which is not supported by these tapes.

Moreover, tapes from mixtapes' set can have their order changed on the team, and stickers moved around (also changing their order), but this is pretty much what can be done to edit a team after saving it. Currently, there are no plans to include any of these features, or to allow renaming teams as well (although this could change).

When sharing a team, a special file will be created inside user://battle_teams/sharing. The name of the file is not important, except for its extensions (anything before the first dot is fair game to be changed). The only purpose of the created name is to identify when a team was already exported, and ask the user if they want to overwrite the exported file.

> [!NOTE]
> All and all, battle teams are implemented as overlays to the real tapes on the party. As such, certain menus will still refer to the original tapes set to your party (the tapes' "a-side"), such as the trading menu and the tape storage menu.

## Community mods compatibility
This mod is autosuficcient and doesn't have any dependences to other mods. Besides that, as of now, most mods present on modworkshop for the game are compatible with this mod. The only mod I had to specifically write code to avoid having issues with was Battle Arena (for reasons of not wanting to ignore the rules of the arena and allow players to enter it with tapes that should not be allowed on restricted modes), but other than that I did not encounter real issues (yet!). If you like the mod and want to help, feel free to clone the repo and submit pull requests :)

> [!CAUTION]
> B-Sides does not edit or add information to the game's savefile, as all information needed is stored on a separate folder inside user://battle_teams. However, any mods should not be considered completely safe for the game, as they are not guaranteed to continue to work after oficial updates from the devs' team. That being said, remember to backup your saves to prevent any data losses or save file corruption of any kind before trying mods out.

## License
The source icons are Bytten Studio / Raw Fury.

Everything else is licensed under the terms of the MIT license.
