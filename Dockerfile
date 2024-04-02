# Use Ubuntu 18.04 LTS as our base image.
FROM ubuntu:18.04

# The Rust toolchain to use when building our image.
ARG TOOLCHAIN=stable

# Install basic deps.
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        cmake \
        curl \
        git \
        libssl-dev \
        libgtest-dev \
        pkgconf \
        sudo \
        && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    useradd rust --user-group --create-home --shell /bin/bash --groups sudo

# Allow sudo without a password.
ADD sudoers /etc/sudoers.d/nopasswd

# Run all further code as user `rust`, and create our working directories
# as the appropriate user.
USER rust
RUN mkdir -p /home/rust/libs /home/rust/src

# Setup binary paths.
ENV PATH=/home/rust/.cargo/bin:/home/rust/binaryen:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Silence rustup and install our Rust toolchain with `wasm` target.
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- -y --default-toolchain $TOOLCHAIN && \
    rustup target add x86_64-unknown-linux-gnu && \
    rustup target add wasm32-unknown-unknown

# Add cargo-generate and wasm-pack.
RUN cargo install cargo-generate
RUN cargo install wasm-pack

# Patch the default `--target` to `wasm` so that our users
# don't need to keep overriding it manually.
ADD cargo-config.toml /home/rust/.cargo/config.toml

# Install and setup paths for binaryen.
RUN echo "Fetching binaryen" && \
    cd /tmp && \
    BINARYEN_VERSION=version_117 && \
    curl -LO "https://github.com/WebAssembly/binaryen/releases/download/$BINARYEN_VERSION/binaryen-$BINARYEN_VERSION-x86_64-linux.tar.gz" && \
    tar xzf "binaryen-$BINARYEN_VERSION-x86_64-linux.tar.gz" && ls -l && cd "binaryen-$BINARYEN_VERSION" && \
    mv bin ~/binaryen

# Expect our source code to live in /home/rust/src. We'll run the build as
# user `rust`, which will be uid 1000, gid 1000 outside the container.
WORKDIR /home/rust/src
