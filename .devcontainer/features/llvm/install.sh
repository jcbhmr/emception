#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y curl ca-certificates jq

if [[ -z $VERSION || $VERSION == latest ]]; then
  curl -fsSLo latest-release.json https://api.github.com/repos/llvm/llvm-project/releases/latest
  version=$(jq -r .tag_name latest-release.json | sed 's/^v//')
else
  version="$VERSION"
fi

wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
./llvm.sh "$version"

rm -rf /var/lib/apt/lists/*
