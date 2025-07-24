# Running PySpark Job

## Build the image

```
docker build -t pyspark-image .
```

## Start a container

In order to use the Docker image use:

```
docker run --rm -v $(pwd):/workspace -it --memory 6g --cpus 2 pyspark-container /opt/spark/bin/spark-submit /workspace/my_pyspark_job.py
```
