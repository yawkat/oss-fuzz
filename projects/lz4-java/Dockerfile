# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

FROM gcr.io/oss-fuzz-base/base-builder-jvm

RUN git clone --recurse-submodules https://github.com/yawkat/lz4-java lz4-java
RUN mkdir -p /root/.m2
# Configure --target=7 compatible JDK toolchain.
RUN echo "\
<toolchains>\
  <toolchain>\
    <type>jdk</type>\
    <provides>\
      <version>7</version>\
    </provides>\
    <configuration>\
      <jdkHome>/usr/lib/jvm/java-15-openjdk-amd64/</jdkHome>\
    </configuration>\
  </toolchain>\
</toolchains>" > /root/.m2/toolchains.xml
WORKDIR $SRC/lz4-java
# Runner docker image has a JDK 17. Fix the test classes to use --release 17.
RUN sed -i 's|<release>21</release>|<release>17</release>|g' $SRC/lz4-java/pom.xml
COPY build.sh $SRC/
