FROM ubuntu:latest

# Set the working directory
WORKDIR /home/lf/zh

# Set noninteractive mode
ENV DEBIAN_FRONTEND=noninteractive

# Update, upgrade, and install required packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        git \
        cmake \
        ninja-build \
        gperf \
        ccache \
        dfu-util \
        device-tree-compiler \
        wget \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python3-tk \
        python3-wheel \
        xz-utils \
        file \
        make \
        gcc \
        gcc-multilib \
        g++-multilib \
        libsdl2-dev \
        libmagic1 \
        python3-venv \
        tzdata

# Select the Indian timezone
RUN ln -fs /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Install west
RUN pip3 install west

# Initialize and update west
RUN west init ~/zephyrproject && \
    cd ~/zephyrproject && \
    west update

# Export Zephyr
RUN west zephyr-export

# Install requirements
RUN pip3 install -r ~/zephyrproject/zephyr/scripts/requirements.txt

# Download and install Zephyr SDK
RUN cd ~ && \
    wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.5/zephyr-sdk-0.16.5_linux-x86_64.tar.xz && \
    wget -O - https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.5/sha256.sum | shasum --check --ignore-missing && \
    tar xvf zephyr-sdk-0.16.5_linux-x86_64.tar.xz && \
    cd zephyr-sdk-0.16.5 && \
    ./setup.sh

# Copy and reload udev rules for openocd
RUN cp ~/zephyr-sdk-0.16.5/sysroots/x86_64-pokysdk-linux/usr/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d && \
    udevadm control --reload
