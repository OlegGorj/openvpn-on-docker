FROM alpine:latest

# Testing: pamtester
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator pamtester libintl inotify-tools && \
    apk --update add sudo dpkg &&  \
    apk add --virtual temppkg gettext &&  \
    apk del temppkg && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Installing OpenVPN AS
#RUN echo "$(date "+%a %b %d %H:%M:%S %Y") Deploying and running 'OpenVPN AS'" && \
#    wget http://swupdate.openvpn.org/as/openvpn-as-2.5.2-Ubuntu16.amd_64.deb  && \
#    sudo dpkg -i openvpn-as-2.5.2-Ubuntu16.amd_64.deb

# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV EASYRSA /usr/share/easy-rsa
ENV EASYRSA_PKI $OPENVPN/pki
ENV EASYRSA_VARS_FILE $OPENVPN/vars

# Prevents refused client connection because of an expired CRL
ENV EASYRSA_CRL_DAYS 3650

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/
