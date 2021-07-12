# Container image for compiling racket source files
FROM debian:buster-slim

ARG RACKET_VERSION=8.1
ARG CFLAGS="-O2 -march=x86-64 -mtune=generic -pipe -fno-plt"

WORKDIR /usr/local/src

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gcc \
        liblz4-dev \
        libffi-dev \
        libglib2.0-0 \
        make \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L "https://download.racket-lang.org/releases/$RACKET_VERSION/installers/racket-minimal-$RACKET_VERSION-src.tgz" | \
        tar -xvzf - && \
    cd racket-$RACKET_VERSION/src && \
    mkdir build && \
    cd build && \
    CFLAGS=$CFLAGS ../configure --prefix=/usr/local --enable-libz --enable-liblz4 \
        --enable-csonly  --enable-strip --disable-docs && \
    make -j$(nproc) && \
    make install && \
    rm -rf /usr/local/src/racket-$RACKET_VERSION

RUN raco pkg install --auto --no-cache -j $(nproc) -D at-exp-lib compiler db-lib threading-lib && \
    raco pkg install --deps force --no-cache -j $(nproc) -D db threading 

CMD ["racket"]
