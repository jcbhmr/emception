#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive
apt-get update >/dev/null
apt-get install -y curl ca-certificates jq >/dev/null

if [[ -z $VERSION || $VERSION == latest ]]; then
  echo "🟪 Fetching latest CMake release..."
  curl -fsSLo latest-release.json https://api.github.com/repos/Kitware/CMake/releases/latest
  version=$(jq -r .tag_name latest-release.json | sed 's/^v//')
  echo "🟦 Using latest CMake release: v$version"
else
  version="$VERSION"
  echo "🟦 Using CMake release: v$version"
fi

echo "🟪 Installing CMake v$version..."
curl -fsSLo cmake.sh "https://github.com/Kitware/CMake/releases/download/v$version/cmake-$version-linux-x86_64.sh"
chmod +x cmake.sh
./cmake.sh --skip-license --prefix=/usr/local
echo "🟩 Installed CMake v$version"

if [[ $INSTALLNINJA == true ]]; then
  echo "🟪 Installing Ninja..."
  apt-get install -y ninja-build
  echo "🟩 Installed Ninja"
fi

if [[ $INSTALLBUILDESSENTIAL == true ]]; then
  echo "🟪 Installing Make..."
  apt-get install -y build-essential
  echo "🟩 Installed Make"
fi

rm -rf /var/lib/apt/lists/*
