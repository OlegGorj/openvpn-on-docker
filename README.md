[![Build Status](https://travis-ci.org/OlegGorj/openvpn-on-docker.svg?branch=master)](https://travis-ci.org/OlegGorj/openvpn-on-docker)
[![GitHub Issues](https://img.shields.io/github/issues/OlegGorJ/openvpn-on-docker.svg)](https://github.com/OlegGorJ/openvpn-on-docker/issues)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/OlegGorJ/openvpn-on-docker.svg)](http://isitmaintained.com/project/OlegGorJ/openvpn-on-docker "Average time to resolve an issue")
[![Percentage of issues still open](http://isitmaintained.com/badge/open/OlegGorJ/openvpn-on-docker.svg)](http://isitmaintained.com/project/OlegGorJ/openvpn-on-docker "Percentage of issues still open")
[![Docker Stars](https://img.shields.io/docker/stars/oleggorj/openvpn.svg)](https://hub.docker.com/r/oleggorj/openvpn/)
[![Docker Pulls](https://img.shields.io/docker/pulls/oleggorj/openvpn.svg)](https://hub.docker.com/r/oleggorj/openvpn/)
[![ImageLayers](https://images.microbadger.com/badges/image/oleggorj/openvpn.svg)](https://microbadger.com/#/images/oleggorj/openvpn)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FOlegGorj%2Fopenvpn-on-docker.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2FOlegGorj%2Fopenvpn-on-docker?ref=badge_shield)

# OpenVPN on docker container

OpenVPN server in a Docker container complete with an EasyRSA PKI CA.


### OpenVPN deployment details

- Use `tun` mode, because it works on the widest range of devices. tap mode, for instance, does not work on Android, except if the device is rooted.

- The topology used is `net30`, because it works on the widest range of OS.

- The UDP server uses192.168.255.0/24 for dynamic clients by default.

- The client profile specifies redirect-gateway def1, meaning that after establishing the VPN connection, all traffic will go through the VPN.



## Setup instructions

To setup VPN clients, generate VPN client credentials for `CLIENTNAME` without password protection; leave 'nopass' out to enter password.

```
ENDPOINT_SERVER=<external IP of bastion instance>
CLIENTNAME=openvpn
```

To create docker volume:

```
OVPN_DATA="ovpn-data-vol"
docker volume create --name $OVPN_DATA
```

Initialize the $OVPN_DATA container that will hold the configuration files and certificates. The container will prompt for a passphrase to protect the private key used by the newly generated certificate authority

```
docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm oleggorj/openvpn ovpn_genconfig -u udp://$ENDPOINT_SERVER
docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it oleggorj/openvpn ovpn_initpki
```

Start OpenVPN server process:

```
docker run -v $OVPN_DATA:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN oleggorj/openvpn
```

Generate a client certificate:

```
docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it oleggorj/openvpn easyrsa build-client-full $CLIENTNAME nopass
```

To generate `ovpn` file:

```
docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm oleggorj/openvpn ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn
```



## Debug

Create an environment variable with the name DEBUG and value of 1 to enable debug output (using "docker -e").

```
docker run -v $OVPN_DATA:/etc/openvpn -p 1194:1194/udp --privileged -e DEBUG=1 oleggorj/openvpn
```

Test using a client that has openvpn installed correctly

```
openvpn --config $CLIENTNAME.ovpn
```



## Links and references

[(Wiki setting up a OpenVPN server)](https://wiki.alpinelinux.org/w/index.php?title=Setting_up_a_OpenVPN_server&redirect=no)

[(Openvpn-AS Docker container)](https://hub.docker.com/r/linuxserver/openvpn-as/)



---
