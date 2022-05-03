# docker-dhcpd-ha
 DHCPD HA Docker container


| Enviroment Value         | Description                                                                                                                                              | Default value |
|--------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| HA			           | **Required:** Enables or Disables DHCP HA Failover. Enabled equals `HA=true`                                                                             | False         |
| ROLE                     | **Required if HA=TRUE :** Set server as Primary or Secondary. `ROLE=PRIMARY`                                                                             | Not Set       |
| PEER_ADDRESS             | **Required if HA=TRUE :** Other DHCP HA Peer IP address. Use the Docker host IP not containers. `PEER_ADDRESS=192.168.1.1`                               | Not Set       |
| HA_PORT                  | Port used to communicate to DHCP HA peer. `HA_PORT=520`                                                                                                  | 647           |
| MAX_RESPONSE_DELAY       | How many seconds may pass without receiving a message from its failover peer before it assumes that connection has failed. `MAX_RESPONSE_DELAY=120`      | 60            |
| MAX_UNACKED_UPDATES      | How many BNDUPD messages it can send before it receives a BNDACK from the local system. `MAX_UNACKED_UPDATES=20`                                         | 10            |
| LOAD_BALANCE_MAX_SECONDS | Allows you to configure a cutoff after which load balancing is disabled. `LOAD_BALANCE_MAX_SECONDS=6`                                                    | 3             |
| MCLT                     |  This is the length of time for which a lease may be renewed by either failover peer without contacting the other. `MCLT=3000`                           | 3600          |
| SPLIT                    | The split statement specifies the split between the primary and secondary for the purposes of load balancing. 0 (Secondary) - 255 (Primary). `SPLIT=255` | 128           |