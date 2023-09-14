<!--
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
-->

# Using Cloudant Package with `wskdeploy`

The [Cloudant usecase](https://github.com/nuvolaris/openwhisk-wskdeploy/tree/master/tests/src/integration/cloudant) demonstrates how to build an OpenWhisk app to retrieve document updates from cloudant using `wskdeploy`.

OpenWhisk supports [Cloudant package](https://github.com/apache/openwhisk-package-cloudant) which can be used to integrate with Cloudant APIs. For our simple app to display document IDs,  we need:

- [manifest.yaml](https://github.com/nuvolaris/openwhisk-wskdeploy/blob/master/tests/usecases/cloudant/manifest.yaml)
- [Action File](https://github.com/nuvolaris/openwhisk-wskdeploy/blob/master/tests/usecases/cloudant/src/process-change.js)

All you have to do is export following environment variables:

- CLOUDANT_USERNAME
- CLOUDANT_PASSWORD
- CLOUDANT_DATABASE (make sure that this databas exists in your cloudant instance)

These env. variables are used in manifest file for:

```yaml
        dependencies:
            # binding cloudant package named openwhisk-cloudant
            openwhisk-cloudant:
                location: /whisk.system/cloudant
                inputs:
                    username: $CLOUDANT_USERNAME
                    password: $CLOUDANT_PASSWORD
                    host: ${CLOUDANT_USERNAME}.cloudant.com
        triggers:
            # Trigger named "data-inserted-trigger"
            # Creating trigger to fire events when data is inserted into database
            data-inserted-trigger:
                source: openwhisk-cloudant/changes
                inputs:
                    dbname: $CLOUDANT_DATABASE
```

### Step 1: Deploy

Deploy it using `wskdeploy`:

```
wskdeploy -m tests/usecases/cloudant/manifest.yaml
```

### Step 2: Verify

```
$ wsk package get cloudant-sample
$ wsk package get openwhisk-cloudant
$ wsk trigger get data-inserted-trigger
$ wsk rule get log-change-rule
```
### Step 3: Run

Create a new document in your cloudant instance which invokes trigger `data-inserted-trigger`
which in turn invokes `openwhisk-cloudant/changes` trigger followed by `process-change` action:

```
Activation: process-change (cadfc8008e68416b9af6c6d94ec81dd1)
[
    "2017-09-22T21:43:33.498579123Z stdout: The changed document ID is:e97e6e30fe198c25d3a38f50c5e2a9a7"
]

Activation: read (2033d2f25ed34295a36e63a5f1012452)
[
    "2017-09-22T21:43:33.475515191Z stdout: success { _id: 'e97e6e30fe198c25d3a38f50c5e2a9a7',",
    "2017-09-22T21:43:33.475558073Z stdout: _rev: '1-3f58ef522e6ba68731509a5c1b14fedf',",
    "2017-09-22T21:43:33.475564787Z stdout: data: 'creating one more document' }"
]

Activation: process-change-cloudant-sequence (8798e2e739c948e08a76cb920b3a8d65)
[
    "2033d2f25ed34295a36e63a5f1012452",
    "cadfc8008e68416b9af6c6d94ec81dd1"
]

Activation: log-change-rule (5662cb7250364730aceb7a8534ffb91d)
[]

Activation: data-inserted-trigger (adc3ea6b02f64a86a283a836364d46ea)
[]
```
