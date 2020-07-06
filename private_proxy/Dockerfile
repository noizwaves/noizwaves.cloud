FROM ubuntu:latest

# Ensure `ssh` and `ip` commands are available
RUN apt update && apt install -y openssh-server iproute2

WORKDIR "/"
EXPOSE 443
ENTRYPOINT "/entrypoint.sh"