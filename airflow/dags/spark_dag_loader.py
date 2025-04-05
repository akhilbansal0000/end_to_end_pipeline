import os
import dagfactory
from airflow import DAG

DAG_CONFIG_PATH = "/opt/airflow/dags/_generated_dag_config.yaml"

if os.path.exists(DAG_CONFIG_PATH):
    dag_factory = dagfactory.DagFactory(DAG_CONFIG_PATH)
    if dag_factory.config:
        dag_factory.clean_dags(globals())
        dag_factory.generate_dags(globals())
    else:
        raise ValueError("DAG config exists but is empty or invalid.")
else:
    raise FileNotFoundError(f"DAG config file not found: {DAG_CONFIG_PATH}")
