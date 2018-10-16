# Flask ML Python Model API Runtime

from flask import Flask,request,jsonify
import sys,os,json

basedir = os.getcwd()
sys.path.append(basedir+'/apiserver')
sys.path.append(basedir)

print(basedir+'/apiserver')

## Retrieve Model Info, Scoring Script and Function Name
model_name=os.environ['ML_MODEL_NAME']
model_desc=os.environ['ML_MODEL_DESC']
model_version=os.environ['ML_MODEL_VERSION']
scoring_package_name=os.environ['ML_API_SCRIPT']
scoring_function_name=os.environ['ML_SCORING_FUNC']
print('model_name:', model_name)
print('model_desc:', model_desc)
print('model_version:', model_version)
print('scoring_package_name:', scoring_package_name)
print('scoring_function_name:', scoring_function_name)

#import apiserver
#from apiserver.model import salary_lr_model

##Import Scoring Function
scoring_package=__import__('apiserver.model.{scoring_script}'.format(scoring_script=scoring_package_name), fromlist=('apiserver.model'))
scoring_function=getattr(scoring_package,scoring_function_name)

app = Flask(__name__)
# api = Api(app)

@app.route('/')
def info():
    return jsonify({
            'info':'C2E Machine Learning Model Runtime'
    })

@app.route('/api/models/call-model', methods=['POST'])
def call_model():
    if request.method == 'POST':
        try:
            print('Received request - [  headers: {0}  ]; [  data: {1}  ]'.format(request.headers, request.data))

            req_data=request.get_json()
            result = scoring_function(req_data)

            print('Return result:', result)
            return jsonify(result)
        except:
            print('Failed to process POST scoring request - [  headers: {0}  ]; [  data: {1}  ]'.format(request.headers, request.data))

    return jsonify({
        'score': -1,
        'error': 'Failed to process request - [  headers {0}  ]; [  data: {1}  ]'.format(request.headers, request.data)
    })


if __name__ == '__main__':
    print('Start flask api:', sys.argv)    
    app.run(debug=False,host='0.0.0.0',threaded=False)
