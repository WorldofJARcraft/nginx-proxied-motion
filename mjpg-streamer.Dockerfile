FROM arm32v7/debian:bullseye as builder


RUN apt-get update && apt-get install -y build-essential git cmake libjpeg-dev libv4l-dev

WORKDIR /build

# hack to get raspicam plugin
RUN git clone --depth 1 https://github.com/raspberrypi/firmware.git && cp -r firmware/opt/vc /opt/ && ls -lisa /opt/vc

RUN git clone --depth 1 https://github.com/jacksonliam/mjpg-streamer.git
RUN cd mjpg-streamer/mjpg-streamer-experimental &&  make && make install

# discard all build packets
FROM arm32v7/debian:bullseye as runner

ARG MJPG_STREAMER_INPUT_PLUGIN="input_raspicam"
ARG MJPG_STREAMER_USER="admin"
ARG MJPG_STREAMER_PASS="something_strong!"
ENV MJPG_STREAMER_INPUT_PLUGIN=${MJPG_STREAMER_INPUT_PLUGIN}
ENV MJPG_STREAMER_USER=${MJPG_STREAMER_USER}
ENV MJPG_STREAMER_PASS=${MJPG_STREAMER_PASS}


# runtime libraries only
RUN apt-get update && apt-get install -y libjpeg-dev libv4l-dev
COPY --from=builder /build /build
COPY --from=builder /opt/vc /opt/vc

RUN find /opt/vc -name libmmal_vc_client.so 
#RUN ln -s /build/mjpg-streamer/mjpg-streamer-experimental/${MJPG_STREAMER_INPUT_PLUGIN}.so /usr/lib/${MJPG_STREAMER_INPUT_PLUGIN}.so
#RUN ln -s /build/mjpg-streamer/mjpg-streamer-experimental/output_http.so /usr/lib/output_http.so

WORKDIR /build/mjpg-streamer/mjpg-streamer-experimental

RUN ls -lisa && find . -name '*so'

RUN echo "#!/bin/sh\nexport LD_LIBRARY_PATH=$(pwd):/opt/vc/lib/\n./mjpg_streamer" "-i" "${MJPG_STREAMER_INPUT_PLUGIN}.so" "-o" "\"output_http.so -w . -c ${MJPG_STREAMER_USER}:${MJPG_STREAMER_PASS}\"" > entrypoint.sh && chmod +x entrypoint.sh 

CMD "./entrypoint.sh"
