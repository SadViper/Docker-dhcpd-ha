#!/bin/bash
IP=$(ip -o -f inet addr show | awk '/scope global/ {print $4}')

arrIP=(${IP//\// })

network=`./utils/bash-ipcalc.sh ${arrIP[0]} ${arrIP[1]} | awk '/Network/ {print $2}'`
netmask=`./utils/bash-ipcalc.sh ${arrIP[0]} ${arrIP[1]} | awk '/Netmask Dotted/ {print $4}'`
gateway=`./utils/bash-ipcalc.sh ${arrIP[0]} ${arrIP[1]} | awk '/Gateway/ {print $2}'`

mkdir -p /data/external

echo "#Auto Generated Block" > /data/external/extdhcpd.conf
echo "subnet $network netmask $netmask" { >> /data/external/extdhcpd.conf
echo "  option routers $gateway;" >> /data/external/extdhcpd.conf
echo "}" >> /data/external/extdhcpd.conf

echo "" >> /data/external/extdhcpd.conf

if [ ${HA^^} = TRUE ]; 
then
    echo "failover peer \"failover-peer\" {" >> /data/external/extdhcpd.conf
    echo "  ${ROLE,,};" >> /data/external/extdhcpd.conf
    echo "  address ${arrIP[0]};" >> /data/external/extdhcpd.conf
    echo "  port $HA_PORT;" >> /data/external/extdhcpd.conf
    echo "  peer address $PEER_ADDRESS;" >> /data/external/extdhcpd.conf
    echo "  peer port $HA_PORT;" >> /data/external/extdhcpd.conf
    echo "  max-response-delay $MAX_RESPONSE_DELAY;" >> /data/external/extdhcpd.conf
    echo "  max-unacked-updates $MAX_UNACKED_UPDATES;" >> /data/external/extdhcpd.conf
    echo "  load balance max seconds $LOAD_BALANCE_MAX_SECONDS;" >> /data/external/extdhcpd.conf
    if [ ${ROLE^^} = PRIMARY ];
    then
        echo "  mclt $MCLT;" >> /data/external/extdhcpd.conf
        echo "  split $SPLIT;" >> /data/external/extdhcpd.conf
    fi
    echo "}" >> /data/external/extdhcpd.conf
fi

echo "" >> /data/external/extdhcpd.conf

dhcpPath=/etc/dhcp/dhcpd.conf

if [ -f "/data/dhcpd.conf" ]; 
then
  dhcpPath=/data/dhcpd.conf
fi

leasePath=/var/lib/dhcp/dhcpd.leases

if [ -f "/data/dhcpd.leases" ]; 
then
  leasePath=/data/dhcpd.leases
fi

dhcpd -4 -f -d --no-pid -cf $dhcpPath -lf $leasePath