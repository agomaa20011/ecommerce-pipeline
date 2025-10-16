from pyspark.sql import SparkSession

# Create Spark session with PostgreSQL connector
spark = (
    SparkSession.builder
    .appName("LoadToPostgres")
    .config("spark.jars.packages", "org.postgresql:postgresql:42.7.3")
    .getOrCreate()
)

# Read Parquet files from the bronze layer
input_path = "data/bronze/events/"
df = spark.read.parquet(input_path)

# Define PostgreSQL connection details
jdbc_url = "jdbc:postgresql://localhost:5432/ecommerce_pipeline"
properties = {
    "user": "postgres",
    "password": "1234",  
    "driver": "org.postgresql.Driver"
}

# rite data to PostgreSQL 
df.write.jdbc(
    url=jdbc_url,
    table="stg.events",   
    mode="overwrite",     
    properties=properties
)
