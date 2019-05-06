#!/bin/sh
if [ ! -d /pki ]; then
  ipsec stop 2> /dev/null
  mkdir /pki && chmod 700 /pki

  # Creating a certificate authority
  ipsec pki --gen --type rsa --size 4096 --outform pem > /pki/ca-key.pem
  ipsec pki --self --ca --lifetime 3650 --in /pki/ca-key.pem \
    --type rsa --dn "CN=$NAME VPN Root CA" --outform pem > /pki/ca-cert.pem

  # Generating a certificate for the VPN server
  ipsec pki --gen --type rsa --size 4096 --outform pem > /pki/server-key.pem
  ipsec pki --pub --in /pki/server-key.pem --type rsa \
      | ipsec pki --issue --lifetime 1825 \
          --cacert /pki/ca-cert.pem \
          --cakey /pki/ca-key.pem \
          --dn "CN=$HOST" --san "$HOST" \
          --flag serverAuth --flag ikeIntermediate --outform pem \
      > /pki/server-cert.pem

  cp /pki/ca-key.pem /etc/ipsec.d/private/
  cp /pki/ca-cert.pem /etc/ipsec.d/cacerts/
  cp /pki/server-key.pem /etc/ipsec.d/private/
  cp /pki/server-cert.pem /etc/ipsec.d/certs/

  sed -i "s/{host}/$HOST/g" /etc/ipsec.conf
fi

iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p udp --dport 500 -j ACCEPT
iptables -A INPUT -p udp --dport 4500 -j ACCEPT
iptables -A FORWARD --match policy --pol ipsec --dir in --proto esp -s 10.10.10.0/24 -j ACCEPT
iptables -A FORWARD --match policy --pol ipsec --dir out --proto esp -d 10.10.10.0/24 -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -m policy --pol ipsec --dir out -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -j MASQUERADE
iptables -t mangle -A FORWARD -m policy --pol ipsec --dir in -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360
iptables -t mangle -A FORWARD -m policy --pol ipsec --dir out -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360

ipsec start --nofork
