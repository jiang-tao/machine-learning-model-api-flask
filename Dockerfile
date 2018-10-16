# Dockerfile
FROM python:2.7-slim

ARG ML_MODEL_NAME=unspecified_model
ARG ML_MODEL_DESC=unspecified_model
ARG ML_MODEL_VERSION=unspecified_model_version
ARG ML_API_SCRIPT=unspecified_api_script
ARG ML_SCORING_FUNC=unspecified_scoring_function
ARG ML_PACKAGE=unknown_package_url
ARG ML_PACKAGE_SECRET=unknown
ENV ML_MODEL_NAME $ML_MODEL_NAME
ENV ML_MODEL_DESC $ML_MODEL_DESC
ENV ML_MODEL_VERSION $ML_MODEL_VERSION
ENV ML_API_SCRIPT $ML_API_SCRIPT
ENV ML_SCORING_FUNC $ML_SCORING_FUNC
ENV ML_PACKAGE ${ML_PACKAGE}
ENV ML_PACKAGE_SECRET ${ML_PACKAGE_SECRET}

# ENV CURL_CA_BUNDLE=
# ENV REQUESTS_CA_BUNDLE=

# RUN apt-get update && apt-get install -y g++

RUN pip install --upgrade setuptools pip && \
    pip install flask && \
    pip install gunicorn

RUN addgroup --system --gid 10000 analytics && \
    adduser --uid 10000 --gid 10000 --shell /bin/bash --system analytics && \
    mkdir -p /analytics 

COPY target/apiserver /analytics/apiserver
COPY uid_entrypoint.sh /analytics/

RUN chmod -R g=u /etc/passwd && \
    chown -R 10000:10000 /analytics && \
    chmod -R 755 /analytics && \
    if [ -f /analytics/apiserver/model/requirements.txt ]; then pip install -r /analytics/apiserver/model/requirements.txt; fi

USER analytics
WORKDIR /analytics

ENTRYPOINT ["/analytics/uid_entrypoint.sh"]
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "apiserver.scoring_server:app" ]
