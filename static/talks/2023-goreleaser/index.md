---
marp: true
theme: gaia
markdown.marp.enableHtml: true
paginate: true
---

<style>

section {
  background-color: #fefefe;
  color: #333;
}

img[alt~="center"] {
  display: block;
  margin: 0 auto;
}
blockquote {
  background: #ffedcc;
  border-left: 10px solid #d1bf9d;
  margin: 1.5em 10px;
  padding: 0.5em 10px;
}
blockquote:before{
  content: unset;
}
blockquote:after{
  content: unset;
}
</style>

<!-- _class: lead -->

# En finir avec les Makefile en ![height:70](binaries/golang-logo.png)
# avec GoReleaser ![height:70](binaries/goreleaser-logo.png)

---

## ~$ whoami

**Denis Germain** 👨‍💻🧙🔥🏃‍♂️

- Site Reliability Engineer ![height:40](binaries/deezer-logo.png)
- Blog tech (et +) : [blog.zwindler.fr](https://blog.zwindler.fr)*

<br/>
<br/>

![width:35](binaries/twitter.png) ![width:32](binaries/Mastodon.png) ![width:32](binaries/logo-bsky.jpg) [@zwindler(@framapiaf.org)](https://framapiaf.org/@zwindler)

![bg fit right:39%](binaries/denis.png)

<br/>

**Les slides de ce talk sont sur le blog*

---

<!-- _class: lead -->

# En finir avec les Makefile en ![height:70](binaries/golang-logo.png)
# avec GoReleaser ![height:70](binaries/goreleaser-logo.png)

---

## Pourquoi ce talk ???

- Golang = 💙, mais compiler ses binaires 🥱
- Projet OSS = actions pénibles 😴
  * ⚔️ cross-compilation
  * 🐋 création d'images Docker
  * 📦 création de packages
  * ✍🏼 signature, checksums de ces artefacts
  * 🚀 releases sur git(hub|lab|ea)

---

## Solution 1 - faire soi même

- Makefile
- Jenkinsfile
- Github action / Gitlab runners
- Scripts bash "roulés sous les aisselles" 
- ...

![bg fit right:35%](binaries/doubitchou.png)

---

## Solution 2 - GoReleaser


Faire tout ça, et même plus, avec [GoReleaser](https://goreleaser.com) !

![center width:400](binaries/goreleaser-logo.png)

---

## It's time to D-D-D-D-D-DEMO !

![center width:600](binaries/demo.png)

---

## Conclusion & feedbacks

- ⚔️ cross-compilation
- 🐋 création d'images Docker
- ✍🏼 signature + checksums
- 🚀 releases sur gitlab
- ![width:36](binaries/Mastodon.png) annonce sur les réseaux sociaux

<br/>
<br/>

![width:35](binaries/twitter.png) ![width:32](binaries/Mastodon.png) ![width:32](binaries/logo-bsky.jpg) [@zwindler(@framapiaf.org)](https://framapiaf.org/@zwindler)

![bg fit right:35%](binaries/bdxio_qr.png)

---

<!-- _class: lead -->

# Sources

- [Site officiel de GoReleaser](https://github.com/goreleaser/goreleaser)
- [Documentation d’installation de GoReleaser](https://goreleaser.com/install)
- Sources pour ce talk
  - [gitlab.com/zwindler/bdxio-goreleaser](https://gitlab.com/dt.germain/bdxio-goreleaser)
- [Variables automatiques utilisables avec GoReleaser](https://goreleaser.com/customization/templates/)
- [Article sur GNU/Linux Magasine](https://connect.ed-diamond.com/gnu-linux-magazine/glmf-265/en-finir-avec-les-makefiles-en-go-avec-goreleaser)
