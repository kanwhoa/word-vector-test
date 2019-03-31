#!/bin/bash

RUNNER=""
if [ -z "${SPARK_HOME}" ]; then
    RUNNER="$(command -v spark-submit)"
    if [ -z "${RUNNER}" ]; then
      echo "Please set SPARK_HOME"
      exit 1
    fi
    export SPARK_HOME="$(dirname $(dirname ${RUNNER}))"
elif [ -z "$(command -v cygpath)" ]; then
    RUNNER="${SPARK_HOME}/bin/spark-submit"
else 
    RUNNER="$(cygpath -u ${SPARK_HOME})/bin/spark-submit"
fi

# If Hadoop not defined, assume it's in the Spark home
# If Spark complains about local libraries, then check with
# hadoop checknative -a
if [ -z "${HADOOP_HOME}" ]; then
    export HADOOP_HOME="${SPARK_HOME}"
fi
export SPARK_SUBMIT_OPTS="-Djava.library.path=${SPARK_HOME}/lib"

# Cleanup
rm -rf out spark-warehouse

"${RUNNER}" \
  --master 'local[*]' \
  --executor-memory 4G \
  --driver-memory 4G \
  target/word-vector-test-1.0-SNAPSHOT.jar "${@}"
