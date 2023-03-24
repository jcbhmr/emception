#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y curl ca-certificates jq

if [[ -z $VERSION || $VERSION == latest ]]; then
  curl -fsSLo latest-release.json https://api.github.com/repos/Kitware/CMake/releases/latest
  version=$(jq -r .tag_name latest-release.json | sed 's/^v//')
else
  version="$VERSION"
fi

curl -fsSLo cmake.sh "https://github.com/Kitware/CMake/releases/download/v$version/cmake-$version-linux-x86_64.sh"
chmod +x cmake.sh
./cmake.sh --skip-license --prefix=/usr/local

rm -rf /var/lib/apt/lists/*
