FROM debian:jessie

MAINTAINER QuillerCS

RUN apt-get update --fix-missing && apt-get upgrade -y && apt-get install -y autoconf gawk automake build-essential devscripts \
        g++ git-core libjpeg-dev libncurses5-dev libtool make python-dev libspeexdsp-dev libspeexdsp1 libspeexdsp-dev          \
        pkg-config libperl-dev libgdbm-dev libdb-dev gettext libedit-dev libldns-dev                                           \
        libspandsp-dev libtiff-dev unixodbc unixodbc-dev sqlite3 libsqlite3-dev libcurl3 curl libcurl3-dev libpcre3            \
        libpcre3-dev libspeex-dev speex libtool-bin git wget libhiredis-dev libsndfile-dev yasm

RUN echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list && \
    wget -O - http://files.freeswitch.org/repo/deb/freeswitch-1.6/key.gpg |apt-key add - &&                                  \
    apt-get update --fix-missing && apt-get install -y libyuv-dev libvpx2-dev

# To install all freeswitch deps
# RUN apt-get update && apt-get install -y freeswitch-all

# Get the source
RUN git config --global pull.rebase true &&                                                    \
    git clone https://freeswitch.org/stash/scm/fs/freeswitch.git --depth 1 /usr/src/freeswitch

ADD modules.conf /usr/src/freeswitch/modules.conf

WORKDIR /usr/src/freeswitch
 
RUN ./bootstrap.sh -j &&      \
    ./configure &&            \
    make &&                   \
    make install &&           \
    make clean


# freeswitch user

RUN groupadd freeswitch
RUN adduser --disabled-password  --quiet --system --home /usr/local/freeswitch --gecos "FreeSWITCH open source softswitch" --ingroup freeswitch freeswitch
RUN chown -R freeswitch:freeswitch /usr/local/freeswitch/ &&  \
    chmod -R ug=rwX,o= /usr/local/freeswitch/ &&              \
    chmod -R u=rwx,g=rx /usr/local/freeswitch/bin/*

RUN rm -rf .git && rm -R /usr/src/*  && apt-get clean && rm -rf /tmp/* /var/tmp/* && rm -rf /var/lib/apt/lists/*

ENTRYPOINT /usr/local/freeswitch/bin/freeswitch
