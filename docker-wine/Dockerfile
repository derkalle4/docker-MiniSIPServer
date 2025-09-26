FROM debian:bookworm-slim

# OS environment
ENV USER=container \
    HOME=/opt/sipserver \
    WINEARCH=win64 \
    WINE_CPU=arm64 \
    WINEPREFIX="/opt/sipserver/.wine" \
    WINEDEBUG=-all \
    XDG_RUNTIME_DIR=/tmp \
    DEBIAN_FRONTEND=noninteractive

# install necessary additional dependencies
RUN apt update \
    && apt install --no-install-recommends -y \
        wget \
        ca-certificates \
        cabextract

# Download and install Hangover
RUN wget -O /tmp/hangover_10.14_debian12_bookworm_arm64.tar https://github.com/AndreRH/hangover/releases/download/hangover-10.14/hangover_10.14_debian12_bookworm_arm64.tar \
    && cd /tmp \
    && tar -xf hangover_10.14_debian12_bookworm_arm64.tar \
    && apt update \
    && apt install -y ./hangover*.deb \
    && rm -rf /tmp/hangover*

# clean all unnecessary things
RUN apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# add user
RUN useradd -m -d /opt/sipserver -s /bin/bash container
USER container
WORKDIR /opt/sipserver

COPY ./run.sh /run.sh
CMD [ "/bin/bash", "/run.sh" ]