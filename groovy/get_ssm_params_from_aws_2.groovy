import groovy.json.JsonSlurper

def cmd = "aws ssm get-parameters-by-path --path /pgw/v4ui"
def ssm_params_json = cmd.execute()

def data = new JsonSlurper().parseText(ssm_params_json.text)

def ssm_params = [];

data.Parameters[0].each { ssm_params.push(it.Value) } 

return ssm_params