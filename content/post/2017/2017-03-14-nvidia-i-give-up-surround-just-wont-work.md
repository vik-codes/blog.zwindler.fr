---
title: 'You’ve won NVidia, I give up. Surround (Triple Screen) just won’t work'
authors:
  - zwindler
type: post
date: 2017-03-14T12:00:25+00:00
url: /2017/03/14/nvidia-i-give-up-surround-just-wont-work/
image: /2017/03/LUOWehvo_400x400.jpeg
categories:
  - materiel
tags:
  - BF3
  - BF4
  - Dragon Age Origin
  - EA
  - Giving up
  - GTA-V
  - GTX
  - Metro 2033
  - Nvidia
  - Open Letter
  - Rise of the Argonauts
  - SLI
  - Surround

---
In this post, I’ll tell you why I tried so hard to make Surround work, and why I finally give up after all the (absence of) effort NVidia made in return.

[French Reader]Comme il m’arrive d’en faire rarement, ceci est à la fois un article d’opinion et un article en anglais. La version Française est [disponible ici](/2017/03/14/fr-youve-won-nvidia-i-give-up-surround-triple-screen-just-wont-work/).[/French Readers]

## I’m an enthousiast

Long time Nvidia Fan, I’ve always liked your products. The first GPU I bought with my own pocket money (which I saved for months!) was a [GeForce 4 Ti 4200][2]. Since then, I have (nearly) never gone the other side.

![](/2017/03/nvidia-geforce4-ti4200.jpg)

I got really serious when the 770 got out. I had a 570 then and with Battlefield 3 out in the wild, I knew I couldn’t hope to get it running on 3 screens with a decent framerate, even if I dropped all the shiny graphics. So I cracked open my economies, bought a 770 and 2 additional screens.

This was so awesome. The immersion was so intense.

![](/2017/03/IMG_20131225_204426.jpg)

This was also a BIG avantage on the other players, the angle of view being much wider.

![](/2017/03/umadbro-1.jpg)

But really what I liked the most was the fact that I was IN the game. Litteraly. My wife might tell you of those times she startled me just by entering the room.

## But it won’t get any better

No, it won’t. Although I had hoped it would. I work as a sysadmin: so, relating to my own work, I figured that it could only be improved over time. Drivers would get better, games would be optimized, OSes would support it better, etc.

### I should have sticked to BF3

As soon as I tried other games, I realized that BF3 might be the exception rather than the rule.

Most of the time, games I played wouldn’t support it and force me to FullHD (games with fixed resolutions). And that was &lsquo;nearly’ the best case scenario. Sometimes, I’d THINK the game supported it, but during play the HUD would be outside the screen or so far on each screens that I’d come to the conclusion (after some time) that I couldn’t play the game like this. Some times cinematics wouldn’t work.

In some extreme cases, the game would launch on one screen, but the image would be so distorded that I could guess that it tried to adapt the image of 3 screens on one (Rise of the Argonauts & Metro 2033). The only option in that case was to quit the game and disable Surround completely for duration of the gaming session.

I hear you saying « HA! That’s the game’s fault if it doesn’t support Surround, not NVidia’s ». I have to agree to some extent. NVidia is not the only responsible here, but they still have a part in this. Should they support Surround as they claim they do, they would have given the tools for the game devs to help them build Surround compatible games.

At the very least, they should have given a way to switch off surround easily, or even better, transparently. Let’s go over the Surround ON/OFF procedure, shall we ?

![](/2017/03/nvidia_on_off.png)

> From tacc (nvidia forum)

Of course, there are « shortcuts » with a combination of CTRL + ALT + [a letter] to automate it, but fear not, I’ll get back to that later.

### SLI and Surround

I’ll be honest. My framerate when playing BF3 on 3x FullHD even with lowered graphics was a little low. I’ve never been a 60 FPS kind of gamer and I could cope with it.

