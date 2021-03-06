# https://hub.docker.com/_/golang
FROM golang:1.11-alpine3.8

MAINTAINER Anuruddha <anuruddhapremalal@gmail.com>

RUN apk update && \
    apk upgrade && \
    apk add git

RUN go get golang.org/x/tools/cmd/goimports
RUN go get github.com/beego/bee
RUN go get honnef.co/go/tools/cmd/staticcheck
RUN apk add --no-cache gcc
RUN apk add --no-cache g++
RUN apk add --no-cache file
RUN apk add --update --no-cache \
        ca-certificates \
        # https://github.com/Masterminds/glide#supported-version-control-systems
        git mercurial subversion bzr \
        openssh \ 
 && update-ca-certificates \
    \
 # Install build dependencies
 && apk add --no-cache --virtual .build-deps \
        curl make \
    \
 # Download and unpack Glide sources
 && curl -L -o /tmp/glide.tar.gz \
          https://github.com/Masterminds/glide/archive/v0.13.1.tar.gz \
 && tar -xzf /tmp/glide.tar.gz -C /tmp \
 && mkdir -p $GOPATH/src/github.com/Masterminds \
 && mv /tmp/glide-* $GOPATH/src/github.com/Masterminds/glide \
 && cd $GOPATH/src/github.com/Masterminds/glide \
    \
 # Build and install Glide executable
 && make install \
    \
 # Install Glide license
 && mkdir -p /usr/local/share/doc/glide \
 && cp LICENSE /usr/local/share/doc/glide/ \
    \
 # Cleanup unnecessary files
 && apk del .build-deps \
 && rm -rf /var/cache/apk/* \
           $GOPATH/src/* \
           /tmp/*

# install pip3 for awscli setup
RUN apk add --no-cache python3 && \
     python3 -m ensurepip && \
     rm -r /usr/lib/python*/ensurepip && \
     pip3 install --upgrade pip setuptools && \
     if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
     if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
     rm -r /root/.cache

# install aws cli
RUN pip3 install awscli --upgrade --user

ENV PATH=$PATH:$GOPATH/bin:~/.local/bin
WORKDIR $GOPATH
