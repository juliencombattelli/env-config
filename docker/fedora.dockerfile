ARG FEDORA_VERSION=latest
FROM fedora:${FEDORA_VERSION}

# Define user information
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Disable prompt during packages installation only for the build stage
# ARG DEBIAN_FRONTEND=noninteractive

# Delete the default `ubuntu` user from newer Ubuntu docker images
# RUN if id -u "ubuntu" >/dev/null 2>&1; then userdel --remove --force ubuntu; fi

# Create the user
RUN groupadd --gid $USER_GID $USERNAME && \
useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
mkdir -p /etc/sudoers.d/ && \
echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME  && \
chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to this new user
USER $USERNAME

WORKDIR /home/$USERNAME
