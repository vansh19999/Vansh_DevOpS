import sys, json
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark.context import SparkContext

args = getResolvedOptions(sys.argv, [])
sc = SparkContext.getOrCreate()
glue = GlueContext(sc)
spark = glue.spark_session

# simple no-op transform: count rows and write out as manifest file
input_path  = "s3://mlops-predictive-raw-975628796846/data.csv"
output_path = "s3://mlops-predictive-processed-975628796846/output/"

df = spark.read.option("header", True).csv(input_path)
count = df.count()
spark.createDataFrame([(count,)], ["row_count"]).coalesce(1).write.mode("overwrite").json(output_path)
