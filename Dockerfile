# Builds OpenVPN and Google Authenticator libpam
FROM debian:stretch

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
      # for openvpn
      file \
      gcc \
      make \
      openssl \
      libssl-dev \
      liblz4-dev \
      libpam0g-dev \
      libnss-ldapd \
      libpam-ldapd \
      libpam-ladp \
      # for google authenticator
      autoconf \
      libtool \
      #for network configuration
#      whatmask \
      iptables \
      net-tools \
      # for sanity
      vim \
      && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV GAUTH_VERSION=1.05
ENV GAUTH_DIST=google-authenticator-libpam-${GAUTH_VERSION}

ADD https://github.com/google/google-authenticator-libpam/archive/${GAUTH_VERSION}.tar.gz /usr/local/src/${GAUTH_DIST}.tgz

RUN cd /usr/local/src/ \
    && tar xzf ${GAUTH_DIST}.tgz \
    && cd ${GAUTH_DIST} \
    && ./bootstrap.sh \
    && ./configure \
    && make \
    && make install

ENV OPENVPN_DIST=openvpn-2.4.5

ADD https://swupdate.openvpn.org/community/releases/${OPENVPN_DIST}.tar.gz /usr/local/src/${OPENVPN_DIST}.tgz

RUN cd /usr/local/src/ \
  && tar xzf ${OPENVPN_DIST}.tgz \
  && cd ${OPENVPN_DIST} \
  && ./configure --enable-iproute2 --disable-lzo \
  && make \
  # works but slows testing: && make check \
  && make install

COPY config/openvpn/pam.conf /etc/pam.d/openvpn
COPY config/openvpn/ldap.conf config/openvpn/server.conf /etc/openvpn/
COPY config/openvpn/crypto/* etc/openvpn/pki/
COPY config/openvpn/entrypoint.sh /usr/local/bin/openvpn-entrypoint
RUN chmod a+x /usr/local/bin/*

EXPOSE 1194/udp

#VOLUME /etc/openvpn

CMD ["/usr/local/bin/openvpn-entrypoint"]
