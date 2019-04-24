FROM debian:stretch-slim

LABEL maintainer="hyeon0145@gmail.com"

RUN apt-get update && apt-get install -y \
    strongswan \
    strongswan-pki \
    libcharon-extra-plugins \
    kmod \
    iptables \
&& rm -rf /var/lib/apt/lists/*

EXPOSE 500:500/udp
EXPOSE 4500:4500/udp

COPY ipsec.conf.template /ipsec.conf.template
COPY ipsec.secrets.template /ipsec.secrets.template

COPY entry.sh /entry.sh
RUN chmod u+x /entry.sh
CMD /entry.sh