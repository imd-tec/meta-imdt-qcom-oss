FROM debian:trixie-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    adb ca-certificates curl \
    python3 python3-numpy python3-pil python3-opencv \
    openssh-client sshpass \
    && rm -rf /var/lib/apt/lists/*
# Build context must be the lava/ directory:
#   docker build -t lava-adb:latest -f lava/docker/Dockerfile lava/
COPY demosaic.py /usr/local/bin/demosaic.py

# Private SSH key matching recipes-core/lava-ssh-keys/files/lava-dut-key.pub,
# authorized (as 'pi', forced through adb-shell-relay.sh) on the harness host
# each board is attached to over USB/adb — see that script for how it relays
# through. ostree-deploy.yaml pushes the OSTree commit archive to the board
# and deploys it, all over ssh. The key is a secret, so it is NOT committed:
# drop the private `lava-dut-key` into the build context (lava/) before
# building this image on the dispatcher.
COPY lava-dut-key /root/.ssh/id_ed25519
RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/id_ed25519
