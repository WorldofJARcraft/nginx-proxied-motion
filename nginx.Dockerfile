FROM alpine:3.20

ARG SERVER_PRIVKEY
ARG MOTION_FULL_PUBKEY
ARG MOTION_LIGHT_PUBKEY

ENV SERVER_PRIVKEY=$SERVER_PRIVKEY
ENV MOTION_FULL_PUBKEY=$MOTION_FULL_PUBKEY
ENV MOTION_LIGHT_PUBKEY=$MOTION_LIGHT_PUBKEY

RUN apk add nginx wireguard-tools-wg-quick gettext-envsubst iptables

COPY entrypoint-nginx.sh /bin/

COPY wgconf/server.conf /etc/wireguard/wg0.conf.template

RUN envsubst < /etc/wireguard/wg0.conf.template > /etc/wireguard/wg0.conf

CMD ["sh", "-c", "/bin/entrypoint-nginx.sh"]
