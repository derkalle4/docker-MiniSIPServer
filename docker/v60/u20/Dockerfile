FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
    procps

RUN apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

EXPOSE 8080/tcp
EXPOSE 5060/udp

CMD ["/usr/local/bin/run.sh"]
