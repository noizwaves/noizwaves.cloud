FROM ubuntu:latest

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
  && apt-get install --yes isync openssl
#gettext-base for envsubst

RUN addgroup isync --gid 1000 \
  && useradd --uid 1000 --gid 1000 --create-home isync

USER isync
WORKDIR "/home/isync"
