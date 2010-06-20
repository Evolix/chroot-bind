#!/bin/sh

# Gregory Colpart <reg@evolix.fr>
# chroot (or re-chroot) script for bind9

# tested on Debian Sarge and Etch and Lenny
# Exec this script after `(apt-get|aptitude) install bind9`
# and after *each* bind9 upgrade

# When the script is finished, ensure you have
# 'OPTIONS="-u bind -t /var/chroot-bind"' in /etc/default/bind9
# and /etc/init.d/bind9 (re)start

# essential dirs
mkdir -p /var/chroot-bind
mkdir -p /var/chroot-bind/bin /var/chroot-bind/dev /var/chroot-bind/etc \
        /var/chroot-bind/lib /var/chroot-bind/usr/lib                   \
        /var/chroot-bind/usr/sbin /var/chroot-bind/var/cache/bind       \
        /var/chroot-bind/var/log /var/chroot-bind/var/run/bind/run/

# for conf
if [ ! -h "/etc/bind" ]; then
    mv /etc/bind/ /var/chroot-bind/etc/
    ln -s /var/chroot-bind/etc/bind/ /etc/bind
fi

# for logs
touch /var/chroot-bind/var/log/bind.log
if [ ! -h "/var/log/bind.log" ]; then
    ln -s /var/chroot-bind/var/log/bind.log /var/log/bind.log
fi

# for pid
mkdir -p /var/run/bind/run
chown -R root:bind  /var/run/bind/
chmod -R  g+rwX /var/run/bind/

if [ -d "/var/chroot-bind/var/run/bind/run/named" ]; then
    rmdir /var/chroot-bind/var/run/bind/run/named
    rm /var/run/bind/run/named.pid
fi

if [ ! -h "/var/run/bind/run/named.pid" ]; then
    ln -s /var/chroot-bind/var/run/bind/run/named.pid /var/run/bind/run/named.pid
fi

if [ ! -e "/var/chroot-bind/dev/random" ]; then
    mknod /var/chroot-bind/dev/random c 1 3
    chmod 666 /var/chroot-bind/dev/random
fi
# essential dev (hum, null is required ??)
#mknod /var/chroot-bind/dev/null c 1 3
#chmod 666 /var/chroot-bind/dev/{null,random}

# essential libs
for i in `ldd $(which named) | cut -d">" -f2 | cut -d"(" -f1`; do install \
        -D $i /var/chroot-bind/${i##/}; done

# essential (hum, bash is required ??)
#cp /bin/bash /var/chroot-bind/bin/
cp /usr/sbin/named /var/chroot-bind/usr/sbin/

# minimal passwd & group file (hum, is required ??)
#grep "bind\|root" /etc/passwd > /var/chroot-bind/etc/passwd
#grep "bind\|root" /etc/group > /var/chroot-bind/etc/group

# just bind
chown -R bind.bind /var/chroot-bind/

