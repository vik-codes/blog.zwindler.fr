---
title: Should we have containers ?
authors:
  - zwindler
type: post
date: 2016-08-25T16:00:21+00:00
url: /2016/08/25/when-should-we-have-containers/
image: /2016/08/Fullvirt_containers.png
categories:
  - Monitoring
  - systeme
  - Virtualisation
tags:
  - cloud ready
  - container
  - conteneur
  - Docker
  - LXC
  - monitoring
  - persistance
  - virtualisation

---
## A more complete answer to « Why do we have containers » by fntlnz

2 days ago, I stumbled apon _fntlnz_ article [Why do we have containers. (dead link, using Internet Archive)](https://web.archive.org/web/20161026190150/http://blog.fntlnz.wtf/post/why-containers/) The article had been reposted by Docker official Twitter account and the first thing that struck me was the displayed image : a schema comparing full virtualization, para virtualization and linux containers.

And of course, I say this because I didn’t entirely agree with it ;-). But then I read the article and I found many good points.

So I decided to write « Should we have containers ? » as an answer to develop my remarks a little.

## Full virtualization vs paravirtualization vs OS level virtualization

First, I’ll go with the schema. I know the point was to provide a really simple schema to help understand the differences between virtualization types but I don’t think it should be presented like that.

![](/2016/08/Virtualization.png)

Hypervisor and host OS are both displayed in the full/para. I find this be misleading. Of course there is a Host OS and a virtualization engine on top of it. But most of the time, either the OS is really thin (ESXi fits in 8GB SD cards and runs nothing but virtualization) or the virt engine is a part of the kernel (KVM, Xen) just like LXC is a part of the Linux kernel.

Also, the bins/libs are only displayed on OS level virt. This is interesting to put in the « host level virtualization schema » but it should be added on full and para as well because this is one of the advantages host level virt. has over full/para.  
Even if your VMs are all identicals, bins and libs have to be present (copied) in each VMs. On contrary, in OS Level virt, you CAN share identicals bins/libs between containers, thus reducing the storage footprint of the virtualized environment.

That’s how I would have presented it

![](/2016/08/Fullvirt_containers.png)

You can see that OS level virtualization and Hypervisors are not so different on this simplified view. The differences appear more clearly when you add x86 Security Rings (0->3). The « overhead » of full virtualization comes from the calls that guest OSes do to hypervisor pilots and the translation of CPU instructions.

On a side note, I put Docker on the left to show that it’s basically an administration suite that helps you run LXC containers

## The rest of the analysis

### Security

When talking about containers, the security point is often raised.

VMs are really hermetics. Taking control of the hypervisor after hacking a VM should be MUCH harder than taking control of the host OS if you are inside a container with whom the kernel is shared.

But I agree with **fntlnz**: having to patch only one kernel for all your virtual environments instead of having to patch ALL kernels of your virtual machines is actually a good point.

I encourage you to read [this (dead link, using Internet Archive)](https://web.archive.org/web/20200925215559/https://2015.rmll.info/IMG/pdf/containers_docker_and_security__state_of_the_union.pdf) from Jérôme Petazzoni if you’d like a good presentation on the subject.

### Performance

A point that’s not really developed in _fntlnz_ article is performance, but I read it/ear it **all the time**.

General belief is that VMs are slow. That was true in the « early days » of x86 virtualization, because of the limitations of the x86 architectures which didn’t allow efficient OS virtualisation. Overhead for CPU instructions was known to be of about 15% (which is enormous). Thus, running processes directly on the OS are believed to be more efficent.

But nowadays, modern hypervisors on modern hardware nearly generates no overhead at all over CPU and RAM consumption. You could argue that guest OSes consume ressources while containers don’t. But let’s be honest: with the 32 GB RAM tomcat instances I regularly see, don’t say to me that a Linux guest OS CPU&RAM consumption is significative.

The real difference is the on the storage consumption. First, for N VMs, you save yourself N*xGB of guest OS files. If your Linux templates are good, you don’t consume that much (a few GB at most) but this can add up when we are talking about thousands of instances. [Edit jan. 2020]Not so true today if you host your own hardware and have so deduplicated storage[/Edit]

From there, you still have some margin for gains, mostly through **Copy on write and union filesystems** :

  * You make a modification to an official tomcat image to add you configuration files ? Only the delta will be stored.
  * You launch thousands of containers from this image ? You only consume the container image once.
  * The real data (user data, business data) is of course the same for both architectures

## So, should I use containers ?

The problem here is that’s not the real question. **Do you need containers ?** Here’s _fntlnz_ point of view.**  
** 

> But if at some extent your motivation consist in **decreasing costs related to full virtualization overheads** while allowing **developers to ship, develop and test code faster** we already found two.  
> - fntlnz

I won’t tell you not to use containers or Docker. Truth be told, we use it in dev and production. Docker is awesome.

  * Yes, Docker reduces overhead of full virtualization. Storage mostly, but it highly depends on your workload. For example if you have the need for millions of really tiny instances, then Guest OS overhead is significative  in full virtualization.
  * Yes, Docker allows developers to ship, develop and test code faster. You still have to change your way to develop yours app but Docker and DevOps is the new thing. Better get on with it ;)

But you shouldn’t use Docker just because of that. Docker containers need you to change your philosophy toward applications and administration.

### Shared kernel = same kernel~~ ~~

You need to understand that you’ll share a kernel. For a long time that ment a 100% Linux only which could be problematic in some cases. I just realized that Windows containers exists in Windows 2016 tech preview. And Solaris is coming.

But independantly of platforms, you still you share a kernel. If you want Linux containers, you’ll need Linux Docker nodes. If you need Windows containers, you’ll have to have Windows Docker nodes.

### Non-persistant/cloud-ready instances

Docker containers are by design non-persistant and by best practice single-process. This isn’t mandatory of course, but Docker works better that way.

The whole idea is to help you make « cloud-ready » & atomic applications that don’t store anything in the container itself (persistant storage is presented to the container but outside it). This way, you can scale out really quickly: you just start up a few more instances if you need more firepower.

This also modifies the way you do systems/applications administration. A container/application is spinning out of control ? Don’t try to repair it.

  * Kill it
  * Launch a new one

The fact that persistant storage is handled outside the containers also helps you to deal with lifecycle management.

  * Update your application inside the docker image
  * Shutdown the old container
  * Start the new container with the new image, plugged to the persistant storage

All that requires of course applications that have been designed this way! This is a massive change in philosophy and old monolithic apps on a Docker platform won’t work as well as microservices will.

### System administration

I don’t say solutions don’t exist because they do.

But starting up and shutting down containers on the fly will give headaches to your « old school Nagios » monitoring administrator. What could be done easily in the physical/VM world (installing an agent in the template), each of those having an IP adress to query for health checks is a lot easier than checking on a single host a highly volatile number of isolated processes.

You’ll probably have to adapt and use tools that are designed to handle such cases.

Backup administrator may find it confusing at first to make application consistant data backups when applications are running in an variable number of containers.

And so on...

## Final thoughts

Yes, you should definitely _look into_ containers. They are mature, stable, a great new way to speed up development and contribute to save money on hardware.

But be aware that VMs and containers don’t answer all usecases; and that you won’t migrate all your applications overnight!
