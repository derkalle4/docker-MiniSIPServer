# MiniSIPServer Dockerized

> [!IMPORTANT]  
> This repository is a private project and is not affiliated with, endorsed by, or in any way officially connected to the company behind MiniSIPServer (myvoipapp.com). It is provided solely for convenience to the community.

This project provides Docker images for running the [MiniSIPServer](https://www.myvoipapp.com/index.html) application. This allows for a simple way to run a SIP server, for instance, to connect traditional landline phones via SIP adapters.

These Docker images are based on the official MiniSIPServer releases and offer different client limit versions.

## Prerequisites

*   [Docker](https://docs.docker.com/get-docker/) must be installed on your system.

## Getting Started: Using Pre-built Docker Images

> [!IMPORTANT]  
> The docker image will download and install the MiniSIPServer application during the first start of the docker container to avoid issues with their license. This repository and the docker images do not contain the application. Make sure DNS is properly configured and the website of myvoipapp.com is reachable!

The easiest way to use MiniSIPServer is by pulling a pre-built image from the GitHub Container Registry (GHCR). The image available will fit all versions of the MiniSIPServer.

`ghcr.io/derkalle4/docker-minisipserver:latest`

### Option 1: Using `docker run`

Choose the image version you need via the environment-variables (e.g., `SRV_TYPE=u5` for 5 clients and run the following command. Make sure to adjust the ports and other stuff to fit your needs:

```sh
docker run --rm \
  -p 5060:5060/udp \
  -p 8080:8080/tcp \
  -v ./minisipserver_files:/opt/sipserver \
  -v ./minisipserver_config:/root/.minisipserver \
  --env SRV_VERSION=v60 \
  --env SRV_TYPE=u5 \
  --name minisipserver \
  ghcr.io/derkalle4/docker-minisipserver:latest
```

This command will:
*   Start a MiniSIPServer container with the 5-client limit.
*   Map port `5060/udp` (standard SIP) and `8080/tcp` (web interface) from the container to your host.
*   Mount a local directory `./minisipserver_files` to `/opt/sipserver` inside the container for persistent server files. Create this directory on your host first if it doesn't exist.
*   Mount a local directory `./minisipserver_config` to `/root/.minisipserver` inside the container for persistent configuration. Create this directory on your host first if it doesn't exist.
*   Sets the wanted version and type of the MiniSIPServer.
*   Name the container `minisipserver`.

### Option 2: Using `docker-compose`

Create a `docker-compose.yml` file with the following content:

```yaml
services:
  minisipserver:
    image: ghcr.io/derkalle4/docker-minisipserver:latest
    container_name: minisipserver
    environment:
      - SRV_VERSION=v60
      - SRV_TYPE=u5
    ports:
      - "3478:3478/udp" # STUN
      - "3479:3479/udp" # Audio
      - "5060:5060/udp" # SIP
      - "8080:8080/tcp" # Web interface
      - "5080:5080/tcp" # Optional: SIP over TCP
      # Add other ports as needed
    volumes:
      - ./minisipserver_files:/opt/sipserver
      - ./minisipserver_config:/root/.minisipserver
    restart: unless-stopped
```

Then, run `docker-compose up -d` in the same directory as your `docker-compose.yml` file.
Make sure the `./minisipserver_files` and `./minisipserver_config` directory exists on your host.

### Access the Webinterface

After the first start a random webinterface password will be created. This will reset every time you restart the docker container if you do not enter a custom one in the webinterface! So make sure to change it once you logged in. You will find the password in the log-file inside the *log* folder.

Access the web interface at `http://<your-docker-host-ip>:8080`.

## Configuration

### Ports

MiniSIPServer uses several ports:

*   `3478/udp` (STUN)
*   `3479/udp` (Audio)
*   `5060/udp` (SIP)
*   `5080/tcp` (SIP over TCP)
*   `8080/tcp` (Webinterface)
*   `10000-100xx/udp` (RTP media range, configurable in MiniSIPServer)

Adjust port mappings based on your needs and MiniSIPServer configuration.

## Building Images Manually (Advanced)

If you prefer to build the images yourself:

1.  Clone this repository.
2.  Navigate to the docker directory, e.g., `cd ./docker/`.
3.  Build the image:
    ```sh
    docker build -t my-minisipserver.
    ```
    You can then use `my-minisipserver` (or your chosen tag) in your `docker run` or `docker-compose` commands.

## License

The MiniSIPServer software is provided by [myvoipapp.com](https://www.myvoipapp.com). Please refer to their website for licensing details of the MiniSIPServer application.
The scripts and Dockerfiles in this repository are provided under the [LICENSE](LICENSE) file in this repository.

## Acknowledgements

Thanks to [myvoipapp.com](https://www.myvoipapp.com) for providing MiniSIPServer, especially the free version for small use cases.
