---
title: Can you remove a physical CPU from a dual socket HP DL380 DL385 G6 G7 G8 ?
authors:
  - zwindler
type: post
date: 2015-05-21T17:24:55+00:00
url: /2015/05/21/can-you-remove-a-physical-cpu-from-a-dual-socket-hp-dl380-dl385-g6-g7-g8/
image: /2015/05/IMG_20150430_162441.jpg
categories:
  - Matériel
  - Système
tags:
  - audit
  - CPU
  - CPU blank
  - database
  - DIMM
  - DL380
  - fan blank
  - Gen6
  - Gen7
  - Gen8
  - Oracle
  - RAM
  - Slot
  - SQL Server

---
Comme je l’ai abordé dans mon tout premier article, le but de ce blog est  -de manière générale- d’offrir des solutions à des problèmes pour lesquels on trouve peu d’aide sur Internet : j’entends pas là que je souhaite éviter de poster sur des sujets archi-traités par d’autres personnes sur le Net, et encore plus si c’est en Français.  
Or dans le cas de cet article, j’ai trouvé très peu de réponses à mes questions, même en anglais. Une nouvelle fois, je vais donc rédiger l’article en anglais, pour toucher/aider le plus de monde possible. Je m’excuse pour les plus francophones d’entre vous.

> One of my teachers once told me that it was a difficult job to audit a company, as the auditee often took a defensive posture, sensing consciously or unconscioulsy the auditor as the enemy.

We had received a request of audit from a big database software company. This big company is known to change regularly it’s licensing policy and to activate silently by default licenced features to « trap » unsuspecting customers and then ask them more money afterward. Not a very clean way to do business if you ask me!

Just in case thing had gone out of control on our side, my employer asked me to physically remove one of the sockets on a few servers that had been oversized. The problem is that I don’t have much experience in the hardware side of the servers and that I wanted to gather as much information as possible before doing any modification (those were production servers, haha!).

## Remove the CPU: from the hardware perpective

My main concern was wether or not it was possible to physically remove a CPU from a dual CPU server. I didn’t know if these factory installed processor had being registered in the BIOS or something like that. Though unlikely, I didn’t want to take any chance.

There is no clear guide I could find that tells you if you can do this or not, and how. I found a few PDFs explaining how to _replace_ a (faulty) CPU, but no clear instructions on how to _remove_ one.

The only clues I gathered were found here (dead link, Internet Archive doesn't have it)

Long story short, _yes you can **BUT** you have to do it right_ :

  * remove only CPU n°2, not n°1 (seems obvious, but it can’t hurt to say)
  * **put a blank heatsink in place of CPU n°2**
  * remove all DIMMs associated with CPU n°2
  * **disconnect Fan n°1 and Fan n°2**
  * **put fan blanks in place of Fan n°1 and Fan n°2**

The official **HP ProLiant DL385p Gen8 Server User Guide** will help to identify which is what when you have opened it but won’t give you any more answers ;-)

## Remove the CPU: from the software perpective

The second thing -which rather concerned my teamates- was whether the OS would have trouble to cope with this sudden CPU removal or not.

Unlike my collegues, I was rather confident that this would work, as the OS was a RedHat Entreprise Linux. I knew that you could hotplug/hot-unplug vCPU on virtual machines AND in the past I had changed a whole different motherboard/CPU couple on a home server without reinstalling Linux OS.

But there again, this was production, and we’d rather to be safe than sorry, and I always prefer to back my beliefs with proof.

Hopefully, there is [no reason why it shouldn’t be possible on the OS level](https://access.redhat.com/discussions/747453)

> On the OS level I do not see any issue, just shutdown the server, do the hardware change and boot up again.  
> You will see the number of « logical » CPUs will have dropped.

I find it « funny » to see how those two links I gave you came from people having licensing issues with their database editor ;-)

## The operation itself

Now that all the homework was done, came the scary part. Here is what a DL 385 G8 looks like from the inside

![](/2015/05/IMG_20150430_162107.jpg)

The first task was to remove the screws that maintain the plastic part shaping the airflow in place, then remove the metal piece that hold the CPU heatsinks together.

![](/2015/05/IMG_20150430_162310.jpg)

Once this is done, I could remove the memory DIMMs, the CPU n°2 heatsink and finally the CPU itself. Now if you followed correctly, you will remember that a CPU heatsink blank has to be put in place of the real heatsink. I’ll give you a hundred points if you can find one on the Internet. Same thing for the Fan n°1 and n°2 and their fan blanks counterparts.

My guess is that only maintainers have access to this kind of parts...

![](/2015/05/IMG_20150430_162441.jpg)

In order not to waste RAM on those servers (RAM is not -yet- taken into account by the editor in the license cost calculation), I had planned to gather DIMMs from CPU n°2 and add them to CPU n°1.

I had a good fright when powering up the first server. One thing I had overlooked is that you have to put DIMMs in a certain order. If you don’t, the server will beep a high pitched critical beep until you power it down and correct your mistake.

![](/2015/05/IMG_20150430_165103.jpg)

As you can see, everything is written on the back of the server cover. I just don’t read manuals, it seems. With the DIMMs in the correct order, everything went fine, and neither the hardware nor the OS complained about the missing processor. Happy ending ;-)

![](/2015/05/IMG_20150430_165052.jpg)