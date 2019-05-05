# docker-ikev2-vpn
Dockerized IKEv2 VPN server

## Usage

    $ docker run \
        --detach \
        --privileged \
        --volume=/lib/modules:/lib/modules \
        --publish=500:500/udp \
        --publish=4500:4500/udp \
        --env NAME="<VPN Server Name>" \
        --env HOST="<Host IP>" \
        --name=ikev2-vpn \
        jonghwanhyeon/ikev2-vpn


To view and download the certificate:

    $ docker exec ikev2-vpn manage certificate


To add a user:

    $ docker exec ikev2-vpn manage adduser <username> <password>