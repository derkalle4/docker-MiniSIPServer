# Docker MiniSIPServer

> [!IMPORTANT]  
> This is an independent, community-driven project that provides Docker containerization for the MiniSIPServer application.

This project is:

- **NOT affiliated with** myvoipapp.com or MiniSIPServer developers
- **Does NOT contain** any MiniSIPServer code, binaries, or licensed content
- **Does NOT redistribute** the MiniSIPServer application
- **Provided as-is** for community convenience

MiniSIPServer is a proprietary application owned by myvoipapp.com. Please refer to their website for licensing terms and official support.

## About This Project

This repository provides Docker images to run [MiniSIPServer](https://www.myvoipapp.com/index.html) in containerized environments. MiniSIPServer is a SIP server application commonly used to connect traditional landline phones via SIP adapters or manage VoIP communications. My use-case is a small home-used SIP server on a raspberry pi and before that on my NAS (hence the two supported versions via docker for easy deployment and backup).

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed on your system
- Basic understanding of Docker concepts

## Available Docker Images

### AMD64 Native Linux Image

**Image:** `ghcr.io/derkalle4/docker-minisipserver:latest`

**Important:** This image automatically downloads and installs MiniSIPServer during first startup. Ensure:
- DNS is properly configured
- myvoipapp.com website is reachable from your Docker host

### ARM64 Wine-based Image

**Image:** `ghcr.io/derkalle4/docker-minisipserver-wine:latest`

**Important:** This image does NOT download MiniSIPServer. You must:
1. Download MiniSIPServer (Windows) manually from myvoipapp.com
2. Install it on a Windows/Wine environment
3. Copy the installed files to your Docker volume

Thanks to the [Hangover project](https://github.com/AndreRH/hangover) for ARM64 Wine support.

## Quick Start

### Step 1: Create Required Directories

```bash
mkdir -p ./minisipserver_files ./minisipserver_config
```

### Step 2: Choose Your Deployment Method

## Using Docker Run

### AMD64 Systems

```bash
docker run -d \
  --name minisipserver \
  -p 5060:5060/udp \
  -p 8080:8080/tcp \
  -p 3478:3478/udp \
  -p 3479:3479/udp \
  -v ./minisipserver_files:/opt/sipserver \
  -v ./minisipserver_config:/root/.minisipserver \
  -e SRV_VERSION=v60 \
  -e SRV_TYPE=u5 \
  ghcr.io/derkalle4/docker-minisipserver:latest
```

### ARM64 Systems

```bash
docker run -d \
  --name minisipserver \
  -p 5060:5060/udp \
  -p 8080:8080/tcp \
  -p 3478:3478/udp \
  -p 3479:3479/udp \
  -v ./minisipserver_files:/opt/sipserver \
  ghcr.io/derkalle4/docker-minisipserver-wine:latest
```

Ensure proper file permissions:
```bash
sudo chown -R 1000:1000 ./minisipserver_files
```

Alternatively use docker volumes instead of local paths and everything will have the correct permissions automatically.

## Using Docker Compose

### AMD64 Systems

Create `docker-compose.yml`:

```yaml
services:
  minisipserver:
    image: ghcr.io/derkalle4/docker-minisipserver:latest
    container_name: minisipserver
    restart: unless-stopped
    environment:
      - SRV_VERSION=v60
      - SRV_TYPE=u5
    ports:
      - "3478:3478/udp"  # STUN
      - "3479:3479/udp"  # Audio
      - "5060:5060/udp"  # SIP
      - "5080:5080/tcp"  # SIP over TCP
      - "8080:8080/tcp"  # Web interface
    volumes:
      - ./minisipserver_files:/opt/sipserver
      - ./minisipserver_config:/root/.minisipserver
```

### ARM64 Systems

Create `docker-compose.yml`:

```yaml
services:
  minisipserver:
    image: ghcr.io/derkalle4/docker-minisipserver-wine:latest
    container_name: minisipserver
    restart: unless-stopped
    ports:
      - "3478:3478/udp"  # STUN
      - "3479:3479/udp"  # Audio
      - "5060:5060/udp"  # SIP
      - "5080:5080/tcp"  # SIP over TCP
      - "8080:8080/tcp"  # Web interface
    volumes:
      - ./minisipserver_files:/opt/sipserver
```

### Start the Service

```bash
docker-compose up -d
```

## Configuration

### Environment Variables (AMD64 only)

| Variable | Description | Example Values |
|----------|-------------|----------------|
| `SRV_VERSION` | MiniSIPServer version | `v60` (default) |
| `SRV_TYPE` | Client limit type | `u5`, `u10`, `u25`, `u50` |

### Port Configuration

| Port | Protocol | Purpose |
|------|----------|---------|
| 3478 | UDP | STUN server |
| 3479 | UDP | Audio streaming |
| 5060 | UDP | SIP signaling |
| 5080 | TCP | SIP over TCP |
| 8080 | TCP | Web interface |
| 10000-100xx | UDP | RTP media (configurable) |

### Accessing the Web Interface

1. Navigate to `http://YOUR_HOST_IP:8080`
2. Find the auto-generated password in the logs:
   ```bash
   docker logs minisipserver
   ```
   Or check the config directory: `./minisipserver_config/`
3. **Important:** Change the default password immediately to prevent it from resetting on container restart

## ARM64 Setup Instructions

### Installing MiniSIPServer Files

1. Download MiniSIPServer from [myvoipapp.com](https://www.myvoipapp.com)
2. Install on a Windows system or Wine environment
3. Copy the installation directory contents to `./minisipserver_files/`
4. Set proper permissions:
   ```bash
   sudo chown -R 1000:1000 ./minisipserver_files
   ```

## Troubleshooting

### Common Issues

**Permission denied errors:**
```bash
sudo chown -R 1000:1000 ./minisipserver_files
```

**Container won't start:**
- Verify internet connectivity
- Check if myvoipapp.com is accessible
- Review container logs: `docker logs minisipserver`

**Web interface inaccessible:**
- Verify port 8080 is not in use
- Check firewall settings
- Ensure container is running: `docker ps`

### Logs and Debugging

View container logs:
```bash
docker logs minisipserver -f
```

Access container shell:
```bash
docker exec -it minisipserver bash
```

## Building from Source

If you prefer to build the images yourself:

1. Clone this repository:
   ```bash
   git clone https://github.com/derkalle4/docker-MiniSIPServer.git
   cd docker-MiniSIPServer
   ```

2. Build for your platform:
   ```bash
   # For AMD64
   cd docker-linux
   docker build -t my-minisipserver .
   
   # For ARM64
   cd docker-wine
   docker build -t my-minisipserver-wine .
   ```

## License and Legal

- **MiniSIPServer:** Proprietary software by myvoipapp.com - see their website for licensing
- **This project:** Open source - see [LICENSE](LICENSE) file for details
- **No warranty:** This project is provided as-is without any warranties

## Acknowledgments

- [myvoipapp.com](https://www.myvoipapp.com) for creating MiniSIPServer
- [Hangover project](https://github.com/AndreRH/hangover) for ARM64 Wine support
- The Docker and open-source community