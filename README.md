# Docker-DHCPD-HA

A HA ISC dhcp docker container. Automatically deploy without needing to attach to the host network adapter and have the failover config generated.

## Running the Container

From the command line 

DHCP primary server:

```
docker run -v ./runtime:/data -e HA=true -e ROLE=PRIMARY -e PEER_ADDRESS=169.254.1.2 -e HA_PORT=647 -e MAX_RESPONSE_DELAY=15 -e MAX_UNACKED_UPDATES=10 -e LOAD_BALANCE_MAX_SECONDS=3 -e MCLT=3600 -e SPLIT=128 --name dhcp-pri -p 67:67/udp -p 647:647/tcp --restart always sadviper/docker_dhcp_ha
```

DHCP secondary server:

```
docker run -v ./runtime:/data -e HA=true -e ROLE=Secondary -e PEER_ADDRESS=169.254.1.1 -e HA_PORT=647 -e MAX_RESPONSE_DELAY=15 -e MAX_UNACKED_UPDATES=10 -e LOAD_BALANCE_MAX_SECONDS=3 --name dhcp-sec -p 67:67/udp -p 647:647/tcp --restart always sadviper/docker_dhcp_ha
```

### Docker-Compose

Example docker-compose file

DHCP primary server:

```
version: '3.3'
services:
    dhcp-server:
        container_name: dhcp-pri
        environment:
            - HA=true
            # Env used in HA Failover not required if not HA=true
            - ROLE=PRIMARY
            - PEER_ADDRESS=169.254.1.2
            - HA_PORT=647
            - MAX_RESPONSE_DELAY=15
            - MAX_UNACKED_UPDATES=10
            - LOAD_BALANCE_MAX_SECONDS=3
            - MCLT=3600
            - SPLIT=128
        ports:
            - '67:67/udp'
            - '647:647/tcp' # HA failover port
        volumes:
            - ./runtime:/data # Save dhcpd.conf and dhcpd.leases
        image: 'sadviper/docker_dhcp_ha'
```

DHCP secondary server:
```
version: '3.3'
services:
    dhcp-server:
        container_name: dhcp-sec
        environment:
            - HA=true
            # Env used in HA Failover not required if not HA=true
            - ROLE=SECONDARY
            - PEER_ADDRESS=169.254.1.1
            - HA_PORT=647
            - MAX_RESPONSE_DELAY=15
            - MAX_UNACKED_UPDATES=10
            - LOAD_BALANCE_MAX_SECONDS=3
        ports:
            - '67:67/udp'
            - '647:647/tcp' # HA failover port
        volumes:
            - ./runtime:/data # Save dhcpd.conf and dhcpd.leases
        image: 'sadviper/docker_dhcp_ha'
```

## Enviroment Values

| Enviroment Value         | Description                   | Default value               |
|--------------------------|-------------------------------|-----------------------------|
| HA			           | **Required:** Enables or Disables DHCP HA Failover. Enabled equals `HA=true` | False |
| ROLE                     | **Required if HA=TRUE :** Set server as Primary or Secondary. `ROLE=PRIMARY` | Not Set |
| PEER_ADDRESS             | **Required if HA=TRUE :** Other DHCP HA Peer IP address. Use the Docker host IP not containers. `PEER_ADDRESS=192.168.1.1` | Not Set |
| HA_PORT                  | Port used to communicate to DHCP HA peer. `HA_PORT=520` | 647 |
| MAX_RESPONSE_DELAY       | How many seconds may pass without receiving a message from its failover peer before it assumes that connection has failed. `MAX_RESPONSE_DELAY=120` | 60 |
| MAX_UNACKED_UPDATES      | How many BNDUPD messages it can send before it receives a BNDACK from the local system. `MAX_UNACKED_UPDATES=20` | 10                          |
| LOAD_BALANCE_MAX_SECONDS | Allows you to configure a cutoff after which load balancing is disabled. `LOAD_BALANCE_MAX_SECONDS=6`| 3 |
| MCLT                     |  This is the length of time for which a lease may be renewed by either failover peer without contacting the other. `MCLT=3000` | 3600 |
| SPLIT                    | The split statement specifies the split between the primary and secondary for the purposes of load balancing. 0 (Secondary) - 255 (Primary). `SPLIT=255` | 128 |