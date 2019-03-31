#!/bin/bash

# FIXME
export HADOOP_HOME=/usr/local/Cellar/apache-spark/2.4.0/libexec
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"
# Check with
#./hadoop checknative -a

RUNNER=""
if [ "x${SPARK_HOME}" = "x" ]; then
    RUNNER="$(which spark-submit)"
    if [ "x${RUNNER}" = "x" ]; then
      echo "set SPARK_HOME"
      exit 1
    fi
elif [ "x$(command -v cygpath)" = "x" ]; then
    RUNNER="$SPARK_HOME/bin/spark-submit"
else 
    RUNNER="$(cygpath -u $SPARK_HOME)/bin/spark-submit"
fi

# Cleanup
rm -rf out spark-warehouse

"${RUNNER}" \
  --master 'local[*]' \
  --executor-memory 4G \
  --driver-memory 4G \
  target/word-vector-test-1.0-SNAPSHOT.jar "${@}"
