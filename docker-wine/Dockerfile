FROM debian:bookworm-slim

# OS environment
ENV USER=container \
    HOME=/opt/sipserver \
    WINEARCH=win64 \
    WINEPREFIX="/opt/sipserver/.wine" \
    WINEDEBUG=-all \
    DISPLAY=:99 \
    DISPLAY_WIDTH=1280 \
    DISPLAY_HEIGHT=720 \
    DISPLAY_DEPTH=24 \
    XVFB=1 \
    DEBIAN_FRONTEND=noninteractive

# Combine all RUN commands and clean up in one layer
RUN apt update \
    && apt install --no-install-recommends -y \
        wget binutils iproute2 net-tools \
        gnupg2 apt-transport-https software-properties-common \
        ca-certificates tzdata locales \
    && update-locale lang=en_US.UTF-8 \
    && dpkg-reconfigure --frontend noninteractive locales \
    && useradd -m -d /opt/sipserver -s /bin/bash container \
    # Add i386 architecture and install wine dependencies
    && dpkg --add-architecture i386 \
    && apt update \
    && apt install --no-install-recommends -y \
        xvfb \
    # Install Wine
    && mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources \
    && apt update \
    && apt install --no-install-recommends -y winehq-stable \
    # Clean up everything in one go
    && apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

USER container
WORKDIR /opt/sipserver

COPY ./run.sh /run.sh
CMD [ "/bin/bash", "/run.sh" ]