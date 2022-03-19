---
layout: single
title: FAQ
permalink: /faq/
---

## MagicMirror is black without content

If you cannot access your MagicMirror (black screen), check the params `address` and `ipWhitelist` in your 
`config.js`, see [this forum post](https://forum.magicmirror.builders/topic/1326/ipwhitelist-howto).

You should try the following parameters if you have problems:

```javascript
var config = {
	address: "0.0.0.0",
	port: 8080,
	ipWhitelist: [],
  ...
```

## How to install OS dependencies needed by a module?

You have 3 choices:

### Build your own image

This is the preferred solution if you need a lot of dependencies and start time of MagicMirror matters. Here an example Dockerfile for [MMM-GoogleCast](https://github.com/ferferga/MMM-GoogleCast):

```bash
FROM karsten13/magicmirror:latest

USER root

RUN set -e; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get -qy --allow-unauthenticated install python3 python3-pip; \
    pip3 install pychromecast; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    python3 --version;

USER node
```

### Use a start script

This is the preferred solution if you need only a few dependencies and start time of MagicMirror doesn't matter.

For this you have to write a `start_script.sh` file and put this beside your `docker-compose.yml` file. Additionally the `start_script.sh` file must be mapped into the container so you need an extra line in the `volumes` section of your `docker-compose.yml` file:

```yaml
    volumes:
      - ./start_script.sh:/opt/magic_mirror/start_script.sh
```

Here an example for the content of `start_script.sh`. If you want to use [MMM-ServerStatus](https://github.com/XBCreepinJesus/MMM-ServerStatus) you need to install the missing `ping` command. This is done by this `start_script.sh`:

```bash
#!/bin/sh
sudo apt-get update
sudo apt-get install -y iputils-ping
```

### Use the `fat` image

Since release `v2.17.1` a new image `karsten13/magicmirror:fat` is provided. This image is based on `debian:buster` (not on `debian:buster-slim` as `latest`) and contains already many dependencies, e.g. python. You can try this image if you need packages missing in `latest`. Be aware that this image is really `fat` so pulling this image takes longer, especially on a raspberry pi.

## How to start MagicMirror without docker-compose?

If you don't want to use `docker-compose` yo can start and stop your container with `docker` commands. For starting the container you have to translate the `docker-compose.yml` file into a `docker run ...` command. Here an example:

`docker-compose.yml`:
```yaml
version: '3'

services:
  magicmirror:
    container_name: mm
    image: karsten13/magicmirror:latest
    ports:
      - "8080:8080"
    volumes:
      - ../mounts/config:/opt/magic_mirror/config
      - ../mounts/modules:/opt/magic_mirror/modules
      - ../mounts/css:/opt/magic_mirror/css
    restart: unless-stopped
    command: 
      - npm
      - run
      - server
```

Corresponding `docker run` command:

```yaml
docker run  -d \
    --publish 8080:8080 \
    --restart always \
    --volume ~/magicmirror/mounts/config:/opt/magic_mirror/config \
    --volume ~/magicmirror/mounts/modules:/opt/magic_mirror/modules \
    --volume ~/magicmirror/mounts/css:/opt/magic_mirror/css \
    --name mm \
    karsten13/magicmirror:latest npm run server
```

You can stop and remove the container with `docker rm -f mm`.

## How to patch a file of MagicMirror?

You may want to test something or fix a bug in MagicMirror and therefore you want to edit a file of the MagicMirror installation.
With a classic install this is no problem, just edit the file, save it and restart MagicMirror.

In a container setup this is not so simple. You can login into the container with `docker exec -it mm bash` and edit the file there.
This solution works as long as no restart of MagicMirror is required. After a restart your changes are gone ...

So how to handle this?

The short story: Copy the file from inside the container to a directory on the host. Add a volume mount to the `docker-compose.yml` which mounts the local file back into the container. Now you can edit the file on the host and the changes are provided to the container. No problem if you need to restart the container.

The long story with example: In MagicMirror v2.11.0 is a bug which stops the MMM-Remote-Control to work ([see](https://github.com/Jopyth/MMM-Remote-Control/issues/185#issuecomment-608600298)). So to solve this problem the file `js/socketclient.js` must be patched.

To get the file from the container to the host (the container must be running) goto `~/magicmirror/run` and execute `docker cp mm:/opt/magic_mirror/js/socketclient.js .`

Now the file `socketclient.js` is located under `~/magicmirror/run`, you can do a `ls -la` to control this.

You can now edit this file and do your changes.

For getting the changes back into the container you have to edit the `docker-compose.yml` and insert a new volume mount, in the following example this is the first line under `volumes:`:

```yaml
version: '3'

services:
  magicmirror:
    container_name: mm
    image: karsten13/magicmirror:latest
    ports:
      - "8080:8080"
    volumes:
      - ./socketclient.js:/opt/magic_mirror/js/socketclient.js
      - ../mounts/config:/opt/magic_mirror/config
      - ../mounts/modules:/opt/magic_mirror/modules
    ...
```

Thats it. If you need to restart the MagicMirror container just execute `docker-compose up -d`.

## My container doesn't start

If an error occurs which force MagicMirror to quit then this will restart the container again and again. You can try to catch the logs with `docker logs mm` but this is not really a solution.

For debugging you can change the `command` section in your `docker-compose.yml` from

```yaml
    command: 
      - npm
      - run
      - server
```

to 

```yaml
    command: 
      - sleep
      - infinity
```

and restart the container with `docker-compose up -d`. Then you can login into the container with `docker exec -it mm bash`. You are by default in the MagicMirror directory (`/opt/magic_mirror`). From here you can start the mirror with `npm run server` in server-only mode or with `npm run start` on your raspberry pi. Now you can examine the logs to catch the errors.

## Error: Cannot find module `request`

With MagicMirror Version v2.16.0 the dependency `request` was removed. `request` is deprecated and should not be used anymore (see [npm request](https://www.npmjs.com/package/request)). This should be no problem for modules using `request` but some modules didn't setup `request` in there own `package.json`, they did rely on that this dependency comes with MagicMirror.

So if your container doesn't start with MagicMirror v2.16.0 or later and you find something like `Error: Cannot find module 'request'` you should open an issue in the module project to get this fixed.

Example log of module MMM-quote-of-the-day:
````
[22.07.2021 12:16.03.454] [LOG]   Starting MagicMirror: v2.16.0
[22.07.2021 12:16.03.462] [LOG]   Loading config ...
[22.07.2021 12:16.03.474] [LOG]   Loading module helpers ...
[22.07.2021 12:16.03.497] [ERROR] WARNING! Could not load config file. Starting with default configuration. Error found: Error: Cannot find module 'request'
Require stack:
- /opt/magic_mirror/modules/MMM-quote-of-the-day/node_helper.js
- /opt/magic_mirror/js/app.js
- /opt/magic_mirror/serveronly/index.js
[22.07.2021 12:16.03.499] [LOG]   Loading module helpers ...
[22.07.2021 12:16.03.504] [ERROR] Whoops! There was an uncaught exception...
[22.07.2021 12:16.03.514] [ERROR] Error: Cannot find module 'request'
Require stack:
- /opt/magic_mirror/modules/MMM-quote-of-the-day/node_helper.js
- /opt/magic_mirror/js/app.js
- /opt/magic_mirror/serveronly/index.js
````

To get your MagicMirror running you can use the following workaround:
- if your container doesn't start see the section above
- login into the container with `docker exec -it mm bash` and navigate into the folder of the module, e.g. `cd modules/MMM-quote-of-the-day`
- check with `ls -la` if the folder contains a file `package.json`, if not run `npm init -y`
- run `npm install request`

After this manual install of `request` the module should work.

This fix is persistent because the `modules` folder is mounted to the host. If you do a fresh install of such a module you have to repeat this procedure.

## Running on a raspberry pi ends with a white or black screen after a while

I had this behavior running the module `MMM-RAIN-MAP` which is fetching a greater amount of images for the map. So if you are running modules which needs a greater amount of shared memory, you have to increase `shm_size` in the `docker-compose.yaml`. The default there is `shm_size: "128mb"` so edit this value and restart the container with `docker-compose up -d`.
