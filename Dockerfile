FROM openjdk:8-jdk

ENV SPARK_VERSION=3.3.1
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/opt/spark
ENV PATH="$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH"

RUN apt-get update && apt-get install -y --no-install-recommends iputils-ping \
    curl wget tar bash procps python3 python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/*

RUN python3 --version
RUN pip3 install pyspark

RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    tar -xvzf spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop3 /opt/spark && \
    rm spark-${SPARK_VERSION}-bin-hadoop3.tgz

RUN cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh && \
    echo 'export SPARK_DAEMON_JAVA_OPTS="-Dlog4j2.disable.jmx=true"' >> $SPARK_HOME/conf/spark-env.sh && \
    echo 'export SPARK_JAVA_OPTS="-Djdk.internal.platform.cgroupv2.enable=false -XX:-UseContainerSupport"' >> $SPARK_HOME/conf/spark-env.sh && \
    echo 'export JAVA_TOOL_OPTIONS="-Djdk.internal.platform.cgroupv2.enable=false"' >> /opt/spark/conf/spark-env.sh


RUN cp $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf && \
    echo 'spark.driver.extraJavaOptions=-Djdk.internal.platform.cgroupv2.enable=false' >> $SPARK_HOME/conf/spark-defaults.conf && \
    echo 'spark.executor.extraJavaOptions=-Djdk.internal.platform.cgroupv2.enable=false' >> $SPARK_HOME/conf/spark-defaults.conf

COPY scripts/start-spark.sh /scripts/start-spark.sh
RUN chmod +x /scripts/start-spark.sh

COPY metrics.properties /opt/spark/conf/metrics.properties

EXPOSE 8080 7077 8081

CMD ["/scripts/start-spark.sh"]