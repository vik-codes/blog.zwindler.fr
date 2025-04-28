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

# Putting an end to Makefile in ![height:70](binaries/golang-logo.png)
# projects with GoReleaser ![height:100](binaries/goreleaser-logo.png)

---

## ~$ whoami

Denis Germain

-  Site Reliability Engineer ![height:40](binaries/deezer-logo.png)
- French tech blogger : [blog.zwindler.fr](https://blog.zwindler.fr)*
<br/>

![width:35](binaries/twitter.png) ![width:35](binaries/Mastodon.png) [@zwindler(@framapiaf.org)](https://framapiaf.org/@zwindler)

**#geek** 👨‍💻 **#SF** 🤖👽 **#runner** 🏃‍♂️

![bg fit right:37%](binaries/denis.png)

<br/>

**the slides are on the blog*

---

<!-- _class: lead -->

# Putting an end to Makefile in ![height:70](binaries/golang-logo.png)
# projects with GoReleaser ![height:100](binaries/goreleaser-logo.png)

---

## Why this talk???

- Golang = 💙, but compiling is 🥱
- Maintaining OSS projects === tedious actions 😴
  * ⚔️ cross-compiling
  * 🐋 building Docker images
  * 📦 making a bunch of packages
  * ✍🏼 signing/checksuming artefacts
  * 🚀 releases to git(hub|lab|ea)

---

## Solution 1 - do it yourself

- Makefile
- Jenkinsfile
- Github action / Gitlab runners
- Bash scripts "roulés sous les aisselles" 
- ...

![bg fit right:35%](binaries/doubitchou.png)

---

## Solution 2 - GoReleaser


You can do all that, and more with [GoReleaser](https://goreleaser.com) !

![center width:400](binaries/goreleaser-logo.png)

---

## It's time to D-D-D-D-D-DEMO !

![center width:550](binaries/demo.png)

- [gitlab.com/dt.germain/fosdem-goreleaser](https://gitlab.com/dt.germain/fosdem-goreleaser)

---

## Conclusion & feedbacks

- ⚔️ cross-compilation
- 🐋 Docker image builds
- ✍🏼 signature + checksums
- 🚀 gitlab releases
- ![width:36](binaries/Mastodon.png) posts on social medias / communication channels

<br/>

![width:35](binaries/twitter.png) ![width:32](binaries/Mastodon.png) ![width:32](binaries/logo-bsky.jpg) [@zwindler(@framapiaf.org)](https://framapiaf.org/@zwindler)

![bg fit right:35%](binaries/fosdem_qr.png)

---

<!-- _class: lead -->

# Sources

- [GoReleaser official website](https://github.com/goreleaser/goreleaser)
- [GoReleaser official documentation](https://goreleaser.com/install)
- Sources
  - [gitlab.com/dt.germain/fosdem-goreleaser](https://gitlab.com/dt.germain/fosdem-goreleaser)
- [Variables for GoReleaser](https://goreleaser.com/customization/templates/)
- [Article in GNU/Linux Magazine France](https://connect.ed-diamond.com/gnu-linux-magazine/glmf-265/en-finir-avec-les-makefiles-en-go-avec-goreleaser)
