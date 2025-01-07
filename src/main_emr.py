import argparse
import logging
from pyspark.sql import SparkSession

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("IcebergJob")

def parse_args():
    parser = argparse.ArgumentParser(description="PySpark Job Arguments for Iceberg Table Writing")
    parser.add_argument("--tablebucket_arn", required=True, help="ARN of the S3 bucket for Iceberg tables")
    parser.add_argument("--namespace", required=True, help="Namespace of the table")
    parser.add_argument("--table", required=True, help="Table name within the namespace")
    return parser.parse_args()

args = parse_args()
TABLEBUCKET_ARN = args.tablebucket_arn
NAMESPACE = args.namespace
TABLE = args.table

logger.info(f"Table Bucket ARN: {TABLEBUCKET_ARN}")
logger.info(f"Namespace: {NAMESPACE}")
logger.info(f"Table: {TABLE}")

spark = SparkSession.builder \
    .appName("IcebergTableWriter") \
    .config("spark.sql.catalog.s3tablesbucket", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.s3tablesbucket.catalog-impl", "software.amazon.s3tables.iceberg.S3TablesCatalog") \
    .config("spark.sql.catalog.s3tablesbucket.warehouse", TABLEBUCKET_ARN) \
    .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
    .getOrCreate()

logger.info("SparkSession initialized successfully.")

data = [
    {"id": 1, "name": "Alice", "age": 30},
    {"id": 2, "name": "Bob", "age": 25},
    {"id": 3, "name": "Charlie", "age": 35}
]

df = spark.createDataFrame(data)

try:
    df.writeTo(f"s3tablesbucket.{NAMESPACE}.{TABLE}") \
        .using("iceberg") \
        .tableProperty("format-version", "2") \
        .createOrReplace()
    
    logger.info("Data written successfully to S3Table.")
except Exception as e:
   raise Exception(f"Failed to write data to S3Table: {e}")

try:
    logger.info("Recovering data from table.")
    spark.table(f"s3tablesbucket.{NAMESPACE}.{TABLE}").show(n=20, truncate=False)
except Exception as e:
    raise Exception(f"Failed to read data from S3Table: {e}")