# Handheld Streaming Service Utility

The Handheld Streaming Service Utility provides a simple interface for turning streaming platforms into Steam launchable web apps. It reads from the `data/links.index` file, presents the available services, and automatically registers your selections as non Steam shortcuts inside Steam.

Any Linux distribution that supports the “add to Steam” mechanism can run the tool. Handheld focused systems such as SteamOS, Bazzite, CachyOS, and Nobara tend to offer the smoothest experience (some may require installing the Flatpak package first). Although the workflow is optimized for Gamescope Session, it works just as well in Big Picture Mode.

## Requirements

Before running the utility, make sure the following components are available:

- Flatpak
- steamos add to steam  
  (included by default on most handheld oriented distros; available in the AUR; may require manual installation on others)

## Browser Selection

When the script launches, you will be asked which browser should handle all streaming shortcuts. You can choose:

1. Google Chrome — broad compatibility  
2. Brave Browser — privacy focused option  

Your selection applies to all services added during that session.

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
3. Delete the `steamfork browser open` script from `~/bin`.

## Acknowledgements

This project was inspired by the SetupStreamingServices utility originally created by the talented developers behind the SteamFork distribution. Although SteamFork is no longer maintained, their approach to integrating streaming services into a handheld friendly environment inspired me to continue a spiritual successor of their utility, so I decided to implement my own version of it here. I will continue to maintain this for users who want a streamlined way to access their streaming platforms on handheld devices.
