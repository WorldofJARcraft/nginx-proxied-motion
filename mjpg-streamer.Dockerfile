FROM bitnami/minideb:bullseye as builder


RUN apt-get update && apt-get install -y build-essential git cmake libjpeg-dev libv4l-dev

WORKDIR /build

RUN git clone --depth 1 https://github.com/jacksonliam/mjpg-streamer.git
RUN cd mjpg-streamer/mjpg-streamer-experimental && make && make install

# discard all build packets
FROM bitnami/minideb:bullseye as runner

ARG MJPG_STREAMER_INPUT_PLUGIN="input_raspicam"
ENV MJPG_STREAMER_INPUT_PLUGIN=${MJPG_STREAMER_INPUT_PLUGIN}

# runtime libraries only
RUN apt-get update && apt-get install -y libjpeg-dev libv4l-dev
COPY --from=builder /build /build

ENV LD_LIBRARY_PATH=.

WORKDIR /build
ENTRYPOINT ["./mjpg_streamer", "-i", "${MJPG_STREAMER_INPUT_PLUGIN}.so", "-o", "output_http.so", "-w","./www"]