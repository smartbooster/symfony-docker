# Phpstorm

## Install Phpstorm

There is 2 way to install Phpstorm :
- snap package (Ubuntu software) - recommended
```bash
sudo snap install phpstorm --classic
```
- Follow Phpstorm official website order

## Link your licence to Phpstorm

You must link your licence to your phpstorm depending on how you got it :
- By account : Log in on your JetBrains account since your Phpstorm
- By key : Add your licence key
- By license server: Add the server address

## Recommended configuration

### Increase memory settings

Help > Change memory settings : set 2048 MiB as minimum to run dockerized project easily

### Wrap line at 150 character

Settings (ctrl + alt + s) > Code style > Hard wrap at > 150

### Font

Settings (ctrl + alt + s) > Editor > Font
- Font : JetBrains Mono
- Size : 13.0
- Line height : 1.2
- Enable ligatures : ✅

### Editor tabs
_Settings (ctrl + alt + s) > Editor > General > Editor tabs_
- if you want to gain some space on the tab name, you can remove the extension by toggling off "show file extension"

## Recommended plugin

- Symfony Support
- Php Annotations
- .ignore
- .env files support

**Native plugin to disable**
- PHPstan
- php codesniffer

## Enable or Disable New UI

- Top right on toothed wheel > "Enable new UI..." or "Switch to classic UI..."
- Settings (ctrl + alt + s) > search new UI in the search bar > enable or disable "Enable new UI"

## Usefully shortcut
- shift + shift -> quick open file
- ctrl + maj + f -> search into project
- ctrl + maj + r -> replace into project

**Recommended shortcut to assign**   
_Settings (ctrl + alt + s) > Keymap_

- Toggle case -> alt + shift + u