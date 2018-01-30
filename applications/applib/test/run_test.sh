#!/bin/bash

# Copyright 2016 Transwarp Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
FAILED=0
EXECUTED=0
THISFOLDER=`dirname $(cd ${0%/*} && echo $PWD/${0##*/})`
JSONNET_CMD="${JSONNET_BIN:-../../bin/jsonnet}"

for JSONNET_FILE in `ls $THISFOLDER/*.jsonnet` ; do
  EXECUTED=$((EXECUTED + 1))
  TEST_OUTPUT="$($JSONNET_CMD "$JSONNET_FILE" 2>&1)"
  TEST_EXIT_CODE="$?"
  if [[ $TEST_EXIT_CODE == 1 ]]; then
    FAILED=$((FAILED + 1))
    echo $TEST_OUTPUT
    echo
  fi
done

if [[ $FAILED -eq 0 ]]; then
  echo  "All $EXECUTED test scripts pass."
  exit 0;
else
  echo  "FAILED: $FAILED / $EXECUTED"
  exit -1;
fi
