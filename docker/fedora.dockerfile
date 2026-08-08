ARG FEDORA_VERSION=latest
FROM fedora:${FEDORA_VERSION}

# Define user information
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ARG EC_FEDORA_ATOMIC=0
ENV EC_FEDORA_ATOMIC=$EC_FEDORA_ATOMIC

# The following packages are preinstalled on Fedora Atomic spins
RUN if [ -n $EC_FEDORA_ATOMIC ]; then dnf install --assumeyes wget git jq curl; fi

# Create the user
RUN groupadd --gid $USER_GID $USERNAME && \
useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
mkdir -p /etc/sudoers.d/ && \
echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME  && \
chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to this new user
USER $USERNAME

WORKDIR /home/$USERNAME
