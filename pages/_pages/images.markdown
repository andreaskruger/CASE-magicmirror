---
layout: single
title: Docker Images
permalink: /images/
toc: false
---

## Images on Docker Hub:  [![](https://dockeri.co/image/karsten13/magicmirror)](https://hub.docker.com/r/karsten13/magicmirror/)

The docker image `karsten13/magicmirror` is provided in this versions:

TAG                | OS/ARCH     | ELECTRON | DISTRO | DESCRIPTION
------------------ | ----------- | -------- | -------|------------------------------------------
latest (or {{ site.data.gitlab.variables.MAGICMIRROR_VERSION }}) | linux/amd64 | no       | debian {{ site.data.gitlab.variables.DEBIAN_VERSION }} slim | only `serveronly`-mode
latest (or {{ site.data.gitlab.variables.MAGICMIRROR_VERSION }}) | linux/arm   | yes      | debian {{ site.data.gitlab.variables.DEBIAN_VERSION_ARM }} slim | for raspberry pi
latest (or {{ site.data.gitlab.variables.MAGICMIRROR_VERSION }}) | linux/arm64 | yes      | debian {{ site.data.gitlab.variables.DEBIAN_VERSION }} slim | for raspberry pi4 64-Bit-Version
fat (or {{ site.data.gitlab.variables.MAGICMIRROR_VERSION }}_fat)| linux/amd64 | no       | debian {{ site.data.gitlab.variables.DEBIAN_VERSION }} | only `serveronly`-mode
fat (or {{ site.data.gitlab.variables.MAGICMIRROR_VERSION }}_fat)| linux/arm   | yes      | debian {{ site.data.gitlab.variables.DEBIAN_VERSION_ARM }} | for raspberry pi
fat (or {{ site.data.gitlab.variables.MAGICMIRROR_VERSION }}_fat)| linux/arm64 | yes      | debian {{ site.data.gitlab.variables.DEBIAN_VERSION }} | for raspberry pi4 64-Bit-Version
alpine             | linux/amd64 | no       | alpine | only `serveronly`-mode, smaller in size

Version {{ site.data.gitlab.variables.MAGICMIRROR_VERSION }} is the current release of MagicMirror. Older version tags remain on docker hub, the other tags are floating tags and therefore overwritten with every new build. The used Node version is {{ site.data.gitlab.variables.NODE_VERSION_MASTER }}.

The difference between `latest` and `fat` is image size and installed debian packages. For most use cases the `latest` image is sufficient. Some modules need dependencies which are not includes in `latest`, e.g. `python` or compilers, so in such cases you should use `fat`.

⛔ The following experimental images are not for production use:

TAG                | OS/ARCH     | ELECTRON | DISTRO | DESCRIPTION
------------------ | ----------- | -------- | -------|------------------------------------------
develop        | linux/amd64 | no       | debian {{ site.data.gitlab.variables.DEBIAN_VERSION }} slim | only `serveronly`-mode
develop        | linux/arm   | yes      | debian {{ site.data.gitlab.variables.DEBIAN_VERSION_ARM }} slim | for raspberry pi
develop        | linux/arm64 | yes      | debian {{ site.data.gitlab.variables.DEBIAN_VERSION }} slim | for raspberry pi4 64-Bit-Version
develop_fat    | linux/amd64 | no       | debian {{ site.data.gitlab.variables.DEBIAN_VERSION }} | only `serveronly`-mode
develop_fat    | linux/arm   | yes      | debian {{ site.data.gitlab.variables.DEBIAN_VERSION_ARM }} | for raspberry pi
develop_fat    | linux/arm64 | yes      | debian {{ site.data.gitlab.variables.DEBIAN_VERSION }} | for raspberry pi4 64-Bit-Version
develop_alpine | linux/amd64 | no       | alpine | only `serveronly`-mode, smaller in size

These images are using the `develop` branch of the MagicMirror git repository and Node version {{ site.data.gitlab.variables.NODE_VERSION_DEVELOP }}.
