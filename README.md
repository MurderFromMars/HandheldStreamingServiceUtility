# Handheld Streaming Service Utility

The Handheld Streaming Service Utility converts streaming platforms into fullscreen Chrome web apps and registers them as launchable applications. On handheld friendly distros, these apps are automatically added to Steam; on other Linux systems, they appear in your application menu.

The utility reads from `data/links.index`, presents a checklist of available services, and generates `.desktop` launchers for each selected entry.

---

## Features

- **Automatic Chrome Flatpak installation**  
  If Google Chrome (Flatpak) is not installed, the script installs it automatically (requires `sudo`).

- **steamos-add-to-steam auto‑detection**  
  - On distros including steamos-addt-steam: apps are created in `~/Applications` and automatically added to Steam.  
  - On other Linux systems: apps are created in `~/.local/share/applications` and appear in your desktop environment’s launcher.

- **Automatic permissions for Chrome**  
  - Grants Chrome access to `~/Applications` on devices where apps are added to steam.  
  - Grants Chrome access to `/run/udev` for controller support.

- **Zenity-based service picker**  
  A graphical checklist lets you choose which services to install.

- **Markdown export**  
  A formatted list of all services is generated at `output/links.md`.

- **Failsafe applist handling**  
  If `links.index` is missing locally, it is downloaded automatically from the repository.

---

## Requirements

The script handles most dependencies automatically, but you should have:

- Flatpak  
- Zenity  
- `sudo` (only required if Chrome Flatpak must be installed)

Optionally,, `steamos-add-to-steam` is detected automatically and used if available.


## Supported Services

The list below reflects the entries currently referenced in the project’s index file.  
For the most accurate and complete list, check `data/links.index` in the repository.

- ABC IView  
- AirGPU  
- Amazon Luna  
- Amazon Prime Video  
- Angry Birds TV  
- Antstream  
- Apple TV  
- BBC iPlayer  
- BritBox  
- Binge  
- Blacknut  
- Boosteroid  
- CBBC  
- CBeebies  
- Channel 4  
- Crave  
- Criterion Channel  
- Crunchyroll  
- Curiosity Stream  
- Daily Wire  
- Discord  
- Disney Plus  
- DocPlay  
- Dropout  
- Emby Theater  
- Fox  
- Fubo TV  
- GeForce Now  
- GBNews Live  
- GlobalComix  
- Google Play Books  
- HBO Max  
- Home Assistant  
- Hulu  
- Internet Archive Movies  
- ITV X  
- Kanopy  
- Microsoft Movies and TV  
- My5  
- Nebula  
- Netflix  
- Newgrounds Movies  
- Newgrounds Games  
- Kogama  
- Paramount Plus  
- Peacock TV  
- POP Player  
- Puffer  
- Plex  
- Pocket Casts  
- Poki  
- Reddit  
- SBS OnDemand  
- Scratch  
- Sling TV  
- Spotify  
- Stan  
- Steam Broadcasts  
- Squid TV  
- TikTok  
- Threads  
- Twitch  
- Twitter  
- Vimeo  
- Virgin TV Go  
- VK Play  
- Xbox Game Pass Streaming  
- Xiaohongshu (RedNote)  
- YouTube Music  
- YouTube TV  
- YouTube  
- WebRcade  

## Installation

Run the following command in your terminal:

```
curl -L https://github.com/MurderFromMars/HandheldStreamingServiceUtility/raw/main/install.sh | bash
```

After installation, return to Gamescope and use the SteamGridDB Decky plugin to assign artwork to your newly created shortcuts.

## Enabling Touchscreen Support

To improve usability on handheld devices, enable native touch input for each shortcut:

1. Open the controller configuration for the shortcut.  
2. Select Edit Layout.  
3. Open Action Sets.  
4. Choose the Default Settings gear icon.  
5. Add an Always On Command.  
6. Select System.  
7. Enable Touchscreen Native Support.

Once applied, return to the app and touch input will be active.

## Uninstalling

To remove the utility:

1. Delete the generated shortcuts from Steam.  
2. Remove the corresponding `.desktop` files from `~/Applications`.  

## Acknowledgements

This project was inspired by the SetupStreamingServices utility originally created by the talented developers behind the SteamFork distribution. Although SteamFork is no longer maintained, their approach to integrating streaming services into a handheld friendly environment inspired me to continue a spiritual successor of their utility, so I decided to implement my own version of it here. I will continue to maintain this for users who want a streamlined way to access their streaming platforms on handheld devices.
