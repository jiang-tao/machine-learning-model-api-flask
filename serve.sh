#!/bin/bash

export ML_MODEL_NAME=dlp
export ML_MODEL_DESC=dlp
export ML_MODEL_VERSION=1.0
# export ML_API_SCRIPT=salary_lr_model
# export ML_SCORING_FUNC=score
export ML_API_SCRIPT=api
export ML_SCORING_FUNC=predict
#export ML_MODEL_RUNTIME_PROD=true

# export PYTHONLIB=/Users/jiangtaojiang/Applications/Homebrew-brew/lib/python2.7
# export PYTHONPATH=/Users/jiangtaojiang/Applications/Homebrew-brew/lib/python2.7

cd target
# export FLASK_APP="apiserver/scoring_server.py"
# flask run
python apiserver/scoring_server.py
cd ..
