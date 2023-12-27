FROM python:3.10-alpine3.18
LABEL maintainer="viswanadh"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
RUN apk --update --no-cache add \
        build-base \
        libffi-dev \
        openssl-dev \
        && python -m venv /py \
        && /py/bin/pip install --upgrade pip \
        && apk add --update --no-cache postgresql-client \
        && apk add --update --no-cache --virtual .tmp-build-deps \
           build-base postgresql-dev musl-dev \ 
        && /py/bin/pip install -r /tmp/requirements.txt \
        && if [ $DEV = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi \
        && rm -rf /tmp \
        && apk del .tmp-build-deps \
        && adduser \
            --disabled-password \
            --no-create-home \
            django-user \
        && apk del build-base libffi-dev openssl-dev

# Install flake8 globally
RUN pip install flake8

ENV PATH="/py/bin:$PATH"

USER django-user