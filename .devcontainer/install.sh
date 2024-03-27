#!/bin/bash

sudo apt-get update
sudo apt-get -y install wget inotify-tools

# ARCH=$(uname -m)

# if [ "$ARCH" = "x86_64" ]; then
#     curl --proto '=https' --tlsv1.2 -fOL https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.96.0/otelcol-contrib_0.96.0_linux_amd64.tar.gz
#     tar -xvf otelcol-contrib_0.96.0_linux_amd64.tar.gz
# elif [ "$ARCH" = "aarch64" ]; then
#     curl --proto '=https' --tlsv1.2 -fOL https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.96.0/otelcol-contrib_0.96.0_linux_arm64.tar.gz
#     tar -xvf otelcol-contrib_0.96.0_linux_arm64.tar.gz
# else
#     echo "Unsupported architecture: $ARCH"
#     exit 1
# fi

if [ ! -f ./otelcol-contrib ]; then
    git clone https://github.com/open-telemetry/opentelemetry-collector-contrib.git
    cd opentelemetry-collector-contrib
    make install-tools && make otelcontribcol
    cp ./bin/otelcontribcol* ../otelcol-contrib
    cd .. && rm -rf opentelemetry-collector-contrib
fi
./otelcol-contrib --config .devcontainer/config.yaml &

go install github.com/open-telemetry/opentelemetry-collector-contrib/cmd/telemetrygen@latest
echo yes | mix archive.install github hexpm/hex branch latest