#!/bin/bash
set -e

# VNC default no password
export X11VNC_AUTH="-nopw"

# look for VNC password file in order (first match is used)
passwd_files=(
  /home/chrome/.vnc/passwd
  /run/secrets/vncpasswd
)

# shellcheck disable=SC2068
for passwd_file in ${passwd_files[@]}; do
  if [[ -f ${passwd_file} ]]; then
    export X11VNC_AUTH="-rfbauth ${passwd_file}"
    break
  fi
done

# override above if VNC_PASSWORD env var is set (insecure!)
if [[ "$VNC_PASSWORD" != "" ]]; then
  export X11VNC_AUTH="-passwd $VNC_PASSWORD"
fi

/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 8900 &

# make sure .config dir exists
mkdir -p /home/chrome/.config
chown chrome:chrome /home/chrome/.config

# set sizes for both VNC screen & Chrome window
: ${VNC_SCREEN_SIZE:='1920x1080'}
IFS='x' read SCREEN_WIDTH SCREEN_HEIGHT <<< "${VNC_SCREEN_SIZE}"
export VNC_SCREEN="${SCREEN_WIDTH}x${SCREEN_HEIGHT}x24"
export CHROME_WINDOW_SIZE="${SCREEN_WIDTH},${SCREEN_HEIGHT}"

#export CHROME_OPTS="${CHROME_OPTS_OVERRIDE:- --user-data-dir --no-sandbox --window-position=0,0 --force-device-scale-factor=1 --disable-dev-shm-usage}"
# 使用--remote-debugging-port必须制定默认路径外的路径： https://developer.chrome.com/blog/remote-debugging-port?hl=zh-cn
if [[ -d /home/Chrome/TaxServices/docs/chrome_proxy_extension && -w /proxy_extension ]]; then
  proxy_config_backup=$(mktemp)
  if [[ -f /proxy_extension/proxy_config.js ]]; then
    cp /proxy_extension/proxy_config.js "$proxy_config_backup"
  fi
  cp -r /home/Chrome/TaxServices/docs/chrome_proxy_extension/. /proxy_extension/
  if [[ -s "$proxy_config_backup" ]]; then
    cp "$proxy_config_backup" /proxy_extension/proxy_config.js
  fi
  rm -f "$proxy_config_backup"
fi
extension_list="/proxy_extension,/singlefile_extension"
export CHROME_OPTS="${CHROME_OPTS_OVERRIDE:- --user-data-dir=/tmp/chrome_user_data_dir --system-developer-mode --no-sandbox --mute-audio --no-first-run --test-type --ignore-certificate-errors --allow-insecure-localhost --disable-popup-blocking --disable-background-networking --disable-sync --ash-no-nudges --disable-dev-shm-usage --disable-infobars --disable-gpu --disable-popup-blocking  --no-default-browser-check --disable-application-cache --disk-cache-size=0 --remote-allow-origins=*  --remote-debugging-port=9922 --remote-debugging-address=0.0.0.0 --disable-features=PrivacySandboxSettings4,Translate  --load-extension=$extension_list}"

exec "$@"
