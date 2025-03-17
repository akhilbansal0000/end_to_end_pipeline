from pyspark.sql import SparkSession

# Initialize Spark session
spark = SparkSession.builder.appName("PySparkExample").master("spark://spark-master:7077").getOrCreate()

# Create a DataFrame
data = [(1, "Alice"), (2, "Bob"), (3, "Charlie")]
df = spark.createDataFrame(data, ["id", "name"])

# Show DataFrame content
df.show()

# Stop the Spark session
spark.stop()
