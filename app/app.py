from src import create_app
from src.worker import CelerySingleton
from celery.exceptions import TimeoutError
import os 
import logging

APP_ENV = os.environ.get("APP_ENV")
FLASK_ENV = os.environ.get("FLASK_ENV")

if FLASK_ENV is None:
    if APP_ENV is None:
        FLASK_ENV = "production"
    else:
        FLASK_ENV = APP_ENV


application = app = create_app(FLASK_ENV)

celery = CelerySingleton(app).get_celery()

# import tasks so that they are defined in the celery app
from src.worker.tasks import add_two_numbers

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)