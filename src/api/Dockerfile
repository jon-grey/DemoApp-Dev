
###############################################################################
#### PYTHON REQUIREMENTS BUILDER
###############################################################################

FROM python:3.9.10-slim-buster

# set flask env vars (with defauls after =)
ARG FLASK_ENV=development
ARG FLASK_APP=api

# export path to gunicorn, flask
ENV PATH "/home/python/.local/bin:${PATH}"

# create python user:group to not use root
RUN groupadd python && useradd -m python -g python

# activate python user:group
USER python:python

# set current directory
WORKDIR /app

# as python user:group, from build stage copy the requirements file into the image
COPY --chown=python:python requirements/requirements.txt requirements.txt

# install python requirements (flask, psutil)
RUN pip3 install --no-cache-dir  -r requirements.txt --no-warn-script-location

# as python user:group copy app source code
COPY --chown=python:python src ./src

# set current directory
WORKDIR /app/src

RUN echo ${PATH}

EXPOSE 5000

RUN ls -la /home/python/.local

# configure the container to run in an executed manner
ENTRYPOINT [ "gunicorn" ]

# default args for entrypoint to serve app
CMD [ "--workers=2", "--threads=4", "--worker-class=gthread", "--bind=0.0.0.0:5000", "app:app" ]
