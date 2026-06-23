FROM debian:trixie-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    adb ca-certificates curl \
    python3 python3-numpy python3-pil python3-opencv \
    openssh-client sshpass \
    && rm -rf /var/lib/apt/lists/*
# Build context must be the lava/ directory:
#   docker build -t lava-adb:latest -f lava/docker/Dockerfile lava/
COPY demosaic.py /usr/local/bin/demosaic.py
