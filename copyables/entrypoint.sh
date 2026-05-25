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
IFS='x' read SCREEN_WIDTH SCREEN_HEIGHT <<<"${VNC_SCREEN_SIZE}"
export VNC_SCREEN="${SCREEN_WIDTH}x${SCREEN_HEIGHT}x24"
export CHROME_WINDOW_SIZE="${SCREEN_WIDTH},${SCREEN_HEIGHT}"

# 使用--remote-debugging-port必须制定默认路径外的路径： https://developer.chrome.com/blog/remote-debugging-port?hl=zh-cn
CHROME_OPTS_DEFAULT="--user-data-dir=/tmp/chrome_user_data_dir --no-first-run --test-type --system-developer-mode --no-sandbox --remote-debugging-port=9922 --remote-debugging-address=0.0.0.0 --remote-allow-origins=* --load-extension=/proxy_extension,/reload_extensions,/singlefile_extension"

# 兼容旧变量 CHROME_OPTS_OVERRIDE，同时支持：
# 1) CHROME_OPTS       完全覆盖参数
# 2) CHROME_OPTS_EXTRA 在默认参数基础上追加
if [[ -n "${CHROME_OPTS_OVERRIDE:-}" ]]; then
  CHROME_OPTS="${CHROME_OPTS_OVERRIDE}"
elif [[ -n "${CHROME_OPTS:-}" ]]; then
  CHROME_OPTS="${CHROME_OPTS}"
else
  CHROME_OPTS="${CHROME_OPTS_DEFAULT}"
fi

if [[ -n "${CHROME_OPTS_EXTRA:-}" ]]; then
  CHROME_OPTS="${CHROME_OPTS} ${CHROME_OPTS_EXTRA}"
fi

export CHROME_OPTS

exec "$@"
