from __future__ import annotations

import pendulum

from airflow.sdk import dag, task


@dag(
    dag_id="local_standalone_example",
    start_date=pendulum.datetime(2026, 1, 1, tz="UTC"),
    schedule=None,
    catchup=False,
    tags=["local", "example"],
    is_paused_upon_creation=False,
)
def local_standalone_example():
    @task
    def hello() -> str:
        message = "Airflow standalone is running from docker compose."
        print(message)
        return message

    @task
    def done(message: str) -> None:
        print(f"Received: {message}")

    done(hello())


local_standalone_example()
