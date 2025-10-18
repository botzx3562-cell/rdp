FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    xrdp \
    xfce4 \
    xfce4-goodies \
    supervisor \
    sudo \
    dbus-x11 \
    x11vnc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash rdpuser && \
    echo "rdpuser:SecurePass2025!" | chpasswd && \
    usermod -aG sudo rdpuser

RUN echo "xfce4-session" > /home/rdpuser/.xsession && \
    chown rdpuser:rdpuser /home/rdpuser/.xsession && \
    chmod +x /home/rdpuser/.xsession

RUN sed -i 's/port=3389/port=3389/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/max_bpp=32/max_bpp=128/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/xserverbpp=24/xserverbpp=128/g' /etc/xrdp/xrdp.ini

RUN mkdir -p /var/run/dbus && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /run/xrdp

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN echo '#!/bin/bash' > /start.sh && \
    echo 'dbus-uuidgen > /var/lib/dbus/machine-id' >> /start.sh && \
    echo 'mkdir -p /var/run/dbus' >> /start.sh && \
    echo 'exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
