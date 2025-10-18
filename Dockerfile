FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# تحديث النظام وتثبيت الحزم
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

# إنشاء مستخدم RDP
RUN useradd -m -s /bin/bash rdpuser && \
    echo "rdpuser:SecurePass2025!" | chpasswd && \
    usermod -aG sudo rdpuser

# تكوين XRDP
RUN echo "xfce4-session" > /home/rdpuser/.xsession && \
    chown rdpuser:rdpuser /home/rdpuser/.xsession && \
    chmod +x /home/rdpuser/.xsession

# تحسين إعدادات XRDP
RUN sed -i 's/port=3389/port=3389/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/max_bpp=32/max_bpp=128/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/xserverbpp=24/xserverbpp=128/g' /etc/xrdp/xrdp.ini

# إنشاء مجلدات ضرورية
RUN mkdir -p /var/run/dbus && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /run/xrdp

# نسخ ملف تكوين Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# إنشاء سكريبت بدء التشغيل
RUN echo '#!/bin/bash\n\
# تهيئة dbus\n\
dbus-uuidgen > /var/lib/dbus/machine-id\n\
mkdir -p /var/run/dbus\n\
# بدء supervisor\n\
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf\n\
' > /start.sh && chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
