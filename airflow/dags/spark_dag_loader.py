import os
import yaml
import dagfactory
from airflow import DAG

DAG_CONFIG_PATH = "/opt/airflow/dags/_generated_dag_config.yaml"  # Temporary YAML file
JOBS_DIR = "/jobs"

# Default config to be shared by all DAGs
default_config = {
    "default_args": {
        "owner": "airflow",
        "start_date": "2025-04-04",
        "retries": 1,
        "retry_delay_sec": 300,
        "depend_on_past": False,
    },
    "schedule_interval": "@once",
    "catchup": False,
    "is_paused_upon_creation": False,
    "description": "Auto-generated Spark job DAG",
}

# Start config with only the default section
full_config = {
    "default": default_config
}

# Walk through jobs folder and generate one DAG per script
for filename in os.listdir(JOBS_DIR):
    if filename.endswith(".py"):
        job_name = filename.replace(".py", "")
        dag_id = f"spark_{job_name}_dag"
        full_config[dag_id] = {
            "tasks": {
                f"run_{job_name}": {
                    "operator": "airflow.operators.bash_operator.BashOperator",
                    "bash_command": f"docker exec spark-master /opt/spark/bin/spark-submit --master spark://spark-master:7077 /jobs/{filename}",
                }
            }
        }

# Write the full config to a temporary YAML file
with open(DAG_CONFIG_PATH, "w") as f:
    yaml.dump(full_config, f, default_flow_style=False)

# Load the DAGs from the generated config
dag_factory = dagfactory.DagFactory(DAG_CONFIG_PATH)
dag_factory.clean_dags(globals())
dag_factory.generate_dags(globals())
