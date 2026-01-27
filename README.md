# Yipper Addon - World of Warcraft

![Yipper](https://wow.zamimg.com/uploads/screenshots/normal/1088816-yipper.jpg)

## What does it do?

The Yipper AddOn is a continuation on the existing AddOn called `Listener`, 
but tweaked and tuned for pure roleplay purposes. 
This AddOn is developed from scratch and provides the basic functionality to listen to people
in large crowds without depending on any single other AddOn.

## What doesn't it do?

* Does not manipulate Chat in any way
* Does not interact with other AddOns (for now)

## What messages does Yipper track?

* `/s` or `/say`
* `/y` or `/yell`
* `/e` or `/emote`
* Standard emotes
* `/roll` results
* Guild Chat
* Office Chat
* Raid Chat
* Raid Leader Chat
* Party Chat
* Whispers

The AddOn will collect these message for every player (where possible),
and display them in a separate frame when hovering over the specific player.
This allows you to simply see what said player said without having to scroll
through the entire chat window.

## Support and Features

If you wish to contribute to the AddOn, please feel free to open an Issue
on GitHub and describe what you feel is missing.
When time permits, the AddOn will be extended when enough requests come in.

## Settings

The Settings window allows you to configure the following settings:

* The display of the minimap button
* The alpha/transparency of the windows
* The background color of the windows
* The border color of the windows

## Slash Commands
The AddOn provides the following slash commands: `/yip` or /`yipper`

* `/yipper config` - Opens the settings window
* `/yipper help` - Shows this help message
* `/yipper` - toggles the main window

## Dependencies

The AddOn has zero dependencies.
It does not even require things like `LibStub`, `WoWAce` or `LibIconDb`.
This is a 100%, pure lua AddOn.

## License

The AddOn is available as open source software through CurseForge.
I am not going to bother with smacking a license on this, 
but if you use/reference it, please have the decency to credit me.
