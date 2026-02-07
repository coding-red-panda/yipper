# Yipper Changelog

## 1.5.3

- Header is now stylized
- Header can now be hidden

## 1.5.2

- Don't use Insets for padding
- Moved message scroll frame right point to do better "padding"
- Moved message scroll frame left point to do better "padding"

## 1.5.1

- Quoted text in emote-messages is now highlighted properly.

## 1.5.0

- Play a preview sound when selecting the notification sound.

## 1.4.3

- Explain the usage of keywords better.

## 1.4.2

- Changing the Alpha settings only affects the tracking window.

## 1.4.1

- Messages are now timestamped in the message list.
- AddOn tracks its version now

## 1.4.0

- Disable event processing during loading screens to avoid corrupt data.

## 1.3.3

- Stop sending notification sounds for your own messages.

## 1.3.2

- Use `GetPlayerInfoByGUID` instead of `UnitTokenFromGUID`

## 1.3.1

- Fixed a bug where the highlighting went haywire if no keywords were set.

## 1.3.0

- Added support for tracking keywords in messages
- Keyword and player names are now highlighted properly
- partial matching supported
- The same logic is also applied to sound notifications

## 1.2.0

- Added notification sound when message with player name is received
- Added support for setting the notification sound
- Added support for setting the notification color

## 1.1.6

- Added a slider to set the font-size of the message text
- Added support for tracking rolls using AddOn Comms

## 1.1.5

- MessageFrame is now scrollable

## 1.1.4

- Fixed a small typo in the UI.Settings.lua file

## 1.1.3

- Preserve previous applied color when cancelling the `ColorPickerFrame`
- Init `ColorPickerFrame` with the current color

## 1.1.2

- Fixed a bug in the onCancel function of the `ColorPickerFrame`

## 1.1.1

- Assign the correct AddOn Category to Yipper
- Assign the correct Icon to Yipper

## 1.1.0

- Added the Settings Window
- Activated the minimap button
- Added a minimap toggle in the settings window
- Added support for the window colors
- Added support for the window border colors
- Added support for the window transparency

## 1.0.4

- Preserve the state of the main window's display setting.

## 1.0.3

- Don't process system messages when they're secret.

## 1.0.2

- Account for messages not being initialized yet on new characters

## 1.0.1

- Removed left-over debug code

## 1.0.0

- Initial functionality
- Tracks specific messages
- Uses default color coding
