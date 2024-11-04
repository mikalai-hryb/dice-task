FROM python:3.11-alpine

LABEL maintainer=mikalai-hryb

RUN apk update
RUN apk upgrade
RUN apk add --no-cache bash vim curl
RUN pip install pipenv

ENV APP_NAME=sonalake-task

WORKDIR pwd/..
COPY Pipfile .
COPY Pipfile.lock .
RUN pipenv install --deploy --ignore-pipfile

COPY src /src

WORKDIR /src
CMD [ "pipenv", "run", "python", "app.py" ]
