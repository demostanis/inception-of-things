#!/bin/sh

project=$PWD

# whys this even the repo name...
dir=$(mktemp -d)
cd "$dir"
trap 'rm -rf "$dir"' EXIT

export GLAB_CONFIG_DIR="$dir"
cp "$project"/glab-config.yml "$GLAB_CONFIG_DIR"/config.yml
pat=$(cd "$project"; bash ./gitlab-pat.sh)
sed 's/REPLACE/'$pat'/g' -i "$GLAB_CONFIG_DIR"/config.yml

git clone https://github.com/demostanis/amassias-iot repo
cd repo
glab repo delete -y repo && sleep 2
glab repo create --public
git remote set-url origin https://root:$pat@gitlab.demolinux.local/root/repo.git
git -c http.sslVerify=false push
