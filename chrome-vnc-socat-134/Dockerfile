FROM ubuntu:22.04

ARG is_mirror=false

ENV VNC_SCREEN_SIZE=1920x1080

ENV LANG C.UTF-8

COPY copyables /

RUN if [ "$is_mirror" = "true" ]; then \
        sed -i 's#http://.*ubuntu.com#http://mirrors.aliyun.com#g' /etc/apt/sources.list; \
    fi && \
    apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
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
    xdotool

RUN if [ "$is_mirror" = "true" ]; then \
        pip3 install --no-cache-dir websockify -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple; \
    fi

RUN if [ "$is_mirror" = "true" ]; then \
        git clone https://gitee.com/ren-chengchengren/noVNC.git /noVNC && \
        git clone https://gitee.com/mirrors/websockify.git /noVNC/utils/websockify; \
    else \
        git clone https://github.com/novnc/noVNC.git /noVNC && \
        git clone https://github.com/novnc/websockify.git /noVNC/utils/websockify; \
    fi && \
    ln -s /noVNC/vnc.html /noVNC/index.html

# RUN curl -fsSL "https://mirror.cs.uchicago.edu/google-chrome/pool/main/g/google-chrome-stable/google-chrome-stable_134.0.6998.88-1_amd64.deb" -o /tmp/google-chrome-stable.deb \
RUN curl -fsSL "https://github.com/shootdev/chrome-vnc-socat/releases/download/134/google_chrome_134_0_6998_88.deb" -o /tmp/google-chrome-stable.deb  && \
    curl -fsSL "https://github.com/shootdev/chrome-vnc-socat/releases/download/134/chrome_remote_desktop_138_0_7204_6.deb" -o /tmp/chrome_remote_desktop.deb  \
    && dpkg -i /tmp/google-chrome-stable.deb \
    || dpkg -i /tmp/chrome_remote_desktop.deb \
    || DEBIAN_FRONTEND=noninteractive apt-get -f --yes install

RUN apt-get clean \
    && rm -rf /var/cache/* /var/log/apt/* /var/lib/apt/lists/* /tmp/* /chrome_remote_desktop.deb /google_chrome_134.deb* \
    && useradd -m -G chrome-remote-desktop,pulse-access chrome \
    && usermod -s /bin/bash chrome \
    && ln -s /crdonly /usr/local/sbin/crdonly \
    && ln -s /update /usr/local/sbin/update \
    && mkdir -p /home/chrome/.config/chrome-remote-desktop \
    && mkdir -p /home/chrome/.fluxbox \
    && echo ' \n\
    session.screen0.toolbar.visible:        false\n\
    session.screen0.fullMaximization:       true\n\
    session.screen0.maxDisableResize:       true\n\
    session.screen0.maxDisableMove: true\n\
    session.screen0.defaultDeco:    NONE\n\
    ' >> /home/chrome/.fluxbox/init \
    && chown -R chrome:chrome /home/chrome/.config /home/chrome/.fluxbox


# headfull proxy
#ENV PORT 9222
#ENV PORT_INTERNAL 9992
#COPY services/proxy.init /etc/service/proxy/run
#RUN \
#    apt-get install $APT_FLAGS socat && \
#    chmod +x /etc/service/proxy/run


USER chrome

VOLUME ["/home/chrome"]

WORKDIR /home/chrome

EXPOSE 5900 8900

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
