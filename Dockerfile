FROM debian:jessie

MAINTAINER QuillerCS

RUN apt-get update --fix-missing && apt-get install -y autoconf gawk automake build-essential devscripts g++ git-core \
        libjpeg-dev libncurses5-dev libtool make python-dev libspeexdsp-dev libspeexdsp1 libspeexdsp-dev \
        pkg-config libperl-dev libgdbm-dev libdb-dev gettext libedit-dev libldns-dev \
        libspandsp-dev libtiff-dev unixodbc unixodbc-dev sqlite3 libsqlite3-dev libcurl3 curl libcurl3-dev libpcre3 \
        libpcre3-dev libspeex-dev speex wget libtool-bin git


RUN echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
RUN wget -O - http://files.freeswitch.org/repo/deb/freeswitch-1.6/key.gpg |apt-key add -
RUN apt-get update && apt-get install libyuv-dev libvpx2-dev -y

# To install all freeswitch deps
# RUN apt-get install freeswitch-all -y


# Get the source
RUN git config --global pull.rebase true
RUN git clone https://freeswitch.org/stash/scm/fs/freeswitch.git /usr/src/freeswitch

ADD modules.conf /usr/src/freeswitch/modules.conf

WORKDIR /usr/src/freeswitch

RUN ./bootstrap.sh -j
RUN ./configure
RUN make
RUN make install
RUN make cd-sounds-install
RUN make cd-moh-install
RUN make samples


# freeswitch user

RUN groupadd freeswitch
RUN adduser --disabled-password  --quiet --system --home /usr/local/freeswitch --gecos "FreeSWITCH open source softswitch" --ingroup freeswitch freeswitch
RUN chown -R freeswitch:freeswitch /usr/local/freeswitch/
RUN chmod -R ug=rwX,o= /usr/local/freeswitch/
RUN chmod -R u=rwx,g=rx /usr/local/freeswitch/bin/*


CMD ["/usr/local/freeswitch/bin/freeswitch"]
