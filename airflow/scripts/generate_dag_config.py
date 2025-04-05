import os
import yaml
from datetime import datetime
from pathlib import Path

DAG_CONFIG_PATH = Path("/opt/airflow/dags/_generated_dag_config.yaml")
JOBS_DIR = Path("/jobs")

DEFAULT_ARGS = {
    "owner": "airflow",
    "start_date": str(datetime.today().date()),
    "retries": 1,
    "retry_delay_sec": 300,
    "depend_on_past": False,
}

DEFAULT_DAG_CONFIG = {
    "default_args": DEFAULT_ARGS,
    "schedule_interval": "0 * * * *",
    "catchup": False,
    "is_paused_upon_creation": False,
    "description": "Auto-generated Spark job DAG",
}

def generate_config():
    if not JOBS_DIR.exists():
        print(f"⚠️  Jobs directory not found: {JOBS_DIR}")
        return

    config = {}

    for job_file in sorted(JOBS_DIR.glob("*.py")):
        job_name = job_file.stem
        dag_id = f"spark_{job_name}_dag"
        config[dag_id] = {
            **DEFAULT_DAG_CONFIG,
            "tasks": {
                f"run_{job_name}": {
                    "operator": "airflow.operators.bash.BashOperator",
                    "bash_command": f"docker exec spark-master /opt/spark/bin/spark-submit --master spark://spark-master:7077 /jobs/{job_file.name}",
                }
            }
        }
        print(f"➕ Added DAG: {dag_id} for job: {job_file.name}")

    DAG_CONFIG_PATH.parent.mkdir(parents=True, exist_ok=True)
    with DAG_CONFIG_PATH.open("w") as f:
        yaml.dump(config, f, default_flow_style=False)
        print(f"✅ Generated DAG config at {DAG_CONFIG_PATH}")

if __name__ == "__main__":
    generate_config()
