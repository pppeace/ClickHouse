#!/bin/bash

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../../

### BUILD DIGESTS ###
# Source files hash:
SOURCE_DIGEST=$(find $DIR/src $DIR/contrib/*-cmake $DIR/cmake $DIR/base $DIR/programs $DIR/packages  -type f  | grep -vE '*.md$' | xargs md5sum | awk '{ print $1 }' | sort | md5sum | awk '{ print $1 }')
echo "SOURCE_DIGEST=${SOURCE_DIGEST}"
# Modules hash:
#   git submodule status cmd works regardeles wether modules are cloned or not, drop possible +/- sign as it shows the status (cloned/ not cloned/ changed files) and may vary
MODULES_DIGEST=$(cd $DIR; git submodule status | awk '{ print $1 }' | sed 's/^[ +-]//' | md5sum | awk '{ print $1 }')
echo "MODULES_DIGEST=${MODULES_DIGEST}"


### TESTS DIGESTS ###
STATELESS_TEST_SRC_DIGEST=$(find $DIR/tests/queries/0_stateless/ -type f | grep -vE '*.md$' | xargs md5sum | awk '{ print $1 }' | sort | md5sum | awk '{ print $1 }')
STATEFUL_TEST_SRC_DIGEST=$(find $DIR/tests/queries/1_stateful/ -type f | grep -vE '*.md$' | xargs md5sum | awk '{ print $1 }' | sort | md5sum | awk '{ print $1 }')
STATELESS_TEST_DOCKER_DIGEST=$(find $DIR/docker/test/stateless $DIR/docker/test/base -type f | grep -vE '*.md$' | xargs md5sum | awk '{ print $1 }' | sort | md5sum | awk '{ print $1 }')
STATEFUL_TEST_DOCKER_DIGEST=$(find $DIR/docker/test/stateful $DIR/docker/test/stateless $DIR/docker/test/base -type f | grep -vE '*.md$' | xargs md5sum | awk '{ print $1 }' | sort | md5sum | awk '{ print $1 }')

STATELESS_TESTS_DIGEST=$(echo $STATELESS_TEST_SRC_DIGEST-$STATELESS_TEST_DOCKER_DIGEST | md5sum | awk '{ print $1 }')
STATEFUL_TESTS_DIGEST=$(echo $STATEFUL_TEST_SRC_DIGEST-$STATEFUL_TEST_DOCKER_DIGEST | md5sum | awk '{ print $1 }')
echo STATELESS_TESTS_DIGEST=$STATELESS_TESTS_DIGEST
echo STATEFUL_TESTS_DIGEST=$STATEFUL_TESTS_DIGEST


### DOCKER DIGESTS ###
# common docker code digest
DOCKER_JOB_DIGEST=$(find $DIR/docker/ -type f | grep -vE '*.md$' | xargs md5sum | awk '{ print $1 }' | sort | md5sum | awk '{ print $1 }' | cut -c 1-8)
echo "DOCKER_JOB_DIGEST=${DOCKER_JOB_DIGEST}"
export DOCKER_JOB_DIGEST=$DOCKER_JOB_DIGEST
# clickhouse/test-util
DOCKER_TEST_UTIL_DIGEST=$(find $DIR/docker/test/util -type f | grep -vE '*.md$' | xargs md5sum | awk '{ print $1 }' | sort | md5sum | awk '{ print $1 }' | cut -c 1-8)
echo "DOCKER_TEST_UTIL_DIGEST=${DOCKER_TEST_UTIL_DIGEST}"
export DOCKER_TEST_UTIL_DIGEST=$DOCKER_TEST_UTIL_DIGEST
# clickhouse/test-base
DOCKER_TEST_BASE_DIGEST=$(find $DIR/docker/test/base -type f | grep -vE '*.md$' | xargs md5sum | awk '{ print $1 }' | sort | md5sum | awk '{ print $1 }' | cut -c 1-8)
echo "DOCKER_TEST_BASE_DIGEST=${DOCKER_TEST_BASE_DIGEST}"
export DOCKER_TEST_BASE_DIGEST=$DOCKER_TEST_BASE_DIGEST
# clickhouse/binary-builder
DOCKER_BUILDER_DIGEST=$(find $DIR/docker/packager/ $DIR/docker/test/util $DIR/docker/test/base -type f | grep -vE '*.md$' | xargs md5sum | awk '{ print $1 }' | sort | md5sum | awk '{ print $1 }') # | cut -c 1-8
echo "DOCKER_BUILDER_DIGEST=${DOCKER_BUILDER_DIGEST}"
export DOCKER_BUILDER_DIGEST=$DOCKER_BUILDER_DIGEST


### sanity check
[ -z $SOURCE_DIGEST ] || [ -z $MODULES_DIGEST ] || [ -z $DOCKER_BUILDER_DIGEST ] || [ -z $DOCKER_JOB_DIGEST ] && echo "ERROR" && exit 1

### FINAL BUILD DIGEST
BUILD_DIGEST=$(echo $SOURCE_DIGEST-$MODULES_DIGEST-$DOCKER_BUILDER_DIGEST | md5sum | awk '{ print $1 }')
echo "BUILD_DIGEST=${BUILD_DIGEST}"
export BUILD_DIGEST=$BUILD_DIGEST
