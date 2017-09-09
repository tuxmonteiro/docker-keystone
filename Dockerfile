FROM blitznote/debootstrap-amd64:16.04
MAINTAINER tuxmonteiro

EXPOSE 5000 35357
ENV KEYSTONE_ADMIN_PASSWORD passw0rd
ENV KEYSTONE_DB_ROOT_PASSWD passw0rd
ENV KEYSTONE_DB_PASSWD passw0rd

RUN apt-get -y update \
    && apt-get install -y login apache2 libapache2-mod-wsgi git memcached libffi-dev python python-dev libssl-dev mysql-client libldap2-dev libsasl2-dev \
    && apt-get -y clean

RUN export DEBIAN_FRONTEND="noninteractive" \
    && echo "mysql-server mysql-server/root_password password $KEYSTONE_DB_ROOT_PASSWD" | debconf-set-selections \
    && echo "mysql-server mysql-server/root_password_again password $KEYSTONE_DB_ROOT_PASSWD" | debconf-set-selections \
    && apt-get -y update && apt-get install -y mysql-server && apt-get -y clean

RUN apt-get -y install keystone python-pip && pip install python-openstackclient PyMySql python-memcached python-ldap ldappool

COPY keystone.conf /etc/keystone/keystone.conf
COPY keystone.sql /keystone.sql
COPY bootstrap.sh /bootstrap.sh
COPY keystone.wsgi.conf /etc/apache2/sites-available/keystone.conf

WORKDIR /root
CMD sh -x /bootstrap.sh
