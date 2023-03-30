#!/bin/bash
PROJECT_NAME=$(basename "$PWD")
JAR_FILE=$(find ./target/ -maxdepth 1 -name "$PROJECT_NAME-*.jar")
MVN_CLASSPATH_GRAPH=$(mvn dependency:build-classpath)
MVN_CLASSPATH_GRAPH=${MVN_CLASSPATH_GRAPH#*classpath:}
MVN_CLASSPATH="${MVN_CLASSPATH_GRAPH%jar*}jar"

# Configuration
CONF_JAVA_VERSION=17
CONF_JDEPS_COMMAND=$(jdeps -recursive -summary --multi-release $CONF_JAVA_VERSION --class-path "$MVN_CLASSPATH" "$JAR_FILE")
CONF_CUSTOM_JRE_OUT_FOLDER="custom-jre"
#

if test -f "$JAR_FILE"; then
  MODULE_DEPS=()
  while IFS= read -r DEP; do
    RAW_DEP=$(echo "${DEP#*->}" | awk '{$1=$1};1')
    if [ "${RAW_DEP%.*}" == "java" ] || [ "${RAW_DEP%.*}" == "jdk" ]; then
      MODULE_DEPS+=("$RAW_DEP")
    fi
  done <<< "$CONF_JDEPS_COMMAND"

  readarray -t DEPENDENCIES < <(printf '%s\n' "${MODULE_DEPS[@]}" | awk '!x[$0]++')

  # Unresolvable Necessary Runtime Components (Spring)
  DEPENDENCIES+=("jdk.management.agent") # (JMX Agent. Required by Spring but possible to remove for other frameworks.)
  DEPENDENCIES+=("java.security.jgss") # (GSS Handler. Required by Spring Web/Security but possible to remove in other circumstances.)
  #

  # " (Quarkus)
  # DEPENDENCIES+=("jdk.zipfs") # (Jar/Zip Filesystem Handler. Required by Quarkus but possible to remove for other frameworks.)
  #

  MODULES_INSERT=$(printf ",%s" "${DEPENDENCIES[@]}")
  MODULES_INSERT=${MODULES_INSERT:1}

  if [ -d "./$CONF_CUSTOM_JRE_OUT_FOLDER" ]; then
    rm -rf "./$CONF_CUSTOM_JRE_OUT_FOLDER"
  fi
  echo "Required Dependencies: $MODULES_INSERT"

  jlink --compress=2 --strip-debug --no-header-files --no-man-pages --add-modules "$MODULES_INSERT" --output $CONF_CUSTOM_JRE_OUT_FOLDER
else
  echo "Please build to target folder using JDK$CONF_JAVA_VERSION before running script."
fi
