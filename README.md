## Handheld Streaming Service Utility 
This script will provide a UI to select any URLs found in the `data/links.index` source file,  and add them to Steam.  It is compatible with any dsitro, provided you can fufill the add to steam dependency. for greatest ease of use a handheld distro such as Bazzite or SteamOS,  CachyOS and Nobara should also work but require installing the flatpak package.  
is best suited for Gamescope-Session but can be used with big picture mode as well. it essentially automatically creates web apps for streaming services that are added as non steam games in your library 

## Dependencies 
Flatpak, steamos-add-to-steam (present on all handheld oriiented distros, also on the AUR, might have to get creative on other distros)

<table>
  <tr>
  </tr>
</table>

## Browser Selection

When running the script, you will be prompted to select the browser you would like to use for all URLs. You can choose between:

1. **Google Chrome** (Best Compatibility)
2. **Brave Browser**: (Best Privacy)

## Supported URLs
The list below is based on the index found in the source tree and may not contain the full list.  Review [data/links.index](/data/links.index) for the most up-to-date data.

* [ABC IView](https://iview.abc.net.au)
* [AirGPU](https://app.airgpu.com)
* [Amazon Luna](https://luna.amazon.com/)
* [Amazon Prime Video](https://www.amazon.com/video)
* [Angry Birds TV](https://www.angrybirds.com/series/)
* [Antstream](https://live.antstream.com/)
* [Apple TV](https://tv.apple.com/)
* [BBC iPlayer](https://www.bbc.co.uk/iplayer/)
* [BritBox](https://britbox.com)
* [Binge](https://binge.com.au)
* [Blacknut](https://www.blacknut.com/en-gb/games)
* [Boosteroid](https://cloud.boosteroid.com)
* [CBBC](https://www.bbc.co.uk/cbbc)
* [CBeebies](https://www.bbc.co.uk/cbeebies)
* [Channel 4](https://www.channel4.com/)
* [Crave](https://www.crave.ca/)
* [Criterion Channel](https://www.criterionchannel.com)
* [Crunchyroll](https://www.crunchyroll.com/)
* [Curiosity Stream](https://curiositystream.com)
* [Daily Wire](https://www.dailywire.com/watch)
* [Discord](https://discord.com/app)
* [Disney+](https://www.disneyplus.com/)
* [DocPlay](https://www.docplay.com)
* [Dropout](https://www.dropout.tv/browse)
* [Emby Theater](https://emby.media/)
* [Fox](https://www.fox.com/)
* [Fubo TV](https://www.fubo.tv)
* [GeForce Now](https://play.geforcenow.com/mall/)
* [GBNews Live](https://www.gbnews.com/watch/live)
* [GlobalComix](https://globalcomix.com/)
* [Google Play Books](https://play.google.com/store/books)
* [HBO Max](https://www.max.com/)
* [Home Assistant](https://demo.home-assistant.io/)
* [Hulu](https://www.hulu.com/)
* [Internet Archive Movies](https://archive.org/details/movies)
* [ITV X](https://www.itv.com/)
* [Kanopy](https://www.kanopy.com)
* [Microsoft Movies and TV](https://apps.microsoft.com/movies)
* [My5](https://www.channel5.com/)
* [Nebula](https://nebula.tv/)
* [Netflix](https://www.netflix.com/)
* [Newgrounds Movies](https://www.newgrounds.com/movies)
* [Newgrounds Games](https://www.newgrounds.com/games)
* [Kogama](https://www.kogama.com/)
* [Paramount+](https://www.paramountplus.com/)
* [Peacock TV](https://www.peacocktv.com/)
* [POP Player](https://player.pop.co.uk/)
* [Puffer](https://puffer.stanford.edu/player/)
* [Plex](https://app.plex.tv/)
* [Pocket Casts](https://play.pocketcasts.com)
* [Poki](https://poki.com/)
* [Reddit](https://www.reddit.com/r/all/)
* [SBS Ondemand](https://www.sbs.com.au/ondemand/)
* [Scratch](https://scratch.mit.edu/explore/projects/all)
* [Sling TV](https://www.sling.com)
* [Spotify](https://open.spotify.com/)
* [Stan](https://www.stan.com.au)
* [Steam Broadcasts](https://steamcommunity.com/?subsection=broadcasts)
* [Squid TV](https://www.squidtv.net/)
* [TikTok](https://www.tiktok.com/)
* [Threads](https://www.threads.net/)
* [Twitch](https://www.twitch.tv/)
* [Twitter](https://twitter.com/)
* [Vimeo](https://vimeo.com/)
* [Virgin TV Go](https://virgintvgo.virginmedia.com/en/home)
* [VK Play](https://cloud.vkplay.ru/)
* [Xbox Game Pass Streaming](https://www.xbox.com/play)
* [Xiaohongshu (RedNote)](https://www.xiaohongshu.com/explore)
* [YouTube Music](https://music.youtube.com/)
* [YouTube TV](https://tv.youtube.com/)
* [YouTube](https://www.youtube.com/)
* [WebRcade](https://play.webrcade.com/)

## Installation Command

```
curl -L https://github.com/MurderFromMars/HandheldStreamingServiceUtility/raw/main/install.sh | bash
```

Return to Gamescope, and use the [SteamGridDB](https://github.com/SteamGridDB/decky-steamgriddb) Decky plugin to add images to the new streaming services launchers.

### Enabling Native Touch Support
After opening a shortcut, enable native touch support to improve the user experience.

* Open controller settings for the platform.
* Select `Edit Layout`.
* Select `Action Sets`.
* Select the `Default Settings` gear.
* Select `Add Always-On command`.
* Select `Add command`.
* Select `System`.
* Select `Touchscreen Native Support`.

Return to your application screen, and use touch input.

### Uninstalling
1. Delete the launchers from Steam.
2. Remove the related .desktop files from ~/Applications.
3. Delete steamfork-browser-open from ~/bin.

## Credit For Original.Concept and Code.

This project was originally called SetupStreamingServices and was created by the lead dev of SteamFork. a SteamOS clone distro that is now defunct and no longer being maintained.
as the code was archived I was unable to actually fork the project, so instead copied the source code and made some alterations. I plan to continue maintaining this as I personally use it on my handheld devices. 
