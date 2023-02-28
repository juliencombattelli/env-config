FROM ubuntu:18.04

# Define user information
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Disable prompt during packages installation only for the build stage
ARG DEBIAN_FRONTEND=noninteractive

# Disable certificate checks
RUN echo "Acquire { https::Verify-Peer false };" > /etc/apt/apt.conf.d/99env-config-do-not-verify-peer.conf ; \
echo "check_certificate = off" > ~/.wgetrc

# Add some retries to apt to prevent some "Undetermined Error" behind corporate proxy
RUN echo 'Acquire::Retries 10;' > /etc/apt/apt.conf.d/80-retries

# Install all needed software to be closer to a full ubuntu distro
RUN apt-get update && \
apt-get install -y ubuntu-server sudo wget python3-distutils locales && \
rm -rf /var/lib/apt/lists/*

# Use an UTF-8 locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

# Create the user
RUN groupadd --gid $USER_GID $USERNAME && \
useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME  && \
chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME
