FROM debian:stretch-slim

LABEL maintainer="hyeon0145@gmail.com"

RUN apt-get update && apt-get install -y \
    python3-minimal \
    strongswan \
    strongswan-pki \
    libcharon-extra-plugins \
    kmod \
    iptables \
&& rm -rf /var/lib/apt/lists/*

EXPOSE 500:500/udp
EXPOSE 4500:4500/udp

COPY conf/ipsec.conf.template /etc/ipsec.conf
COPY conf/charon-logging.conf /etc/strongswan.d/charon-logging.conf
COPY conf/charon.conf /etc/strongswan.d/charon.conf
COPY conf/ipsec.secrets /etc/ipsec.secrets

COPY scripts/manage /usr/local/bin/manage
RUN chmod u+x /usr/local/bin/manage

COPY scripts/entry.sh /entry.sh
RUN chmod u+x /entry.sh
CMD /entry.sh
