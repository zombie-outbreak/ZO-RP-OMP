# ZO-RP-OMP
![play.zo-rp.com](https://img.shields.io/badge/play.zo--rp.com-e01b24.svg?style=for-the-badge) [![zo-rp.com](https://img.shields.io/badge/zo--rp.com-ff7800.svg?style=for-the-badge)](https://zo-rp.com/)

## Why?
ZO-RP has for its whole lifetime been closed source. Only a select few people have ever had access to versions of the game mode. I have decided that in the best interest of preserving this game mode and hopefully building it up into something truly amazing that I will open source the latest version I have been working on. The hope is that in time, more people can contribute to the source and we can create the best Zombie Roleplay server on the Open Multiplayer platform. This also takes the pressure off me being the only developer and allows the server to have better and potentially more frequent updates.

The gamemode as of writing this (04/11/2025) is incomplete and requires a lot of work to reach v1.0.0. However, it has now entered the beta phase of development and the server is now open without a password. It is now much more feature complete but with player feedback more might still be added yet. Consider this v0.1.X

## Contributing
You can contribute code by submitting a pull request. All pull requests need to be signed off by myself (or eventually other trusted developers) before it is merged into the main branch's source code. The source code is released under the [GPL-3.0 license](https://github.com/zombie-outbreak/ZO-RP-OMP/blob/main/LICENSE).

## Libraries and Tools Required
The following libraries are used. This repository includes the windows DLLs for localhost testing. Please note that the ZO-RP map used on the live server is closed source, and not shared here.

- [Open.MP server v1.4.0.2779](https://github.com/openmultiplayer/open.mp/releases/tag/v1.4.0.2779)
  - Download the Windows version to get the latest version of the PAWN compiler
- [SA-MP-MySQL R41-4](https://github.com/pBlueG/SA-MP-MySQL/releases/tag/R41-4)
- [Streamer Plugin v2.3.6](https://github.com/samp-incognito/samp-streamer-plugin/releases/tag/v2.9.6)
- [samp-bcrypt v0.4.1](https://github.com/Sreyas-Sreelal/samp-bcrypt/releases/tag/0.4.1)
- [Filemanager v1.5.1](https://github.com/JaTochNietDan/SA-MP-FileManager/releases/tag/1.5.1)
- [samp-plugin-xml v1.0](https://github.com/Marevin/samp-plugin-xml)
  - Originally from github.com/Zeex/samp-plugin-xml but looks as though the original repository has been deleted
- [Weapon Config](https://github.com/oscar-broman/samp-weapon-config)
- [Dialog-Pages v3.3.0](https://github.com/Nickk888SAMP/Dialog-Pages/releases/tag/3.3.0)
- [eSelection](https://github.com/TommyB123/eSelection/blob/db371eb137dfbf6eacab7c7eea661714fd722bde/eSelection.inc)
- [easyDialog](https://github.com/Awsomedude/easyDialog/blob/master/easyDialog.inc)
- [ColAndreas v1.5.0](https://github.com/Pottus/ColAndreas/releases/tag/1.5.0)
  - The Scriptfiles folder on this repo contains the generated files required for the plugin; you will only need the plugin binary and include the file from this link
- [Pawn.RakNet v1.6.0-omp](https://github.com/katursis/Pawn.RakNet/releases/tag/1.6.0-omp)
  - Place the .dll/.so in the components folder.
- [Pawn.CMD v3.4.0-omp](https://github.com/katursis/Pawn.CMD/releases/tag/3.4.0-omp)
  - Place the .dll/.so in the components folder.
- [PawnPlus v1.5.1](https://github.com/IS4Code/PawnPlus/releases/tag/v1.5.1)
- [sscanf v2.13.8](https://github.com/Y-Less/sscanf/releases/tag/v2.13.8)
  - I advise using the component version, putting the .dll/.so in the OMP components folder.
- [SA-MP Textdraw Streamer v2.0.3-hotfix](https://github.com/nexquery/samp-textdraw-streamer/releases/tag/v2.0.3-hotfix)

I use [Visual Studio Code](https://code.visualstudio.com/) for my IDE of choice when coding PAWN, with the [PAWN Tools](https://marketplace.visualstudio.com/items?itemName=southclaws.vscode-pawn) extension as well as [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) and [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) for additional auto-completion and coding assistance/debugging (not required). This repository includes the .vscode folder, which has the tasks.json file for setting up the ability to compile the game mode from within Visual Studio Code using CTRL + LEFT SHIFT + B.

You can also use [VSCodium](https://vscodium.com/) with the [PAWN Tools](https://open-vsx.org/extension/southclaws/vscode-pawn) extension if you don't want Microsoft's telemetry, I am not sure/haven't checked if the GitHub Copilot extensions work with VSCodium.

Finally, the Zombie skins used in the game were downloaded from [here](https://libertycity.net/files/gta-san-andreas/185232-skiny-zombi-san-andreas.html). The skins originally came from a singleplayer mod called Zombie Andreas Complete.

## Useful tools (not required)
The following are links to useful tools that can assist in development.

- [GTASA Gangzone Editor](https://dev.prineside.com/en/gtasa_gangzone_editor/)
  - Useful for setting up new territories in game as it can give you an idea of size and shape, as well as the required coordinates to create one.
- [PawnKit color generator](https://pawnokit.ru/en/colorgen)
  - Useful for mocking up some colours if you need them.
  - Any method that gets you 0xFFFFFFAA formatted colours works.
- [XAMPP](https://www.apachefriends.org/)
  - Useful if you want a quick localhost mysql server with phpmyadmin to use for a test database host for the gamemode.
  - Although XAMPP itself is not required and you can install a database and manage it however you like, a MySQL database is required to host this gamemode for testing or otherwise.