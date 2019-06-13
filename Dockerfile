FROM debian:stretch-slim AS builder

ENV STRONGSWAN_VERSION 5.8.0

RUN apt-get update && apt-get install -y \
    curl \
    checkinstall \
    build-essential \
    pkg-config \
    libssl-dev \
    libiptc-dev \
&& rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN curl \
    --output strongswan-$STRONGSWAN_VERSION.tar.gz \
    https://download.strongswan.org/strongswan-$STRONGSWAN_VERSION.tar.gz
RUN tar xfz strongswan-$STRONGSWAN_VERSION.tar.gz

WORKDIR /tmp/strongswan-$STRONGSWAN_VERSION
RUN ./configure \
    --sysconfdir=/etc \
    --enable-acert \
    --enable-addrblock \
    --enable-dhcp \
    --enable-eap-identity \
    --enable-eap-md5 \
    --enable-eap-mschapv2 \
    --enable-eap-peap \
    --enable-eap-tls \
    --enable-eap-tnc \
    --enable-eap-ttls \
    --enable-md4 \
    --enable-openssl \
    --enable-xauth-eap \
    --disable-gmp \
    --disable-swanctl \
    --disable-vici
RUN make
RUN checkinstall --default --install=no --fstrans=no --nodoc
RUN mv strongswan*.deb /tmp/strongswan.deb


FROM debian:stretch-slim

LABEL maintainer="hyeon0145@gmail.com"

RUN apt-get update && apt-get install -y \
    python3-minimal \
    iptables \
&& rm -rf /var/lib/apt/lists/*

COPY --from=builder /tmp/strongswan.deb /tmp/strongswan.deb
COPY --from=builder /etc/ipsec.d /etc/ipsec.d
RUN dpkg -i /tmp/strongswan.deb && rm /tmp/strongswan.deb

COPY conf/ipsec.conf.template /etc/ipsec.conf
COPY conf/charon-logging.conf /etc/strongswan.d/charon-logging.conf
COPY conf/charon.conf /etc/strongswan.d/charon.conf
COPY conf/ipsec.secrets /etc/ipsec.secrets

COPY scripts/manage /usr/local/bin/manage
RUN chmod u+x /usr/local/bin/manage

COPY scripts/entry.sh /entry.sh
RUN chmod u+x /entry.sh

EXPOSE 500:500/udp
EXPOSE 4500:4500/udp
CMD /entry.sh