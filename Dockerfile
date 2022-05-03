FROM ubuntu:20.04

LABEL version="0.2"

RUN apt-get -q -y update \
&& apt-get -q -y install isc-dhcp-server iproute2 bc \
 && apt-get -q -y autoremove \
 && apt-get -q -y clean \
 && rm -rf /var/lib/apt/lists/*

RUN touch /var/lib/dhcp/dhcpd.leases

ENV HA=true \
    ROLE=PRIMARY \
    PEER_ADDRESS=169.254.1.2 \
    HA_PORT=647 \
    MAX_RESPONSE_DELAY=60 \
    MAX_UNACKED_UPDATES=10 \
    LOAD_BALANCE_MAX_SECONDS=3 \
    MCLT=3600 \
    SPLIT=128

COPY data/dhcpd.conf /etc/dhcp/dhcpd.conf

COPY utils/* /utils/

EXPOSE 67/udp

ENTRYPOINT ["/utils/entrypoint.sh"]