But as soon as BF4 came out, I realized that my 770 wouldn’t be enough. Although the games where only 1 year apart, BF4 was clearly either less optimised or more graphics intensive. I had massive framerates drops leading to painful lag and the most economical option for me, even if I was reluctant to go for it, was SLI. The other valid option would have been the 780Ti but the price wasn’t in my league.

![](/2017/03/IMG_20141104_221126.jpg)

And as you might know, SLI is a joke. Always has been.

I had always refused to try it because of the long history of buggy SLI (or Crossfire) setups around me. And that’s not taking into account the limitations (same GPU chip, if possible 100% identical models, GPU virtual memory is not shared, ...).

But SLI AND Surround might very well be the most experimental you can get. At least until people start going multiple GPUs vendor with DX12. This will definitely be fun to watch: people banging their heads because they mixed AMD and NVidia. A little like Frankeinstein monster or Debian GNU kFreeBSD (a fusion of FreeBSD kernel and Debian packaging system).

The funniest of this is my experience with GTA-V. Even with the lowest settings, in Surround and SLI, I would come across the most bizarre bugs in the game at random times.  
![](/2017/03/2015-05-04_00003.jpg)


After more than 50 (not kidding) useless emails exchanged with the support of GTA-V, the answer came from NVidia Surround community. Helifax, a player of Witcher III [had spent hours to make an extensive testing on SLI performance, depending on how the screens were plugged on the cards][9].

> HOW. THE. SCREENS. WERE. PLUGGED.

And indeed, I can confirm that changing where my screen cables were miraculously fixed my issues.

So I selled both my 770 and bought (painfully) a 1080, the ONLY card capable of running current games on 3 screens. I still can’t play in Surround when games don’t support it, but at least I can play without my SLI crashing around.

[Carte Graphique MSI Nvidia GeForce GTX 1080 GAMING X 8G](https://www.amazon.fr/gp/product/B01GELBO1C)

### Surround and Windows 10

I don’t always play on my computer, I also work with it.

RDP Client MSTSC doesn’t support surround. You have to switch off Surround or you will have a 21:9 screen distributed across you 3 screens, with big black holes on most of the outer screens.

So for some reason, I thought that Windows 10 would support Surround better. I switched as soon as I could from Windows 7 to Windows 10, as many users did.

But **after 18 months,** Surround still doesn’t work properly on Windows 10 :  
- Resizing windows is a pain in the back. Maximizing apps (like a browser for example), will make it use the whole 3 screens. I have to resize all my windows manually. [Edit]Either latest driver fix the issue or it works randomly[/Edit]  
- By default, the windows bar takes the whole 3 screens, which is really unusable. Hopefully, with the NVidia driver, the Windows bar « can » be placed only on the middle screen (or the right if you prefer), but when you click the Windows Home Button, it will ALWAYS pop the menu on the left screen. The « solution » ? Place the bar on the left screen. I hope you don’t get stiff necks often, 'cause I do.  
![](/2017/03/nvidia_surround_windows10.png)
- But funniest of all. You remember when I was raving about the « Surround switching off procedure » but then told you there was a « hotkey » to automate it ? The **ON/OFF surround key combination won’t work anymore**. I go for the manual procedure « tacc » detailed each freaking time I need to launch a game or mstsc or whatever.

## NVidia killed Surround Enthousiasts

Don’t take my word for it. If you need another point of view, I invite you to read the messages [in the Surround community in the NVidia forum][11].

So, fine NVidia. I’ll stop bothering you with Surround, I’ve moved on.

I guess you might as well drop it, because I wonder if there is any resistance left among the NVidia enthousiasts.

**But then, maybe it was your plan all along?**

 [2]: http://www.hardware.fr/articles/419-1/nvidia-geforce4-ti-4200.html
 [9]: https://forums.geforce.com/default/topic/839311/nvidia-surround/-how-to-wticher-3-3d-surround-benchmark-solution/
 [11]: https://forums.geforce.com/default/board/47/nvidia-surround/
