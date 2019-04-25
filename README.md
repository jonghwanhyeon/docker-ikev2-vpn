# docker-vpn-ikev2
Dockerized VPN server using IKEv2 protocol

## Usage
    $ docker run \
        --detach \
        --privileged \
        --publish=500:500/udp \
        --publish=4500:4500/udp \
        --env NAME="<VPN Server Name>" \
        --env HOST="<Host IP>" \
        --name=vpn-ikev2 \
        jonghwanhyeon/vpn-ikev2

To view and download the certificate:
    $ docker exec vpn-ikev2 manage certificate

To add a user:
    $ docker exec vpn-ikev2 manage adduser <username> <password>