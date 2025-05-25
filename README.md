# MiniSIPServer Dockerized

This project provides a Docker image for running the [MiniSIPServer](https://www.myvoipapp.com) application. I needed a simple way to run a SIP-Server in my home for a land line (which is only doable via a SIP connection nowadays). I really like having "old" land line phones connected and have some adapters for SIP to analog which I wanted to put into use.

This docker image per default builds the 5 client version which is totally suitable for a private home and manageable via webinterface. Thanks for providing this simple software for free for small use cases and including a webinterface!

## Building the Docker Image

To build the Docker image, navigate to the project directory and run the following command:

```
docker build -t minisipserver .
```

## Running the Docker Image

Either use the command line:
```
docker run --rm -p 5060:5060/udp -p 5080:5080/tcp -p 6060:6060/tcp -p 8080:8080/tcp -v ./config:/root/.minisipserver minisipserver
```

Or use the docker compose file

```
services:
  minisipserver:
    image: minisipserver
    container_name: minisipserver
    ports:
      - "5060:5060/udp"
      - "5080:5080/tcp"
      - "6060:6060/tcp"
      - "8080:8080/tcp"
    volumes:
      - ./config:/root/.minisipserver
    restart: always
```

This will execute the minisipserver application and map the necessary ports.
