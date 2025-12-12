#!/usr/bin/env bash
set -eEuo pipefail

# System deps for: build tools + runtime libs for build_grammar + apt-file for diagnostics.
sudo apt update
sudo apt install -y \
  ca-certificates curl git \
  build-essential cmake \
  python3 python3-venv python3-pip \
  file ldd \
  software-properties-common

# Enable Universe (librime1 is commonly in Universe on Ubuntu)
sudo add-apt-repository -y universe || true
sudo apt update

# Rime core runtime library (fixes: librime.so.1 => not found)
sudo apt install -y librime1

# Tool to map missing .so -> package name
sudo apt install -y apt-file
sudo apt-file update
