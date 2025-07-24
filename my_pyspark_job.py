from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("High Workload PySpark Job").getOrCreate()

# Example PySpark code
df = spark.read.csv("emp.csv", header=True, inferSchema=True)
df.show()
