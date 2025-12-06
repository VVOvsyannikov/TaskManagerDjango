FROM python:3.12-slim

ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PIPX_HOME=/opt/pipx \
    PIPX_BIN_DIR=/opt/pipx/bin \
    PATH="/opt/pipx/bin:$PATH"

RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        build-essential \
        python3-venv \
        python3-pip \
        ca-certificates \
        curl \
        git \
        gnupg \
        jq \
        less \
        libpcre2-8-0 \
        libpcre2-dev \
        openssh-client \
        telnet \
        unzip \
        vim \
        wget \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log

RUN pip install --no-cache-dir pipx \
    && pipx ensurepath

RUN pipx install poetry

RUN poetry config virtualenvs.create false

RUN mkdir -p /app
WORKDIR /app

COPY pyproject.toml poetry.lock ./
RUN poetry install  --no-interaction --no-ansi --no-root

ADD . /app
ENV DJANGO_SETTINGS_MODULE="task_manager.settings"

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]