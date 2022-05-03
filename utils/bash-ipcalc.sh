#!/bin/bash

function convip() {

    CONV=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1})

    ip=""
    for byte in `echo ${1} | tr "." " "`; do
        ip="${ip}${CONV[${byte}]}"
    done
    echo ${ip:0}
}

function convbin() {
    bin=${1}
    length=${#bin}
    while [ $length -le 31 ]
    do
        bin="0${bin}"
        ((length++))
    done
    ip=""
    for byte in `echo $bin | sed -r 's/(.{8})/\1 /g'`; do
        ip=`echo "$ip$((2#${byte}))".`
    done
    ip=${ip%?}
    echo $ip
}

function netmask() {
    mask=$(($1))
    netmask=`head -c $mask < /dev/zero | tr '\0' '1'`
    length=${#netmask}
    while [ $length -le 31 ]
    do
        netmask="${netmask}0"
        ((length++))
    done
    echo ${netmask}
}

function network() {
    ip=$((2#${1}))
    netmask=$((2#${2}))
    network=`echo "$(($ip & $netmask))"`
    network=`echo "obase=2;${network}" | bc`
    network=`convbin "${network}"`
    echo ${network}
}

function gateway() {
    ip=$((2#${1}))
    netmask=$((2#${2}))
    network=`echo "$(($ip & $netmask))"`
    network=`echo "obase=2;${network}" | bc`
    one=1
    gateway=`echo "ibase=2;obase=2;$network+$one" | bc -l`
    gateway=`convbin "${gateway}"`
    echo ${gateway}
}

binaryOfIP=`convip "${1}"`
IPDotted=`convbin "${binaryOfIP}"`
binaryOfNetmask=`netmask "${2}"`
NetmaskDotted=`convbin "${binaryOfNetmask}"`
GatewayDotted=`gateway "${binaryOfIP}" "${binaryOfNetmask}"`
NetworkDotted=`network "${binaryOfIP}" "${binaryOfNetmask}"`

echo "IP Binary:  ${binaryOfIP}"
echo "IP Address: ${IPDotted}"
echo "Netmask Spacing: 12345678123456781234567812345678"
echo "Netmask Binary : ${binaryOfNetmask}"
echo "Netmask Dotted : ${NetmaskDotted}"
echo "Gateway: ${GatewayDotted}"
echo "Network: ${NetworkDotted}"
