#!/bin/bash

# Create ovpn log and otp directories
mkdir -p /var/log/openvpn/
mkdir -p /etc/openvpn/otp/

#######################
####SETUP NETWORKING###
######################
# Create VPN tunnel interface
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
 mknod /dev/net/tun c 10 200
fi

#no routes are set: redirect all traffic from the client over the tunnel.
# NAT mode by default
export this_natdevice=`route | grep '^default' | grep -o '[^ ]*$'`

iptables -t nat -C POSTROUTING -s "${OVPN_NETWORK}" -o $this_natdevice -j MASQUERADE || \
iptables -t nat -A POSTROUTING -s "${OVPN_NETWORK}" -o $this_natdevice -j MASQUERADE

######################

# Start OpenVPN Server
exec /usr/local/sbin/openvpn --config /etc/openvpn/server.conf


#Variables to extract from Dockerfile / Config CONFIGFILES
#${OVPN_NETWORK}
#${}
