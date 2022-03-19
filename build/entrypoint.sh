#!/bin/sh

default_dir="/opt/magic_mirror/modules/default"
config_dir="/opt/magic_mirror/config"
css_dir="/opt/magic_mirror/css"

[ ! -d "${default_dir}" ] && MM_OVERRIDE_DEFAULT_MODULES=true

if [ "${MM_OVERRIDE_DEFAULT_MODULES}" = "true" ]; then
  echo "copy default modules to host ..."
  sudo rm -rf ${default_dir}
  sudo mkdir -p ${default_dir}
  sudo cp -r /opt/magic_mirror/mount_ori/modules/default/. ${default_dir}/
fi

sudo mkdir -p ${config_dir}

sudo mkdir -p ${css_dir}

[ ! -f "${css_dir}/main.css" ] && MM_OVERRIDE_CSS=true

if [ "${MM_OVERRIDE_CSS}" = "true" ]; then
  echo "copy css files to host ..."
  sudo cp /opt/magic_mirror/mount_ori/css/* ${css_dir}/
fi

# create css/custom.css file https://github.com/MichMich/MagicMirror/issues/1977
[ ! -f "${css_dir}/custom.css" ] && sudo touch ${css_dir}/custom.css

echo "chown modules and config folder ..."
sudo chown -R node:node /opt/magic_mirror/modules &
sudo chown -R node:node ${config_dir}
sudo chown -R node:node ${css_dir}

if [ -f "${config_dir}/config.js.template" ]; then
  if [ -f "${config_dir}/config.js" ]; then
    mv -v ${config_dir}/config.js ${config_dir}/config.js-old
  fi
  envsubst < ${config_dir}/config.js.template > ${config_dir}/config.js
fi

if [ ! -f "${config_dir}/config.js" ]; then
  echo "copy default config.js to host ..."
  cp /opt/magic_mirror/mount_ori/config/config.js.sample ${config_dir}/config.js
fi

if [ "$MM_SHOW_CURSOR" = "true" ]; then
  echo "enable mouse cursor ..."
  sed -i "s|  cursor: .*;|  cursor: auto;|" /opt/magic_mirror/css/main.css
fi

[ -z "$TZ" ] && export TZ="$(wget -qO - http://geoip.ubuntu.com/lookup | sed -n -e 's/.*<TimeZone>\(.*\)<\/TimeZone>.*/\1/p')"

if [ -z "$TZ" ]; then
  echo "***WARNING*** could not set timezone, please set TZ variable in docker-compose.yml, see https://gitlab.com/khassel/magicmirror#timezone"
else
  echo "timezone is $TZ"
  sudo ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
  sudo sh -c "echo $TZ > /etc/timezone"
fi

[ -z "$MM_RESTORE_SCRIPT_CONFIG" ] || (/opt/magic_mirror/create_restore_script.sh "$MM_RESTORE_SCRIPT_CONFIG" || true)

if [ "$StartEnv" = "test" ]; then
  set -e

  export NODE_ENV=test

  echo "start tests ..."

  Xvfb :99 -screen 0 1024x768x16 &
  export DISPLAY=:99

  cd /opt/magic_mirror

  echo "/mount_ori/**/*" >> .prettierignore
  npm run test:prettier
  npm run test:js
  npm run test:css
  npm run test:unit
  npm run test:e2e
  npm run test:electron
else
  echo "start magicmirror"

  if [ -f "start_script.sh" ]; then
    sudo chmod +x "start_script.sh"
    . "./start_script.sh"
  fi

  exec env TZ=$TZ "$@"
fi
