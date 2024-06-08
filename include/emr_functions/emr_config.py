# aws_access_key_id = os.getenv("access_key")
# aws_secret_access_key = os.getenv("secret_key")
region_name = 'us-east-2' #os.getenv("REGION_NAME")
cluster_name = 'emr-cluster-learning' #os.getenv("CLUSTER_NAME")
path_s3_logs = 's3://aws-logs-612649281430-us-east-2/elasticmapreduce' #os.getenv("PATH_S3_LOGS")
ServiceRole = 'arn:aws:iam::612649281430:role/service-role/AmazonEMR-ServiceRole-20240502T101532' #'AmazonEMR-ServiceRole-20240502T101532' #os.getenv("SERVICE_ROLE")
JobFlowRole = 'arn:aws:iam::612649281430:instance-profile/AmazonEMR-InstanceProfile-20240502T101515' #'AmazonEMR-InstanceProfile-20240502T101515' #os.getenv("JOB_FLOW_ROLE")
KeyEc2 = 'aws_emr_keypair' #os.getenv("KEYEC2")
#bootstrap_path = 's3://owshq-landing-zone-dev-612649281430/bootstrap/bootstrap.sh'
vpc_id = 'vpc-0a0d66bf21f1689f4'
Subnet_Id = 'subnet-08cbc6f0b6624216c' #os.getenv("SUBNET_ID")
EmrManagedMasterSecurityGroup = 'sg-025c1b308419633e7'
EmrManagedSlaveSecurityGroup = 'sg-096268a4b279b8c75'

SPARK_STEPS = [
    {
        'Name': 'calculate_pi',
        'ActionOnFailure': 'CONTINUE',
        'HadoopJarStep': {
            'Jar': 'command-runner.jar',
            'Args': ['/usr/lib/spark/bin/run-example', 'SparkPi', '10'],
        },
    }
]

JOB_FLOW_OVERRIDES = {
    "Name":cluster_name,
    "ReleaseLabel":"emr-6.15.0",
    "Applications":[
        {"Name": "Spark"},
        {"Name": "Hadoop"},
        {"Name": "Hive"},
        {"Name": "JupyterEnterpriseGateway"},
    ],
    "ServiceRole":ServiceRole,
    "JobFlowRole":JobFlowRole,
    "VisibleToAllUsers":True,
    "StepConcurrencyLevel":2,
    "LogUri":path_s3_logs,  # criar um bucket para os logs
    "Instances":{
        "InstanceGroups": [
            {
                "Name": "Master nodes",
                "Market": "SPOT", #ON_DEMAND
                "InstanceRole": "MASTER",
                "InstanceType": "m5.xlarge",
                "InstanceCount": 1,
            },
            {
                "Name": "Worker nodes",
                "Market": "SPOT",
                "InstanceRole": "CORE",
                "InstanceType": "m5.xlarge",
                "InstanceCount": 1,
            },
        ],
        "Ec2KeyName": KeyEc2,  # criar uma key
        "KeepJobFlowAliveWhenNoSteps": False,
        "TerminationProtected": False,
        "Ec2SubnetId": Subnet_Id,  # subnet padrao da aws
        'EmrManagedMasterSecurityGroup': EmrManagedMasterSecurityGroup,
        'EmrManagedSlaveSecurityGroup': EmrManagedSlaveSecurityGroup,
    },
    "Steps":SPARK_STEPS,
    "Configurations":[
        {
            "Classification": "spark-hive-site",
            "Properties": {
                "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
            },
        },
        {
            'Classification': 'hive-site',
            'Properties': {
                'hive.metastore.client.factory.class': 'com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory'
            }
        },
        {
                "Classification": "delta-defaults",
                "Properties": {"delta.enabled": "true"},
            },
    ],
    "AutoTerminationPolicy":{"IdleTimeout": 3600},
    "EbsRootVolumeSize":15, #GiB
    "EbsRootVolumeIops":3000,      
    "EbsRootVolumeThroughput":125, #MiB/s
}

