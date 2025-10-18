#!/bin/bash
set -e

# إنشاء مجلدات النظام الضرورية
mkdir -p /var/log/supervisor
mkdir -p /var/run/dbus
chown -R root:root /var/log/supervisor

# توليد machine-id إذا لم يكن موجود
if [ ! -f /var/lib/dbus/machine-id ]; then
  dbus-uuidgen > /var/lib/dbus/machine-id || true
fi

# تأكد من صلاحيات ملف .xsession للمستخدم
if [ -f /home/rdpuser/.xsession ]; then
  chown rdpuser:rdpuser /home/rdpuser/.xsession || true
  chmod +x /home/rdpuser/.xsession || true
fi

# تشغيل supervisord (الذي سيبدأ dbus + xrdp)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
