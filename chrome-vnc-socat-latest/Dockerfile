FROM ubuntu:22.04

ARG is_mirror=false

ENV VNC_SCREEN_SIZE=1920x1080
ENV LANG=C.UTF-8

COPY copyables /

RUN if [ "$is_mirror" = "true" ]; then \
        sed -i 's#http://.*ubuntu.com#http://mirrors.aliyun.com#g' /etc/apt/sources.list; \
    fi && \
    apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        gnupg2 \
        fonts-noto-cjk \
        pulseaudio \
        supervisor \
        x11vnc \
        fluxbox \
        eterm \
        libzbar0 \
        socat \
        vim \
        git \
        python3-pip \
        xdotool \
        ca-certificates

ADD https://dl.google.com/linux/linux_signing_key.pub \
    https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb \
    /tmp/

RUN apt-key add /tmp/linux_signing_key.pub \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        /tmp/google-chrome-stable_current_amd64.deb \
        /tmp/chrome-remote-desktop_current_amd64.deb

RUN if [ "$is_mirror" = "true" ]; then \
        pip3 install --no-cache-dir websockify -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple; \
    fi

RUN if [ "$is_mirror" = "true" ]; then \
        git clone https://gitee.com/ren-chengchengren/noVNC.git /noVNC && \
        git clone https://gitee.com/mirrors/websockify.git /noVNC/utils/websockify; \
    else \
        git clone https://github.com/novnc/noVNC.git /noVNC && \
        git clone https://github.com/novnc/websockify.git /noVNC/utils/websockify; \
    fi \
    && ln -sf /noVNC/vnc.html /noVNC/index.html

RUN apt-get clean \
    && rm -rf /var/cache/* /var/log/apt/* /var/lib/apt/lists/* /tmp/* \
    && groupadd -f chrome-remote-desktop \
    && groupadd -f pulse-access \
    && useradd -m -G chrome-remote-desktop,pulse-access -s /bin/bash chrome \
    && ln -sf /crdonly /usr/local/sbin/crdonly \
    && ln -sf /update /usr/local/sbin/update \
    && mkdir -p /home/chrome/.config/chrome-remote-desktop \
    && mkdir -p /home/chrome/.fluxbox \
    && printf '%s\n' \
        'session.screen0.toolbar.visible:        false' \
        'session.screen0.fullMaximization:       true' \
        'session.screen0.maxDisableResize:       true' \
        'session.screen0.maxDisableMove:         true' \
        'session.screen0.defaultDeco:            NONE' \
        >> /home/chrome/.fluxbox/init \
    && chown -R chrome:chrome /home/chrome/.config /home/chrome/.fluxbox

USER chrome

VOLUME ["/home/chrome"]

WORKDIR /home/chrome

EXPOSE 5900 8900

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
