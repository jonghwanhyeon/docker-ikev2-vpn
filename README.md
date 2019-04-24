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
        --env USERNAME="<Username>" \
        --env PASSWORD="<Password>" \
        jonghwanhyeon/ikev2