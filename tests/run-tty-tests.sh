#!/bin/bash
# Copyright 2016 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

DRONE_BUILD_NUM=${DRONE_BUILD_NUM:=0}
unit_test_array=($TEST_URL_ARRAY)
arrLen=${#unit_test_array[@]}
TEST_URL=${unit_test_array[$(($DRONE_BUILD_NUM % $arrLen))]}

function cleanup {
    echo "Cleaning up VCH-$DRONE_BUILD_NUM-TTY..."
    out="$(bin/vic-machine-linux delete --target $TEST_URL --user $TEST_USERNAME --password $TEST_PASSWORD --name VCH-$DRONE_BUILD_NUM-TTY --force)"
}

echo "Installing VCH-$DRONE_BUILD_NUM-TTY..."
out="$(bin/vic-machine-linux create --target $TEST_URL --user $TEST_USERNAME --password $TEST_PASSWORD --no-tls --name VCH-$DRONE_BUILD_NUM-TTY --force | grep 'docker -H')"
outarray=($out)
params=(${outarray[3]})

#TEST - docker run -it date
echo "Running docker run -it date test..."
out="$(docker -H $params run -it busybox /bin/date)"
if [[ $out != *"UTC"* ]]; then
  echo "docker run -it date test failed!";
  cleanup;
  exit 1;
fi

#TEST - docker run -it df
echo "Running docker run -it df test..."
out="$(docker -H $params run -it busybox /bin/df)"
if [[ $out != *"Filesystem"* ]]; then
  echo "docker run -it df test failed!";
  cleanup;
  exit 1;
fi

#TEST - docker run -it command that doesn't stop
echo "Running docker run -it command that doesn't stop test..."
out="$(docker -H $params run -itd busybox /bin/top)"
out="$(docker -H $params logs $out)"
if [[ $out != *"Load average:"* ]]; then
  echo "docker run -it command that doesn't stop test failed!";
  cleanup;
  exit 1;
fi

cleanup
echo "Run tty tests have passed!"
