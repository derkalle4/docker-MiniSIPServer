FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    gcc \
    g++ \
    qtbase5-dev \
    wget \
    ca-certificates

RUN wget https://www.myvoipapp.com/download/mss_v60/amd64/mss_v60_u100_amd64.deb && \
    dpkg --install mss_v60_u100_amd64.deb && \
    rm mss_v60_u100_amd64.deb

RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

EXPOSE 8080/tcp
EXPOSE 5060/udp

CMD ["/usr/local/bin/run.sh"]
