# Use a lightweight base image compatible with Apple M1 chip
FROM openjdk:11-jdk-slim

# Set environment variables
ENV SPARK_VERSION=3.3.1
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/opt/spark
ENV PATH="$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH"

# Install dependencies, including Python 3
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget tar bash procps \
    python3 python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/*

# Verify Python installation (debugging step)
RUN python3 --version

# Install PySpark
RUN pip3 install pyspark

# Download and install Spark
RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    tar -xvzf spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop3 /opt/spark && \
    rm spark-${SPARK_VERSION}-bin-hadoop3.tgz

# Set up Spark environment configuration
RUN cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh && \
    echo 'export SPARK_DAEMON_JAVA_OPTS="-Dlog4j2.disable.jmx=true -Djdk.internal.platform.cgroupv2.enable=false"' >> $SPARK_HOME/conf/spark-env.sh && \
    echo 'export JAVA_TOOL_OPTIONS="-Djdk.internal.platform.cgroupv2.enable=false -XX:-UseContainerSupport"' >> $SPARK_HOME/conf/spark-env.sh && \
    echo 'export JAVA_TOOL_OPTIONS="-Djdk.internal.platform.cgroupv2.enable=false"' >> $SPARK_HOME/conf/spark-env.sh

# Set up Spark defaults configuration
RUN cp $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf && \
    echo 'spark.driver.extraJavaOptions=-Dlog4j2.disable.jmx=true -Djdk.internal.platform.cgroupv2.enable=false' >> $SPARK_HOME/conf/spark-defaults.conf

    # Set up Spark master and worker scripts
COPY start-spark.sh /start-spark.sh
RUN chmod +x /start-spark.sh

# Expose ports for Spark
EXPOSE 8080 7077 8081

# Set entrypoint script
CMD ["/start-spark.sh"]
