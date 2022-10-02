FROM alpine:3.16

ARG SG_API_KEY="unknown"
ARG FROM_EMAIL="unknown"
ARG TO_EMAIL="unknown"

ENV SG_API_KEY=${SG_API_KEY}
ENV FROM_EMAIL=${FROM_EMAIL}
ENV TO_EMAIL=${TO_EMAIL}

# enable testing repository, which we need for motion
RUN echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk add --update motion@testing python3 py-pip

WORKDIR /tmp

COPY send-email.py /usr/sbin/
COPY requirements.txt /tmp/

RUN pip3 install -r requirements.txt

ENTRYPOINT [ "motion", "-c", "/etc/motion/motion.conf", "-n" ]