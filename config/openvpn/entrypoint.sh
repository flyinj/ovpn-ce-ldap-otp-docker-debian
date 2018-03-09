#!/bin/bash

mkdir -p /var/log/openvpn/
mkdir -p /etc/openvpn/otp/

exec /usr/local/sbin/openvpn --config /etc/openvpn/server.conf
