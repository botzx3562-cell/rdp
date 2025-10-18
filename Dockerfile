FROM ubuntu:22.04

# تجنب الأسئلة التفاعلية أثناء التثبيت
ENV DEBIAN_FRONTEND=noninteractive

# تحديث النظام وتثبيت الحزم الأساسية
RUN apt-get update && apt-get install -y \
    xrdp \
    xfce4 \
    xfce4-goodies \
    supervisor \
    sudo \
    dbus-x11 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# إنشاء مستخدم RDP مع كلمة مرور
RUN useradd -m -s /bin/bash rdpuser && \
    echo "rdpuser:SecurePass2025!" | chpasswd && \
    usermod -aG sudo rdpuser

# تكوين XRDP لاستخدام XFCE
RUN echo "xfce4-session" > /home/rdpuser/.xsession && \
    chown rdpuser:rdpuser /home/rdpuser/.xsession

# تكوين XRDP
RUN sed -i 's/port=3389/port=3389/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/max_bpp=32/max_bpp=128/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/#rsakeys_ini=/rsakeys_ini=\/etc\/xrdp\/rsakeys.ini/g' /etc/xrdp/xrdp.ini

# إنشاء ملف تكوين Supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# فتح المنفذ 3389
EXPOSE 3389

# تشغيل Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
