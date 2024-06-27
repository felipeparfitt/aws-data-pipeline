from pyspark.sql import SparkSession
from delta.tables import *
import os
import json
from emr_delta_transformation import silver_transformation_sql, gold_transformation


class DeltaLakeOnAWS():
    def __init__(
        self,
        database_name: str,
        delta_lake_bucket: str,
    ):
        self.database_name = database_name
        self.delta_lake_bucket = delta_lake_bucket
        self.spark = SparkSession.builder.getOrCreate()
        
    def read_from_glue_catalog(self, table_name: str):
        # Reading the data from aws glue datacalog
        self.spark.catalog.setCurrentDatabase(f"`{self.database_name}`")
        spark_data_frame = self.spark.sql(f"SELECT * FROM {table_name}")
        
        return spark_data_frame
        
    def write_to_bronze(self, df, format: str = "delta", prefix: str = None):
        # Write to bronze layer
        df.write.mode('overwrite').format(format).save(
            f"s3a://{self.delta_lake_bucket}/{prefix}"
        )
        # Creating the manifest file
        deltaTable = DeltaTable.forPath(self.spark, f"s3a://{self.delta_lake_bucket}/{prefix}")
        deltaTable.generate("symlink_format_manifest")
            
    def write_to_silver(self, table_name: str = None, format: str = "delta", sql_query: str = None):
        # REMVE FIELDS, CONCAT FIELDS, CHANGE THE TYPE, REPLACE EMPTY FIELDS WITH NULLS,
        # FORMAT MORE OPTIMATIZED FOR DATA ANALISTICS
        
        # Reading data from bronze layer
        bronze_prefix = f'bronze/{table_name}'
        df = self.spark.read.load(f"s3a://{self.delta_lake_bucket}/{bronze_prefix}")
        df.createOrReplaceTempView(table_name)
        # Transforming the bronze data using sql query
        df_silver = self.spark.sql(sql_query)
        
        # Write to silver layer
        silver_prefix = f'silver/{table_name}'
        df_silver.write.mode('overwrite').format(format).save(f"s3a://{self.delta_lake_bucket}/{silver_prefix}")
        # Creating the manifest file
        deltaTable = DeltaTable.forPath(self.spark, f"s3a://{self.delta_lake_bucket}/{silver_prefix}")
        deltaTable.generate("symlink_format_manifest")
    
    def write_to_gold(self, table_name: str = None, used_tables: list = None, format: str = "delta", sql_query: str = None):
        
        for table in used_tables:
            # Reading data from silver layer
            silver_prefix = f'silver/{table}'
            df = self.spark.read.load(f"s3a://{self.delta_lake_bucket}/{silver_prefix}")
            df.createOrReplaceTempView(table)
        # Transforming the bronze data using sql query
        df_gold = self.spark.sql(sql_query)
        
        # Write to gold layer
        gold_prefix = f'gold/{table_name}'
        df_gold.write.mode('overwrite').format(format).save(f"s3a://{self.delta_lake_bucket}/{gold_prefix}")
        # Creating the manifest file
        deltaTable = DeltaTable.forPath(self.spark, f"s3a://{self.delta_lake_bucket}/{gold_prefix}")
        deltaTable.generate("symlink_format_manifest")
        
        
        
if __name__ == '__main__':
    
    # Getting useful variables
    GLUE_DATABASE_NAME = os.getenv('GLUE_DATABASE_NAME')
    DELTA_LAKE_BUCKET_NAME = os.getenv('DELTA_LAKE_BUCKET_NAME')
    GLUE_DATACATALOG_TABLES = os.getenv('GLUE_DATACATALOG_TABLES').split()
    
    deltalake = DeltaLakeOnAWS(
                    database_name=GLUE_DATABASE_NAME, 
                    delta_lake_bucket=DELTA_LAKE_BUCKET_NAME
                )
    # Write to bronze layer
    for glue_table in GLUE_DATACATALOG_TABLES:
        spark_df = deltalake.read_from_glue_catalog(glue_table)
        spark_df.printSchema()
        spark_df.show()
        
        deltalake.write_to_bronze(
            spark_df, 
            prefix=f'bronze/{glue_table}'
        )
    
    # Write to silver layer
    for table_name, sql_query in silver_transformation_sql.items():
        deltalake.write_to_silver(
            table_name=table_name,
            sql_query=sql_query
        )
    
    # Write to gold layer
    for table_name, dict_transf in gold_transformation.items():
        deltalake.write_to_gold(
            table_name=table_name,
            used_tables=dict_transf["tables"],
            sql_query=dict_transf["sql"]
        )



