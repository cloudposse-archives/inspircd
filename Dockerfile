FROM ubuntu:14.04

MAINTAINER Erik Osterman <e@osterman.com>

ENV INSPIRCD_SERVER_NAME irc.cloudposse.com
ENV INSPIRCD_SERVER_DESCRIPTION Cloudposse IRC Networks
ENV INSPIRCD_NETWORK CloudPosse
ENV INSPIRCD_ADMIN_NAME Cloud Posse
ENV INSPIRCD_ADMIN_NICK cloudposse
ENV INSPIRCD_ADMIN_EMAIL ops@cloudposse.com

ENV INSPIRCD_LINK_NAME anope.localhost
ENV INSPIRCD_LINK_PORT 7000
ENV INSPIRCD_LINK_SEND_PASS secret
ENV INSPIRCD_LINK_RECV_PASS secret

ENV INSPIRCD_CGIHOST_WEBIRC_PASSWORD super-secret
ENV INSPIRCD_CLOAK_KEY something-secret

ENV INSPIRCD_STATS_USERNAME stats
ENV INSPIRCD_STATS_PASSWORD password
ENV INSPIRCD_STATS_WHITELIST 127.0.0.*,10.*,192.168.*

ENV INSPIRCD_SQLLOG_QUERY INSERT INTO events (nick, host, ip, user_name, ident, server, channel, event, message) VALUES ('$nick', '$host', '$ip', '$gecos', '$ident', '$server', '$channel', '$event', '$message')

# Mysql
ENV MYSQL_USER irc
ENV MYSQL_PASSWORD password
ENV MYSQL_DATABASE inspircd
ENV MYSQL_HOST localhost
ENV MYSQL_PORT 3306


# TODO: MySQL configuration
# TODO: Log to MySSQL
# TODO: Nick registration (via Anope) with MySQL
# TODO: Motd / branding
# TODO: WebIRC

ADD https://github.com/inspircd/inspircd/archive/v2.0.18.tar.gz /usr/src/
ADD m_sqllog.cpp /usr/src/

RUN apt-get update && \
    apt-get install -y build-essential libssl-dev libssl1.0.0 openssl pkg-config  libwww-perl libmysqlclient-dev mysql-client gettext && \
    groupadd -g 1000 inspircd && \
    useradd -u 1000 -g 1000 -d /inspircd/ inspircd && \
    cd /usr/src && \
    tar -xzf *.tar.gz && \
    ln -sf inspircd-* inspircd  && \
    mv /usr/src/*.cpp /usr/src/inspircd/src/modules/extra/ && \
    cd /usr/src/inspircd  && \
    ./configure  --enable-extras=m_mysql.cpp \
                 --enable-extras=m_sqllog.cpp && \
    ./configure --disable-interactive --prefix=/inspircd/ --uid 1000 --enable-openssl && \
    make && \
    make install && \
    mkdir -p /inspircd/conf.d && \
    chown 1000:1000 -R /inspircd && \
    apt-get purge -y build-essential && rm -rf /usr/src/inspircd/

USER inspircd
WORKDIR /inspircd
ADD data/ /inspircd/data
ADD templates/ /inspircd/templates/
ADD inspircd.conf /inspircd/conf/
ADD start /start

EXPOSE 6667 6697

ENTRYPOINT ["/start"]

