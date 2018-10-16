#!/bin/bash

TAG=${1:-"salary_lr_model:1.0"}
NAME=${2:-"salary_lr_model"}

docker run --env ML_MODEL_RUNTIME_PROD=true -p 8080:8080 -d --name ${NAME} --hostname machine-learning-api-flask ${TAG}
