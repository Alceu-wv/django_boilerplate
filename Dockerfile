FROM python:3.10.5-slim-buster AS compile-image

RUN apt-get update && apt-get -y upgrade  && apt-get install -y --no-install-recommends build-essential\
    gcc libcurl4-openssl-dev libssl-dev curl libpq-dev libopenblas-dev liblapack-dev gfortran

WORKDIR /app

ENV \
    POETRY_VERSION=1.1.15 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1

RUN curl -sSL https://install.python-poetry.org | python -
ENV PATH="$POETRY_HOME/bin:$PATH"

COPY poetry.lock pyproject.toml ./
RUN poetry export --without-hashes --format=requirements.txt > /app/requirements.txt


FROM python:3.10.5-slim-buster AS runtime-image

ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1

ENV \
    CELERY_LOGLEVEL=WARNING \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100\
    OTEL_PYTHON_DISABLED_INSTRUMENTATIONS="system_metrics"


COPY --from=compile-image /app/requirements.txt ./

RUN apt-get update && apt-get install -y --no-install-recommends build-essential gcc libcurl4-openssl-dev libssl-dev git libpq-dev libopenblas-dev liblapack-dev gfortran
RUN pip install -r requirements.txt

WORKDIR /app
COPY . /app
EXPOSE 8001

CMD ["sh", "/app/entrypoint.sh"]


FROM compile-image AS runtime-dev

ENV CELERY_LOGLEVEL=DEBUG
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME | true \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME | true \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN apt-get update && apt-get install -y git
WORKDIR /app
COPY . /app

RUN poetry config virtualenvs.create false && poetry install

EXPOSE 8001

CMD ["sh", "/app/entrypoint.sh"]
