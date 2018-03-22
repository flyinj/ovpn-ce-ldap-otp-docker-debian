#!/bin/bash

# Create openvpn log and otp directories
mkdir -p /var/log/openvpn/
mkdir -p /etc/openvpn/otp/
mkdir -p /lib/security/ && ln -s /usr/local/lib/security/pam_google_authenticator.so /lib/security/pam_google_authenticator.so

#######################
####SETUP NETWORKING###
######################
# Create VPN tunnel interface
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
 mknod /dev/net/tun c 10 200
fi

#no routes are set: redirect all traffic from the client over the tunnel.
ovpn_net_addr=`sipcalc ${OVPN_NETWORK} | grep 'Network address' | awk '{ print $4 }'`
ovpn_net_mask=`sipcalc ${OVPN_NETWORK} | grep 'Network Mask' | awk '{ print $4 }'`
ovpn_net="${ovpn_net_addr} ${ovpn_net_mask}" #not used - should be used to setup  address ovp server conf

# NAT mode by default
export this_natdevice=`route | grep '^default' | grep -o '[^ ]*$'`
iptables -t nat -A POSTROUTING -s ${OVPN_NETWORK} -o $this_natdevice -j MASQUERADE

######################

# Start OpenVPN Server
exec /usr/local/sbin/openvpn --config /etc/openvpn/server.conf

#Variables to extract from Dockerfile / Config CONFIGFILES
#OVPN_NETWORK : CIDR format : 10.10.50.0/24 for example -> May need to change that with whatmask as OVPN_NETWORK also used in server.conf with another format
#OVPN_PROTOCOL? --maybe
#OVPN_PORT
#LDAP_URI
#LDAP_BASE_DN
#LDAP_BIND_USER_DN
#LDAP_BIND_USER_PASS
#LDAP_FILTER
#OVPN_DNS_SERVERS?
#OVPN_DNS_SEARCH_DOMAIN?
