---
layout: single
title: Configuration
permalink: /configuration/
---


## Config, Modules, and custom CSS

After the first start of the container you find 3 directories
```bash
~/magicmirror/mounts/config
~/magicmirror/mounts/modules
~/magicmirror/mounts/css
```

`config` contains the `config.js`, you find more information [here](https://docs.magicmirror.builders/getting-started/configuration.html#general).

You can also use a `config.js.template` instead which can contain environment variables (this is not possible in `config.js`).
This make sense for keeping secrets (e.g. passwords, api keys) out of the config file. In `config.js.template` you can use shell variable syntax e.g. `${MY_SECRET}` as placeholder for your secrets. Don't forget to pass variables in `config.js.template` as environment variables to the container:
```yaml
    environment:
      MY_SECRET: "abc"
```

You can also use an `.env` file (in the same directory as your `docker-compose.yml`) to define your secrets there, for more info on this see [the docker-compose reference](https://docs.docker.com/compose/environment-variables/).

> 👉 When the container starts, the `config.js` will be created using the `config.js.template`. An existing `config.js` will be overwritten and saved as `config.js-old`

For installing modules refer to the module website, the default modules are described [here](https://docs.magicmirror.builders/modules/introduction.html).

> There is one difference installing or updating modules compared to a standard setup: You must do the `git clone ...`, `git pull` and `npm install` commands from inside the running docker container. For this you execute `docker exec -it mm bash` and in this shell you navigate to the `modules/MMM-...` folder. For exiting from the container you type `exit`.

`css` contains the `custom.css` file, which you can use to override your
modules' appearance. CSS basics are documented
[here](https://forum.magicmirror.builders/topic/6808/css-101-getting-started-with-css-and-understanding-how-css-works), among many other places.

> 👉 The css-files in the `css` folder which exists in the MagicMirror git repo (currently only `main.css`) are overriden with the original file from inside the container with every restart. So if you need to change this file, you must stop this default copying by setting the environment variable `MM_OVERRIDE_CSS` to `false` in the `docker-compose.yml` file:
```yaml
    environment:
      MM_OVERRIDE_CSS: "false"
```

## Default Modules

The default modules of MagicMirror are located in the folder `~/magicmirror/mounts/modules`. These modules are maintained in the MagicMirror project and not - as other modules - in own git repositories. So if they are mounted the first time outside the container this version remains on the host and would never updated again. To prevent this, the docker container overrides the `default` modules folder with the versions from inside the container.

If someone does not agree with this procedure he can avoid the copy process by adding the environment variable `MM_OVERRIDE_DEFAULT_MODULES` to `false` in his `docker-compose.yml` file:
```yaml
    environment:
      MM_OVERRIDE_DEFAULT_MODULES: "false"
```

## Timezone

The container tries to get the timezone by location. If this is not possible or wrong, you can set the timezone to a different value by editing the `docker-compose.yml` file. You have to add the timezone as environment variable:

```yaml
    environment:
      TZ: Europe/Berlin
```

## Mouse cursor

The mouse cursor is diabled by default. You can enable it by adding the environment variable `MM_SHOW_CURSOR` to `true` in your `docker-compose.yml` file:
```yaml
    environment:
      MM_SHOW_CURSOR: "true"
```
