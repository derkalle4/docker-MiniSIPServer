# MiniSIPServer Dockerized

This project provides a Docker image for running the [MiniSIPServer](https://www.myvoipapp.com) application. I needed a simple way to run a SIP-Server in my home for a land line (which is only doable via a SIP connection nowadays). I really like having "old" land line phones connected and have some adapters for SIP to analog which I wanted to put into use.

This docker image per default builds the 5 client version which is totally suitable for a private home and manageable via webinterface. Thanks for providing this simple software for free for small use cases and including a webinterface!

## Building the Docker Image

To build the Docker image, navigate to the project directory and run the following command:

```
docker build -t minisipserver .
```

After building the image, you can run the container using the following command:

```
docker run --rm -p 8080:8080/tcp -p 5060:5060/udp -v ./config:/root/.minisipserver minisipserver
```

This will execute the minisipserver application and map the necessary ports.
