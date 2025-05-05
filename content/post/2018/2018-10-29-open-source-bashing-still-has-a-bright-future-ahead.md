---
title: Open source bashing still has a bright future ahead
authors:
  - zwindler
type: post
date: 2018-10-29T19:30:26+00:00
url: /2018/10/29/open-source-bashing-still-has-a-bright-future-ahead/
image: /2018/10/2l8z3e.jpg
categories:
  - systeme
tags:
  - humeur
  - Open Source
  - philosophy
  - SAP
  - sap hana

---
This article is a translation of an article I previous wrote in french and has been asked by a friend of mine.

[French]Pour les francophones qui n’auraient pas lu l’article en Français, il est [disponible ici](/2018/10/19/lopen-source-bashing-a-encore-de-beaux-jours-devant-lui/)[/French]

## Once is not custom

(or maybe twice, as I already wrote an _opinion piece_  [for a weird issue between comics authors and Creative Commons](/2016/09/09/2223/))

Yeah, I have said that I wouldn’t write opinion pieces, but then, who can blame me when I find this in my Twitter from SAP France account (sponsored, of course).

![](/2021/tweet_sapfrance.png)

This comic series (I couldn’t find the author name anywhere) tells the story of a project manager that has to implement a big computer science project. In this particular episode, he thought it was a good idea to try to do it with open source solutions.

But clearly his team fails to deliver, having all sort of « open source » related issues. In the end, it’s **SO MUCH EASIER to choose SAP**.

Riiiight. As if we don’t know anybody among our profesionnal relations that struggled with SAP ;-).

## Did you say bashing ?

I don’t know for sure if the word _bashing_ still only has it’s colorful first signification in english (like bashing someone’s head in), but in french, we heavily borrowed your word to describe the _act of systematic denigration of a person or a subject_.

A quick search of « bashing » terms in my favorite search engine gave me: (French politician) [Mélenchon bashing][3], but also (French footballer) [Benzema bashing][4], and even [plactic bashing][5]. This has gone too far... :p

If you are an IT professional, you might already know that for a long time, free open source softwares were frowned upon in the professional world.

More than once, I heard :

  * « It’s free, it’ll never work... »
  * « Why do you contribute to this free project? You should get paid for this work rather than give it away freely ».
  * « It’s a free open source software developped by bearded men in a garage » (being **bearded** clearly is an issue here. Which is funny if you consider that hipsters fashistas now **all** wear beards. And that Microsoft started in a garage...)

If that’s not open source bashing, I don’t know what is...

## He’s the one who started it!

Maybe he’s not the one, but the ultimate quote of **open source bashing** is probably given for eternity to Steve Ballmer from Microsoft for his world famous [« Linux is a cancer »][6] in 2001.

Oh boy how much I laugh why I look in the mirror.

> first they ignore you  
> then they laugh at you  
> then they fight you  
> then you win  
> -[So many people think it’s Gandhi who said that, but that’s probably not true ;)][7]

Tough luck for Ballmer, that was a big mistake. Most companies, starting from the biggest but now more and more average to small businesses rely heavily on open source solutions and solutions that work only on Linux/Unix systems.

While it was not so much of a problem when we lived in the physical servers world, on premise, it was still OK.

## Turn. Turn! Turn aroouuuuuuuuund!

Virtualization was the first nail in the coffin.

First version of Hyper-V, Microsoft attempt (ahah) at a professional virtualization platform was excruciatingly slow/broken/not suited for Linux/Unix runtimes. This benefited mostly to VMware (and in some proportion to Citrix and KVM), which was already the leader back then and also resulted in a considerable loss of market share for Microsoft in this area.

If I remember correctly, that’s around the time when Microsoft began to make less vindicative statement about Linux. It even resulted in a partnership with SUSE Linux first, then other distribs, and I remember because it surprised me a lot at that time.

Nowadays, Microsoft can’t shake off the idea that’s it’s some kind of **open source arch enemy**, no matter how much is spent on contributions on open sources projects. Microsoft communicates heavily on the fact that they are (as a company) one of the biggest (if not the biggest) contributor in open source, far before Google or Redhat (I don’t know if IBM acquisition changes anything to this). They even have a website claiming their love for open source [open.microsoft.com][8]!

