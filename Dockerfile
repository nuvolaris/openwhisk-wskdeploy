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

FROM golang:1.15

# Install zip
RUN apt-get -y update && \
    apt-get -y install zip emacs

ENV GOPATH=/

ADD . /src/github.com/nuvolaris/openwhisk-wskdeploy

# All of the Go CLI binaries will be placed under a build folder
RUN rm -rf /src/github.com/nuvolaris/openwhisk-wskdeploy/build
RUN mkdir /src/github.com/nuvolaris/openwhisk-wskdeploy/build

ARG WSKDEPLOY_OS
ARG WSKDEPLOY_ARCH

# Build the Go wsk CLI binaries and compress resultant binaries
RUN chmod +x /src/github.com/nuvolaris/openwhisk-wskdeploy/build.sh
RUN cd /src/github.com/nuvolaris/openwhisk-wskdeploy/ && ./build.sh
