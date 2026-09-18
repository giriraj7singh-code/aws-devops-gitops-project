#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y \
  ca-certificates \
  curl \
  git \
  unzip \
  openjdk-21-jdk-headless \
  maven \
  docker.io

systemctl enable --now docker

touch /var/log/devops-bootstrap-complete
