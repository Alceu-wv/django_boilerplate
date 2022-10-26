#!/bin/sh

echo ">>> Run Migration"
python manage.py migrate -v 0
echo ">>> Collect Static Files"
python manage.py collectstatic --noinput -v 0

if [ "$PROJECT_SERVICE_TYPE" = "api" ];
 then
  echo ">>> Starting Gunicorn"
  gunicorn core.wsgi
fi

if [ "$PROJECT_SERVICE_TYPE" = "worker" ];
 then
  echo ">>> Starting Celery Worker"
  celery worker -A core --loglevel=DEBUG
fi

if [ "$PROJECT_SERVICE_TYPE" = "beat" ];
 then
  echo ">>> Starting Celery Beat"
  rm -f /tmp/celerybeat.pid
  celery -A core beat --loglevel=DEBUG --pidfile /tmp/celerybeat.pid --scheduler django_celery_beat.schedulers:DatabaseScheduler
fi

if [ "$PROJECT_SERVICE_TYPE" = "flower" ];
 then
  echo ">>> Starting Celery Flower"
  celery -A core flower --address=0.0.0.0 --port=5555
fi
