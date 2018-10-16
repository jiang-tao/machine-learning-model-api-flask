# Linear Regression Model for Salary Data
import os, pickle

#Init
model_path=os.path.realpath(__file__)
model_dir=os.path.dirname(model_path)
print('model - init - loading pickle file from: ', model_dir)
with open(model_dir+'/python_lreg_model.pkl', 'rb') as file_handler:
    loaded_lr_model = pickle.load(file_handler)
print('model - init - done.')

def score(data):    
    try:
        print('score data:',data)
        print('Input[ yearsExperience:',data['yearsExperience'],' ]')
    except:
        return {
            'salary':-1, 
            'error':'invalid data format: {0}'.format(data)
        }
    
    try:
        score_predict=loaded_lr_model.predict([
            [data['yearsExperience']]
        ])
        return {'salary': score_predict[0], 'error': None}
    except:
        return {
            'salary':-1, 
            'error':'cannot load model'
        }

if __name__ == '__main__':
    #print the input variables
    print("argv: ",sys.argv)
    score_result=score({'yearsExperience':10})
    print("scoring result:",score_result)
