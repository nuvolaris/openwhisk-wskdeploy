#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set +x
set -e

get_bin_name () {
  local os=$1
  local bin="wskdeploy"

  if [ $os = "windows" ]; then
    bin="${bin}.exe";
  fi

  echo $bin;
};

build_wskdeploy () {
  local os=$1
  local arch=$2
  local bin=$3

  echo "Building for OS '$os' and architecture '$arch'"

  if [ $os = "mac" ]; then
    export GOOS=darwin;
  else
    export GOOS=$os;
  fi

  export GOARCH=$arch

  cd /src/github.com/nuvolaris/openwhisk-wskdeploy
  go build -ldflags "-X main.Version=`date -u '+%Y-%m-%dT%H:%M:%S'`" -v -o build/$os/$arch/$bin main.go;
};

get_compressed_name() {
  local os=$1
  local arch=$2
  local product_name="OpenWhisk_WSKDEPLOY"

  if [ $arch = amd64 ]; then
      comp_name="$product_name-$os";
  elif [ $arch = 386 ]; then
      comp_name="$product_name-$os-32bit";
  else
      comp_name="$product_name-$os-$arch";
  fi

  echo $comp_name;
};

compress_binary() {
    local comp_name=$1
    local bin=$2
    local os=$3
    local arch=$4

    cd build/$os/$arch

    if [ $os = "linux" ]; then
      comp_name="$comp_name.tgz"
      tar -cvzf $comp_name $bin >/dev/null 2>&1;
    else
      comp_name="$comp_name.zip"
      zip $comp_name $bin >/dev/null 2>&1;
    fi

    cd ../../..
    echo $os/$arch/$comp_name;
};

create_wskdeploy_packages() {
  local dirIndex="{\"wskdeploy\":{"

  for platform in $platforms; do
    dirIndex="$dirIndex\"$platform\":{"

    for arch in $archs; do
      bin=$(get_bin_name $platform)
      build_wskdeploy $platform $arch $bin
      comp_name=$(get_compressed_name $platform $arch)
      comp_path=$(compress_binary $comp_name $bin $platform $arch)

      if [ $arch = $default_arch ]; then
          dirIndex="$dirIndex\"default\":{\"path\":\"$comp_path\"},";
      fi

      dirIndex="$dirIndex\"$arch\":{\"path\":\"$comp_path\"},";
    done

    dirIndex="$(echo $dirIndex | rev | cut -c2- | rev)"
    dirIndex="$dirIndex},";
  done

  dirIndex="$(echo $dirIndex | rev | cut -c2- | rev)"
  dirIndex="$dirIndex}}"

  echo $dirIndex > ./build/content.json
};

platforms="$WSKDEPLOY_OS"
archs="$WSKDEPLOY_ARCH";
default_arch="amd64"

create_wskdeploy_packages
