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
    wget \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# أنشئ المستخدم - (هنا باسورد صريح كما طلبت)
RUN useradd -m -s /bin/bash rdpuser && \
    echo "rdpuser:SecurePass2025!" | chpasswd && \
    usermod -aG sudo rdpuser

# تأكد من وجود ملفات الجلسة وحقوقها
RUN echo "xfce4-session" > /home/rdpuser/.xsession && \
    chown rdpuser:rdpuser /home/rdpuser/.xsession && \
    chmod +x /home/rdpuser/.xsession

# تعديلات بسيطة على xrdp.ini (إن وُجدت خيارات أخرى عدّل حسب حاجتك)
RUN sed -i 's/max_bpp=.*$/max_bpp=128/g' /etc/xrdp/xrdp.ini || true && \
    sed -i 's/xserverbpp=.*$/xserverbpp=128/g' /etc/xrdp/xrdp.ini || true

# مجلدات اللوق وملفات التشغيل
RUN mkdir -p /var/log/supervisor /var/run/dbus /run/xrdp && \
    chown -R root:root /var/log/supervisor

# انسخ ملفات الإعدادات (تأكد أنها في الريبو)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
