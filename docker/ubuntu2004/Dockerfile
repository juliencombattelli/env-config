FROM ubuntu:20.04

# Disable prompt during packages installation only for the build stage
ARG DEBIAN_FRONTEND=noninteractive

# Install all needed software to be closer to a full ubuntu distro
RUN apt-get update && \
apt-get install -y ubuntu-server sudo wget python3-distutils && \
rm -rf /var/lib/apt/lists/*

# Disable certificate checks
RUN echo "Acquire { https::Verify-Peer false }" > /etc/apt/apt.conf.d/99env-config-do-not-verify-peer.conf ; \
echo "check_certificate = off" > ~/.wgetrc

WORKDIR /root