> We are all in on open source  
> --Satya Nadella (actual CEO of Microsoft)

Nothing seems to matter. When they bought Github.com for nearly 8 billion dollars, the Internet nearly took the pitchforks out. « Why Github acquisition by Microsoft chocks the Internet » were titling newspapers. In the process, a lot of open source teams left Github in a hurry, never realizing that they had been on a closed platform all along and that Microsoft decision changed virtually nothing. There is a great article about this called [Le danger Github][9] but sadly (for you) it’s only in french...

## And the others?

Many followed the trend. It’s commonly admitted (even though some might call it a little bit unethical) to play on both sides of the source (open/closed).

One example among many others is VMware, which acquired a few years ago Pivotal, contributes to open source projects, and open sourced some of it’s own. While at the same time maintaining a large part of it’s portfolio closed source and making a lot of money with it.

Still, with all these possibilities, some big companies, selling uber-complex softwares still continue to choose open source bashing to promote their product. Among the years, I came across these examples:

  * A big company selling an ERP/ETL, claiming that should you use the open source alternative, you will fail. The image chosen for the illustration was a Donkey showing teeth, looking really dump and silly (sadly, I didn’t think to take a screenshot at that time)...
  * A company selling a platform to secure file transfers (one of the most costly software I ever came across), explaining us that you will in fact loose money if you choose an open source solution rather than their own. They made the comparaison between their software and ... plain FTP. Well, for a paid solution, I do hope that their solution is better! But choosing to ignore the open source solutions that DO compete with their product is not really fair (to say the least).
  * An then, there is SAP

## Should we take a look again at the tweet?

Today’s comic is caracteristic of those caricatures of a comparison we get from those companies.

![](/2021/tweet_sapfrance.png)

So here’s what is said in the first bubble:

> So? How is progressing your data platform based on open source software

From the look of our hero, I guess it not going well...

### « We need to install the new release AGAIN! » / « 2.65 beta! »

The main idea to convey here is that open source software are unreliable. The versions change quickly to compensate blocking bugs. They are even so buggy that you need to deploy betas in order to hope to make it run.

Now that’s really bad-faith. There are many open source project ran by teams adamant on stability, delivery process and proper quality checks and tools.

On the contrary, many software project do deploy badly tested code, open source or not, with sometimes catastrophic impacts. One example very close to us is [the last October update of Windows 10][10], which has skipped one of the usual validation steps to be released in production early (maybe just to be on time) which deleted some users directories!

### « Wait! It’s not compatible with my module! » / « Why is the text highlighted in yellow in the new version? » »

One part in this is true. Building a complex solution from multiple components is indeed a challenge (open source or not... but let’s not stray) and does indeed brings a certain number of problems. You can’t improvise this and have to build procedures to avoid major issues.

But let’s consider for a second the alternative we are proposed here. Let’s take a total random example, say, a big bad closed source costly ERP. How does it’s lifecycle plays out?

I’ve seen it countless times, there are 2 types of companies :

  * Heavily staffed and organized. They take this big software and they do it right. Meaning: they put up a whole team whose **sole purpose** is to maintain the whole platform up-to-date. They don’t do anything else, it’s really costly.
  * Small or(/and) not organized. The maintaning up-to-date is « just a thing », in the mind of the board. Why put so much resources, when actual admins can do it when they have time? And that’s were the fun begins. In those companies, at the first bug, the support of the big software will tell the admin to update, before even taking a look at the case. You end up with an ERP that is kept in a working state but never updated, in case something could break. Hackers/security auditors will be so happy ;).

### « And the fork, what do we do with it? »

That’s an excellement question, and I’m really glad you asked.

The idea here is that, at some point, the team in charge had to fork an open source project, maybe to patch with an homemade fix or to add a missing functionality. Eventually, the real open source project moved on and now, our team doesn’t know what to do. Forget their work and switch back to the main project, or continue to maintain their own copy while the main project grows?

Let’s be honest here. If you rely on open source softwares and don’t contribute your improvments (be they fixes or functionalities), don’t expect your work to be future proof!

