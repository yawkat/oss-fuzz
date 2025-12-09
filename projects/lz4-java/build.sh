#!/bin/bash -eu
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

maven_args="-Dmaven.repo.local=$OUT/.m2 -DskipTests -P fuzz"

# Build the project and its test classes.
./mvnw package $maven_args

deps_class_path=$(./mvnw dependency:build-classpath $maven_args -DincludeScope=test --no-transfer-progress | grep -v "[INFO]")
build_class_path="$JAZZER_API_PATH:$JAZZER_JUNIT_PATH:$deps_class_path:target/test-classes/:target/classes"


cp -r target/classes target/test-classes $OUT/

FUZZ_TESTS=$(java -cp $build_class_path com.code_intelligence.jazzer.Jazzer --list_fuzz_tests=)
for fuzzer in $FUZZ_TESTS; do
  # Split into class and method
  class="${fuzzer%%::*}"
  method="${fuzzer##*::}"
  basename="${class##*.}_${method}"

  # Fix class path for runtime by adjusting $OUT to \$this_dir
  adjusted_deps_class_path=$(echo $deps_class_path | sed "s|$OUT|\$this_dir|g")

  echo "#!/bin/bash
# LLVMFuzzerTestOneInput for fuzzer detection.

this_dir=\$(dirname \"\$0\")
run_class_path=\$this_dir/jazzer_agent_deploy.jar:\$this_dir/jazzer_junit.jar:$adjusted_deps_class_path:\$this_dir/test-classes/:\$this_dir/classes

\$this_dir/jazzer_driver --agent_path=\$this_dir/jazzer_agent_deploy.jar \
--cp=\$run_class_path \
--target_class=$class \
--target_method=$method \
\$@" > $OUT/$basename
  chmod +x $OUT/$basename
done
