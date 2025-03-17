#!/bin/bash

if [[ "$HOSTNAME" == "spark-master" ]]; then
    # Start Spark Master
    $SPARK_HOME/sbin/start-master.sh -h 0.0.0.0
else
    # Start Spark Worker
    $SPARK_HOME/sbin/start-worker.sh spark://spark-master:7077
fi

# Keep container running
tail -f /dev/null