### « Buy a new server / Buy another server / Try with a server from another brand »

I’d really like to have an opinion on this, because it’s seems important, as this is told 3 times. But unfortunatly I have no freaking idea of what critic of the open source the author meant.

![](/2018/10/sense-this-picture-makes-non.png)

## Funnies of all, SAP does contribute to Open Source!

I have had trouble to understand this at all at first. Because I checked, SAP is one of those companies that DO contribute! In the past years, SAP open sourced 4 internal big projects (and a few hundred of little more), [all available freely on Github][12]!

There is also [an OFFICIAL LIST of SAP open source contributions][13]. SAP has no reason to contribute actively on those external projects if they are not using these at least partly. According to [**Matt Asay,** they even rank as the seventh biggest open source contributor on Github][14]! Just behind Amazon and way before Facebook or Mozilla!

I’m 98% sure (as you can see that’s a really precise metric :p) that all SAP softwares at least use a third party open source component. More than an intuition, it’s more the fact that **everyone** uses open source at some level, be it frameworks, libs, or third party modules to ease integrations with third party softwares.

Last, but not least, there is a documentation page on SAP website, [listing FOSS and licences that go with them][15]. That doesn’t say that all SAP software use open source, but at least one does.

## In conclusion

Some might say that I’m over-reacting, that it’s just a bad tweet from France marketing team rather than a real will to undermine open source philosophy.

Yet, I can’t shake the idea that all the people in marketing from these companies MUST know that _open source_ was for a long time a rude word. This probably still echos on the mind of people less close to today’s work, who have « always done it like this » and « don’t see a reason to change now ». Claiming that open source is unreliable **will be probably most effective to top management**.

And don’t be fooled, this tweet’s target is not developers or system administrators. This tweets aims top management, who have to decide weither they go for open source or SAP solutions.

**No, I don’t think that’s a mistake; on the contrary, I think it’s done on purpose and probably very effective.**

![](/2018/10/2l8z3e.jpg)

## Sources

  * The initial tweet (deleted)
  * [SAP HANA, la plateforme de données qui rend libre !][18] (litterally, « SAP HANA, the data platform that frees/opens ». I find the irony hilarious and I thank the post author for the pun intended)
  * [Who really contributes to open source on Infoworld][14]
  * [official list of SAP open source contributions][13]
  * [FOSS and licences][15] for third party open source projects that come SAP
  * An article about [famous « Linux is a cancer » from Steve Ballmer][6]
  * [Le danger Github][9] from Carl Chenet [FR]
  * [October update removing user folders (arstecnica)][10]

 [3]: https://melenchon.fr/2018/05/22/alerte-aux-consequences-du-bashing-mediatique/
 [4]: https://www.goal.com/fr/news/halte-au-benzema-bashing-ses-chiffres-ne-sont-pas-si-mauvais-que-/1stnj28oyxovb1wa0959azdo8i
 [5]: https://www.leprogres.fr/haute-loire-43/2018/10/14/stop-au-plastique-bashing
 [6]: https://www.theregister.co.uk/2001/06/02/ballmer_linux_is_a_cancer/
 [7]: http://professorbuzzkill.com/qnq-gandhi-first-they/
 [8]: https://open.microsoft.com/
 [9]: https://carlchenet.com/le-danger-github-revu-et-augmente/
 [10]: https://arstechnica.com/gadgets/2018/10/microsoft-fixes-october-update-file-deleting-bug-resumes-insider-testing/
 [12]: https://github.com/sap
 [13]: https://archive.sap.com/documents/docs/DOC-29056
 [14]: https://www.infoworld.com/article/3253948/open-source-tools/who-really-contributes-to-open-source.html
 [15]: https://help.sap.com/saphelp_nw73ehp1/helpdata/de/0a/cad9cd019b4dc4a33baf824a751fce/frameset.htm
 [16]: /2018/10/2l8z3e.jpg
 [18]: https://news.sap.com/france/2018/10/sap-hana-plateforme-de-donnees/?source=social-EMEA_North-SAPFrance-TWITTER-MarketingCampaign-DDM-SAPHANA&campaigncode=CRM-FR18-DDM-DIGBLSE
