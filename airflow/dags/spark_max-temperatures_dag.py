from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {
    'start_date': datetime(2025, 4, 4),
}

with DAG(
    dag_id='spark_max-temperatures_dag',
    default_args=default_args,
    schedule_interval=None,
    catchup=False,
    tags=['spark'],
) as dag:

    run_spark_job = BashOperator(
        task_id='run_max-temperatures',
        bash_command="""
        docker exec spark-master \
        /opt/spark/bin/spark-submit \
        --master spark://spark-master:7077 \
        /jobs/friends-by-age.py
        """,
    )
