---
layout: single
title: Installation
permalink: /installation/
---

## Installation prerequisites

* [Docker](https://docs.docker.com/engine/installation/)
* I recommend [docker-compose](https://docs.docker.com/compose/install/). The images can also started with `docker run ...` commands instead,
  but this would result in very long statements. `docker-compose` uses yml-Files which are included in this setup. You find an example using
  docker in the [FAQ]({{ site.baseurl }}/faq/#how-to-start-magicmirror-without-docker-compose).

## Additional prerequisites for running on a raspberry pi with Scenario **electron** ✌️

> 👉 if you use [MagicMirrorOS](https://github.com/guysoft/MagicMirrorOS) the steps in this section are already done.

### Setup for graphical desktop
- install unclutter: `sudo apt-get install -y unclutter`
- edit (here with nano) `sudo nano /etc/xdg/lxsession/LXDE-pi/autostart` and insert the following lines for disabling screensaver and mouse cursor:

  ```bash
  @xset s noblank
  @xset s off
  @xset -dpms
  @unclutter -idle 0.1 -pi
  @xhost +local:
  ```

  > Hint: With older debian versions you must edit `nano /home/pi/.config/lxsession/LXDE-pi/autostart`.

- uncomment the existing lines, otherwise you will see the pi desktop before MagicMirror has started
- edit (here with nano) `nano ~/.bashrc` and insert the following line (otherwise docker has no access on the pi display):
  ```bash
  xhost +local:
  ```
- execute `sudo raspi-config` and navigate to "3 boot options" and choose "B2 Wait for Network at Boot". If not set, some modules will remaining in "load"-state because MagicMirror starts to early.

> Before next installation steps please reboot your pi 

## Installation of this Repository

Open a shell in your home directory and run
```bash
git clone https://gitlab.com/khassel/magicmirror.git
```

Now cd into the new directory `magicmirror/run` and copy the yml-file depending on the scenario, for scenario **server** ☝️:
```bash
cd ./magicmirror/run
cp serveronly.yml docker-compose.yml
```

For scenario **electron** ✌️:
```bash
cd ./magicmirror/run
cp rpi.yml docker-compose.yml
```

## Start MagicMirror²

Navigate to `~/magicmirror/run` and execute

```bash
docker-compose up -d
```

The container will start and with scenario **electron** ✌️ the MagicMirror should appear on the screen of your pi. In server only mode opening a browser at `http://localhost:8080` should show the MagicMirror (scenario **server** ☝️).

> The container is configured to restart automatically so after executing `docker-compose up -d` it will also restart after a reboot of your pi.


You can see the logs with

```bash
docker logs mm
```

Executing
```bash
docker ps -a
```
will show all containers and 

```bash
docker-compose down
```

will stop and remove the MagicMirror container.

You can restart the container with one command `docker-compose up -d --force-recreate`. This is e.g. necessary if you change the configuration.

## Updating the image

The MagicMirror²-Project has quarterly releases so every 1st of Jan/Apr/Jul/Oct a new version is released.

This project ist updated weekly because the image contains debian as operating system. To get (security) updates in time the image build is executed every sunday.

To get the newest image you have to update this locally. Navigate to `~/magicmirror/run` and execute

```bash
docker-compose pull
```

After the new image is pulled you have to restart the container with

```bash
docker-compose up -d
```

> With every new image the old image remains on your hard disc and occupies disk space. To get rid of all old images you can execute `docker image prune -f`.