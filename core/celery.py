import os

from asbool import asbool
from celery import Celery
from celery.schedules import crontab
from celery.signals import worker_process_init

# set the default Django settings module for the "celery" program.
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "core.settings")


@worker_process_init.connect(weak=False)
def init_celery_tracing(*args, **kwargs):
    if not asbool(os.environ.get("OTEL_EXPORTER_ACTIVE")):
        return ""


app = Celery("project_name")

# Using a string here means the worker doesn"t have to serialize
# the configuration object to child processes.
# - namespace="CELERY" means all celery-related configuration keys
#   should have a `CELERY_` prefix.
app.config_from_object("django.conf:settings", namespace="CELERY")

# Load task modules from all registered Django app configs.
app.autodiscover_tasks()

app.conf.timezone = "UTC"

# app.conf.beat_schedule = {
#     "health_check": {
#         "task": "worker_health_check",
#         "schedule": crontab(minute="*/1"),
#     },
# }
