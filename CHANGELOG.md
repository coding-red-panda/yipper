# Yipper Changelog

# 1.3.1

- Fixed a bug where the highlighting went haywire if no keywords were set.

# 1.3.0

- Added support for tracking keywords in messages
- Keyword and player names are now highlighted properly
- partial matching supported
- The same logic is also applied to sound notifications

# 1.2.0

- Added notification sound when message with player name is received
- Added support for setting the notification sound
- Added support for setting the notification color

# 1.1.6

- Added a slider to set the font-size of the message text
- Added support for tracking rolls using AddOn Comms

# 1.1.5

- MessageFrame is now scrollable

# 1.1.4

- Fixed a small typo in the UI.Settings.lua file

# 1.1.3

- Preserve previous applied color when cancelling the `ColorPickerFrame`
- Init `ColorPickerFrame` with the current color

# 1.1.2

- Fixed a bug in the onCancel function of the `ColorPickerFrame`

# 1.1.1

- Assign the correct AddOn Category to Yipper
- Assign the correct Icon to Yipper

# 1.1.0

- Added the Settings Window
- Activated the minimap button
- Added a minimap toggle in the settings window
- Added support for the window colors
- Added support for the window border colors
- Added support for the window transparency

# 1.0.4

- Preserve the state of the main window's display setting.

# 1.0.3

- Don't process system messages when they're secret.

# 1.0.2

- Account for messages not being initialized yet on new characters

# 1.0.1

- Removed left-over debug code

# 1.0.0

- Initial functionality
- Tracks specific messages
- Uses default color coding