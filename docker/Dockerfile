ARG UBUNTU_VERSION=latest
FROM ubuntu:${UBUNTU_VERSION}

# Define user information
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Disable prompt during packages installation only for the build stage
ARG DEBIAN_FRONTEND=noninteractive

# Delete the default `ubuntu` user from newer Ubuntu docker images
RUN if id -u "ubuntu" >/dev/null 2>&1; then userdel --remove --force ubuntu; fi

# Disable certificate checks
RUN echo "Acquire { https::Verify-Peer false };" > /etc/apt/apt.conf.d/99env-config-do-not-verify-peer.conf

# Add some retries to apt to prevent some "Undetermined Error" behind corporate proxy
RUN echo 'Acquire::Retries 10;' > /etc/apt/apt.conf.d/80-retries

# Install all needed software to be closer to a full ubuntu distro
RUN apt-get update && \
apt-get install -y ubuntu-server sudo wget locales && \
rm -rf /var/lib/apt/lists/*

# Use an UTF-8 locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

# Create the user
RUN groupadd --gid $USER_GID $USERNAME && \
useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
mkdir -p /etc/sudoers.d/ && \
echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME  && \
chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to this new user
USER $USERNAME

# Disable certificate checks (cont'd)
RUN git config --global http.sslVerify "false" && \
echo "check_certificate = off" > /home/$USERNAME/.wgetrc

WORKDIR /home/$USERNAME
