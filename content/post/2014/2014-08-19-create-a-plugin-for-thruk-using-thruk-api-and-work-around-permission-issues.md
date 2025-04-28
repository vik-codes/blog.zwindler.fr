---
title: Create a plugin for Thruk using Thruk API, and work around permission issues
authors:
  - zwindler
type: post
date: 2014-08-19T09:13:19+00:00
url: /2014/08/19/create-a-plugin-for-thruk-using-thruk-api-and-work-around-permission-issues/
image: /2014/08/perl.gif
categories:
  - Monitoring
  - Script
tags:
  - deamon
  - Perl
  - permissions
  - poller
  - Shinken
  - thruk
  - thruk API
  - thruk_local.conf

---
[French readers]Une fois n’est pas coutume, je vais rédiger cet article en anglais[/French readers]

A friend of mine came to me with a problem. During one of his Shinken/Thruk deployment, he came with the idea of writing a plugin that could take advantage of Thruk statistics to graph the load of the monitoring engine.

Though you can get this information from Nagios itself through nagiostats, it’s a bit more difficult with the couple Thruk/Shinken. You could emulate Nagios by adding the Shinken _old-cgi_ legacy module, or you could an _authenticated wget_ the web page of Thruk and parse it, but let’s face it, these « solutions » aren’t pretty. I guess that the prettiest one should be to plug into Shinken, and maybe I’ll cover this later, because I think it’s the best solution, but this may need a little « dev effort ».

In order to avoid some useless effort, my friend asked Thruk developers how to do it the way Thruk does it. The main dev guided him to the « thruk » command line, which basically just generates the web page, but in a cleaner way as this is done internaly. You can get more information about Thruk command line with a simple « _thruk --help_ » in your shell.

With this information, my friend developped a perl script (because he is a perl addict ;-) ) to parse this page and get the statistics he needed. But when he deployed it \*shock\*: he couldn’t see a thing INSIDE the Thruk console.

The main problem here isn’t the fact that the script doesn’t seem to work, but rather the lack of error output.

When first idea was to add the shinken user in _apache_ group. This did help to make it work for the shinken user in shell, but for the web page of shinken/thruk it didn’t help.

To reproduce, I wrote a really simple script

```
#/bin/perl
#Print your page with thruk CLI, and display error output with 2>&1
print `/usr/bin/thruk -A thrukadmin extinfo.cgi?type=4 2>&1 `;
```


Though now the output was correct (lots of generated HTML jibber jabber) in the shell, the error is still displayed in Thruk

```
open file /etc/thruk/thruk_local.conf failed (id: uid=500(shinken) gid=500(shinken)
groups=500(shinken),0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023,
pwd: /var/run/shinken): at /usr/share/thruk/lib/Thruk/Utils/CLI.pm line 272.
```


AH-AH ! So, basically what I did was to add this at the first line of my script, to help me understand those groups/permissions issues.

```
#/bin/perl
print `id shinken`;
#Print your page with thruk CLI, and display error output with 2>&1
print `/usr/bin/thruk -A thrukadmin extinfo.cgi?type=4 2>&1 `;
```


Here is the output

```
uid=500(shinken) gid=500(shinken) groups=500(shinken),48(apache)
open file /etc/thruk/thruk_local.conf failed (id: uid=500(shinken) gid=500(shinken)
groups=500(shinken),0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023,
pwd: /var/run/shinken): at /usr/share/thruk/lib/Thruk/Utils/CLI.pm line 272.
```


This is what helped me understand what was really happening here. The groups were _shinken_ and _root_, but there where no mention of _apache_, even though I had just added apache to shinken and restarted the whole lot.

In fact, the groups are set at another level : during the deamonization. By reading the files, I managed to find 3 places where shinken can set it’s own group :

  * _/etc/default/shinken_, but only used for run and var directories creation (first launch)
  * _/etc/shinken/shinken.cfg_, only the arbiter
  * _/etc/daemons/*.ini_, for the daemons

You need to have read access for these 3 files (for my setup anyway)

```
ll /etc/thruk/thruk*
-rw-r--r--. 1 apache apache 25933 17 mai   19:13 /etc/thruk/thruk.conf
-rw-rw----. 1 apache apache   671 18 août  15:36 /etc/thruk/thruk_local.conf
ll /var/lib/thruk/secret.key
-rw-r-----. 1 apache apache 32 13 août  13:13 /var/lib/thruk/secret.key
```


Opening theses file to « _other_ » is obviously not an option, and I not a fan of changing the group of these conf files, even though this can/will work.

So, as of today, my favorite working solution (I’m still searching for a better one, and maybe I’ll switch to Shinken integration instead of Thruk) is to change _shinken poller_ group in _poller.ini_ to _apache_ and restart the daemon. This way, the poller and the associated plugins can access those 3 files and your Thruk API will work in Thruk console as it does in the shell.
