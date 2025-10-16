# reading csv from data/landing and write parquet to data/bronze

"""
1) read all csv files in data/landing/
2) lowercase 'brand' and 'category_code'
3) parse timestamps
4) adds an 'ingested_at' timestamp
5) write parquet files to data/bronze/events/
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, lower, current_timestamp, to_timestamp, to_date, regexp_replace
from pyspark.sql.types import StructType, StructField, StringType, LongType, DoubleType


spark = (
    SparkSession.builder
    .appName("BronzeTransformation")
    .config("spark.driver.memory", "4g")                # gives Spark more memory (prevents Java heap error)
    .config("spark.sql.shuffle.partitions", "8")         # fewer shuffle partitions = less overhead
    .config("spark.sql.files.maxPartitionBytes", "134217728")  # 128 MB partitions
    .config("spark.sql.parquet.compression.codec", "snappy")   # compress output
    .getOrCreate())



input_path = "data/landing/"
output_path = "data/bronze/events/"

# defining the schema

schema = StructType([
    StructField("event_time", StringType(), True),
    StructField("event_type", StringType(), True),
    StructField("product_id", StringType(), True),
    StructField("category_id", LongType(), True),
    StructField("category_code", StringType(), True),
    StructField("brand", StringType(), True),
    StructField("price", DoubleType(), True),
    StructField("user_id", LongType(), True),
    StructField("user_session", StringType(), True)
])

# reading csv in landing
df_raw = spark.read.csv(input_path, header=True, schema=schema)

# cleaning the data

df_clean = (
    df_raw
      .withColumn("brand", lower(col("brand")))
      .withColumn("category_code", lower(col("category_code")))
      # parse event_time: strip trailing ' UTC', then cast to timestamp in UTC
      .withColumn("event_time_ts", to_timestamp(regexp_replace(col("event_time"), r" UTC$", ""), "yyyy-MM-dd HH:mm:ss"))
      .withColumn("event_date", to_date(col("event_time_ts")))  # partition column
      .withColumn("ingested_at", current_timestamp())
)

# naming the folder by the date
df_clean.write.mode("overwrite").partitionBy("event_date").parquet(output_path)