---
layout: single
title: Pi Related Modules
permalink: /pi-modules/
---

Many modules are working out of the box with this docker setup. But if you want to use modules which needs hardware of the raspberry pi the setup can be tricky. This step-by-step example is a showcase how to solve such problems when you want to use a PIR motion sensor.

# MagicMirror with PIR motion sensor

## Install module MMM-Pir-Sensor

Start image `karsten13/magicmirror:latest` on a raspberry pi and login into the running container with `docker exec -it mm bash`. Navigate to the `modules` folder and clone [MMM-PIR-Sensor](https://github.com/paviro/MMM-PIR-Sensor) with `git clone https://github.com/paviro/MMM-PIR-Sensor.git`. Now `cd` into the new folgder `MMM-PIR-Sensor` and run `npm install`.

This will throw errors because some packages are needed but not installed: python3, g++ and make.

So we have to build a new Docker image:

```Dockerfile
FROM karsten13/magicmirror:latest

USER root

RUN set -e; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get -qy --no-install-recommends install python3 g++ make; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*;

USER node
```

First we have to switch to user `root` so we can install packages. In the `RUN` section the missing packages are installed and we clean up for a small image size. After this, we switch back to the default user `node`.

We need to build this image and update the `docker-compose.yml` with the new image name.

## Configure MMM-PIR-Sensor

Every module needs to be configured in the `config.js` file. You can choose the [example](https://github.com/paviro/MMM-PIR-Sensor#example) from the module website:

```javascript
	{
		module: 'MMM-PIR-Sensor', 
		position: "top_center", // Remove this line to avoid having an visible indicator
		config: {
			sensorPin: 23,
			powerSavingDelay: 60, // Turn HDMI OFF after 60 seconds of no motion, until motion is detected again
			preventHDMITimeout: 4, // Turn HDMI ON and OFF again every 4 minutes when power saving, to avoid LCD/TV timeout
			supportCEC: true, 
			presenceIndicator: "fa-eye", // Customizing the indicator
			presenceOffIndicator: "fa-eye", // Customizing the indicator
			presenceIndicatorColor: "#f51d16", // Customizing the indicator
			presenceOffIndicatorColor: "#2b271c" // Customizing the indicator
		}
	}
```

After updating the `config.js` you have to restart the container.

But the PIR-Sensor does'nt work, you find the following error message in the logs: `permission denied, open '/sys/class/gpio/export'`.

To get this working you have to
- add an additional volume mount into your `docker-compose.yml` in the `volumes:` section: `- /sys:/sys`
- give the user `node` access to `/sys/class/gpio`.

For this we have to update our Dockerfile:

```Dockerfile
FROM karsten13/magicmirror:latest

USER root

RUN set -e; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get -qy --no-install-recommends install python3 g++ make; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    groupadd --gid 997 gpio; \
    usermod -a -G gpio node;

USER node
```

After rebuilding the docker image, updating the `docker-compose.yml` and restarting the container our PIR-Sensor should work. The icon on the mirror becomes red if motion is detected.

In the `config.js` we defined `powerSavingDelay: 60` which means turn HDMI off after 60 seconds. So we cover the PIR-Sensor and wait 60 seconds expecting a blank screen, but nothing happens - and nothing in the logs.

So after looking into the source code of the module I found that `/usr/bin/vcgencmd display_power 0` is executed for turning off the screen. But `vcgencmd` is not installed in the docker image. The last fix is to add another volume mount into your `docker-compose.yml` in the `volumes:` section: `- /usr/bin/vcgencmd:/usr/bin/vcgencmd`.

## Conclusion

Running hardware related modules within a docker image is possible, but needs further investigation to get it running.

The full example is contained in this repo:
- [Dockerfile](https://gitlab.com/khassel/magicmirror/-/blob/master/build/Dockerfile-gpio)
- [docker-compose.yml](https://gitlab.com/khassel/magicmirror/-/blob/master/run/rpi_gpio.yml)
- docker image: `registry.gitlab.com/khassel/magicmirror:master_gpio`

To use it clone this repository, navigate to `run`, rename `rpi_gpio.yml` into `docker-compose.yml` and run `docker-compose up -d`.