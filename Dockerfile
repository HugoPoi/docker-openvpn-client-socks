# OpenVPN client + SOCKS proxy
# Usage:
# Create configuration (.ovpn), mount it in a volume
# docker run --volume=something.ovpn:/ovpn.conf:ro --device=/dev/net/tun --cap-add=NET_ADMIN
# Connect to (container):1080
# Note that the config must have embedded certs
# See `start` in same repo for more ideas

FROM alpine

COPY sockd.sh /usr/local/bin/

RUN true \
    && echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add --update-cache dante-server openvpn bash openresolv openrc \
    && rm -rf /var/cache/apk/* \
    && chmod a+x /usr/local/bin/sockd.sh \
# Add a user   && adduser test -D \
# Add password method 1    && echo test:superpassword | chpasswd \
# Add password method 2   && echo "superpassword" | passwd test --stdin \
    && true

COPY sockd.conf /etc/

WORKDIR /etc/openvpn

ENTRYPOINT [ \
    "/usr/sbin/openvpn",\
    "--config", "config.ovpn",\
    "--script-security", "2",\
    "--up", "/usr/local/bin/sockd.sh"\
    ]
