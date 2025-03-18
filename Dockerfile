# Stage 1: Build stage for Spark installation
FROM openjdk:8-jdk AS builder

ENV SPARK_VERSION=3.3.1
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/opt/spark
ENV PATH="$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH"

# Install common dependencies in a single layer to optimize caching
RUN apt-get update && apt-get install -y --no-install-recommends \
    iputils-ping \
    curl wget tar bash procps python3 python3-pip unzip && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/*

# Copy the requirements.txt into the container
COPY requirements.txt /tmp/requirements.txt

# Install Python dependencies from requirements.txt
RUN pip3 install -r /tmp/requirements.txt

# Download and install Spark in the builder stage
RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    tar -xvzf spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop3 /opt/spark && \
    rm spark-${SPARK_VERSION}-bin-hadoop3.tgz

# Copy the scripts directory from the build context to the builder stage
COPY scripts/. /scripts/

# Stage 2: Production stage for final image
FROM openjdk:8-jdk

# Set environment variables
ENV SPARK_VERSION=3.3.1
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/opt/spark
ENV PATH="$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH"

# Install only the necessary dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    iputils-ping \
    bash procps python3 python3-pip unzip && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/*

# Copy Spark from the builder stage
COPY --from=builder /opt/spark /opt/spark

# Copy the /scripts directory from the builder stage
COPY --from=builder /scripts /scripts/

# Copy the necessary data
COPY metrics.properties /opt/spark/conf/metrics.properties
COPY data/. /data/

# Copy the requirements.txt file
COPY requirements.txt /tmp/requirements.txt

# Install Python dependencies from requirements.txt in the final image
RUN pip3 install -r /tmp/requirements.txt

# Make scripts executable
RUN find /scripts/ -type f -exec chmod +x {} \;

EXPOSE 8080 7077 8081

CMD ["/scripts/download_data.sh"]