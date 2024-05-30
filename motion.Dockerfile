FROM alpine:3.19

ARG SG_API_KEY="unknown"
ARG FROM_EMAIL="unknown"
ARG TO_EMAIL="unknown"
ARG MOTION_CONF_FILE="motion-full.conf"
ARG IR_CAM_URL="unknown"
ARG IR_CAM_USER="unknown"
ARG IR_CAM_PASS="unknown"
ARG EMAIL_SCRIPT="send-email-smtp.py"
ARG EMAIL_PASSWORD="unknown"

ARG MOTION_PRIVKEY
ARG SERVER_PUBKEY
ARG SERVER_URL
ARG MOTION_WG_IP

ENV SG_API_KEY=${SG_API_KEY}
ENV FROM_EMAIL=${FROM_EMAIL}
ENV TO_EMAIL=${TO_EMAIL}
ENV IR_CAM_URL=$IR_CAM_URL
ENV IR_CAM_USER=$IR_CAM_USER
ENV IR_CAM_PASS=$IR_CAM_PASS

ENV MOTION_PRIVKEY=$MOTION_PRIVKEY
ENV SERVER_PUBKEY=$SERVER_PUBKEY
ENV SERVER_URL=$SERVER_URL
ENV MOTION_WG_IP=$MOTION_WG_IP
ENV EMAIL_SCRIPT=$EMAIL_SCRIPT
ENV EMAIL_PASSWORD=$EMAIL_PASSWORD

# enable testing repository, which we need for motion
RUN echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk add --update motion@testing ffmpeg python3 py-pip gettext-envsubst wireguard-tools-wg wireguard-tools-wg-quick

WORKDIR /tmp

COPY send-email.py /usr/sbin/
COPY send-email-smtp.py /usr/sbin/
RUN chmod +x /usr/sbin/send-email.py && chmod +x /usr/sbin/send-email-smtp.py
COPY requirements.txt /tmp/

RUN pip3 install --break-system-packages -r requirements.txt

COPY motion-conf /etc/motion/template

ENV MOTION_CONF_FILE=$MOTION_CONF_FILE

RUN cd /etc/motion/template && for file in `ls`; do echo "Subbed $file:"; envsubst < $file | tee ../$file; done

RUN mv /etc/motion/$MOTION_CONF_FILE /etc/motion/motion.conf

COPY entrypoint.sh /bin/entrypoint.sh 

COPY wgconf/motion-full.conf /etc/wireguard/wg0.conf.template

RUN envsubst < /etc/wireguard/wg0.conf.template > /etc/wireguard/wg0.conf


ENTRYPOINT ["/bin/sh","-c", "/bin/entrypoint.sh"]
