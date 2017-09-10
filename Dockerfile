FROM blitznote/debootstrap-amd64:16.04
MAINTAINER tuxmonteiro

EXPOSE 5000 35357
ENV KEYSTONE_ADMIN_PASSWORD passw0rd
ENV KEYSTONE_DB_ROOT_PASSWD passw0rd
ENV KEYSTONE_DB_PASSWD passw0rd

RUN echo -e 'path-exclude /usr/share/locale/*\npath-include /usr/share/locale/en*\npath-exclude /usr/share/doc/*\npath-exclude /usr/share/man/*\npath-exclude /usr/share/groff/*\npath-exclude /usr/share/info/*' > /etc/dpkg/dpkg.cfg.d/01_nodoc \
    && echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/99no-recommends \
    && echo -e 'Dir::Cache {\n  srcpkgcache "";\n  pkgcache "";\n}' > /etc/apt/apt.conf.d/02nocache \
    && apt-get -y update \
    && apt-get install -y apt-utils \
    && apt-get install -y gcc build-essential login \
    && apt-get install -y apache2 libapache2-mod-wsgi git memcached libffi-dev python python-dev libssl-dev mysql-client libldap2-dev libsasl2-dev keystone python-pip systemd-sysv python-setuptools \
    && pip install wheel \
    && pip install python-openstackclient PyMySql python-memcached python-ldap ldappool \
    && export DEBIAN_FRONTEND="noninteractive" \
    && export RUNLEVEL=1 \
    && echo "mysql-server mysql-server/root_password password $KEYSTONE_DB_ROOT_PASSWD" | debconf-set-selections \
    && echo "mysql-server mysql-server/root_password_again password $KEYSTONE_DB_ROOT_PASSWD" | debconf-set-selections \
    && apt-get install -y mysql-server \
    && apt-get remove -y --purge gcc build-essential \
    && dpkg -l | grep -- '-dev[ :]' | awk '{ print $2 }' | xargs apt-get remove -y --purge \
    && apt-get autoremove -y --purge \
    && apt-get -y clean \
    && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

COPY keystone.conf /etc/keystone/keystone.conf
COPY keystone.sql /keystone.sql
COPY bootstrap.sh /bootstrap.sh
COPY keystone.wsgi.conf /etc/apache2/sites-available/keystone.conf

WORKDIR /root
CMD sh -x /bootstrap.sh
