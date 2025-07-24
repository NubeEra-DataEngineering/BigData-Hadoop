# Use an official  base image
FROM :3.8-slim

# Set environment variables
ENV PYSPARK_VERSION=3.3.0
ENV HADOOP_VERSION=3.2
ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$PATH

# Install dependencies
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk wget curl  && \
    apt-get clean

# Install Apache Spark
RUN wget -q "https://apache.mirror.digitalpacific.com.au/spark/spark-$PYSPARK_VERSION/spark-$PYSPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz" -O /tmp/spark.tgz && \
    tar xvf /tmp/spark.tgz -C /opt && \
    mv /opt/spark-$PYSPARK_VERSION-bin-hadoop$HADOOP_VERSION /opt/spark && \
    rm -rf /tmp/spark.tgz

# Install  dependencies
RUN pip install --no-cache-dir pyspark

# Set default working directory
WORKDIR /workspace

# Expose default Spark ports
EXPOSE 7077 8080 4040

# Default command to run Spark in local mode
CMD ["pyspark"]
