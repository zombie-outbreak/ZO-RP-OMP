# ZO-RP-OMP
![play.zo-rp.com](https://img.shields.io/badge/play.zo--rp.com-e01b24.svg?style=for-the-badge) [![zo-rp.com](https://img.shields.io/badge/zo--rp.com-ff7800.svg?style=for-the-badge)](https://zo-rp.com/)

## Why?
ZO-RP has for its whole lifetime been closed source. Only a select few people have ever had access to versions of the game mode. I have decided that in the best interest of preserving this game mode and hopefully building it up into something truly amazing that I will open source the latest version I have been working on. The hope is that in time, more people can contribute to the source and we can create the best Zombie Roleplay server on the Open Multiplayer platform. This also takes the pressure off me being the only developer and allows the server to have better and potentially more frequent updates.

The gamemode as of writing this (04/04/2025) is incomplete and requires a lot of work to reach v1.0.0. I consider it to still be bare bones and a lot of the code could do with tidying up and optimizing. A lot of the basic ideas are in place and some fo the core functionality is in place.

## Contributing
You can contribute code by submitting a pull request. All pull requests need to be signed off by myself (or eventually other trusted developers) before it is merged into the main branch's source code. The source code is released under the [GPL-3.0 license](https://github.com/zombie-outbreak/ZO-RP-OMP/blob/main/LICENSE).

## Libraries and Tools Required
The following libraries are used. This repository includes the windows DLLs for localhost testing. Please note that the ZO-RP map used on the live server is closed source, and not shared here.

- [Open.MP server v1.4.0.2779](https://github.com/openmultiplayer/open.mp/releases/tag/v1.4.0.2779)
  - Download the Windows version to get the latest version of the PAWN compiler
- [YSI v5.10.0006](https://github.com/pawn-lang/YSI-Includes/releases/download/v5.10.0006/YSI-Includes.zip) (See below for list of YSI libraries currently in use)
  - y_commands
  - y_dialog
- [Streamer Plugin v2.3.6](https://github.com/samp-incognito/samp-streamer-plugin/releases/tag/v2.9.6)
- [samp-bcrypt v0.4.1](https://github.com/Sreyas-Sreelal/samp-bcrypt/releases/tag/0.4.1)
- [Filemanager v1.5.1](https://github.com/JaTochNietDan/SA-MP-FileManager/releases/tag/1.5.1)
- [Weapon Config](https://github.com/oscar-broman/samp-weapon-config)
- [Dialog-Pages v3.3.0](https://github.com/Nickk888SAMP/Dialog-Pages/releases/tag/3.3.0)
- [eSelection](https://github.com/TommyB123/eSelection/blob/db371eb137dfbf6eacab7c7eea661714fd722bde/eSelection.inc)
- [ColAndreas v1.5.0](https://github.com/Pottus/ColAndreas/releases/tag/1.5.0)
  - The Scriptfiles folder on this repo contains the generated files required for the plugin; you will only need the plugin binary and include the file from this link
- [Pawn.RakNet v1.6.0-omp](https://github.com/katursis/Pawn.RakNet/releases/tag/1.6.0-omp)
  - Place the .dll/.so in the components folder.
- [PawnPlus v1.5.1](https://github.com/IS4Code/PawnPlus/releases/tag/v1.5.1)
- [sscanf v2.13.8](https://github.com/Y-Less/sscanf/releases/tag/v2.13.8)
  - I advise using the component version, putting the .dll/.so in the OMP components folder.
- [SA-MP Textdraw Streamer v2.0.3-hotfix](https://github.com/nexquery/samp-textdraw-streamer/releases/tag/v2.0.3-hotfix)

I use [VSCodium](https://vscodium.com/) for my IDE of choice when coding PAWN, with the [PAWN Tools](https://open-vsx.org/extension/southclaws/vscode-pawn) extension. This repository includes the .vscode folder, which has the tasks.json file for setting up the ability to compile the game mode from within VSCodium using CTRL + LEFT SHIFT + B. You can use VsCode as well if you wish as it's basically the same IDE but with added Microsoft telemetry.

Finally, the Zombie skins used in the game were downloaded from [here](https://libertycity.net/files/gta-san-andreas/185232-skiny-zombi-san-andreas.html). The skins originally came from a singleplayer mod called Zombie Andreas Complete.
