// import groovy.json.JsonSlurper
// //      when ssm param like ikea,translations,lazadaph,amway,ant
// def cmd = "aws ssm get-parameters-by-path --path /pgw/v4ui"
// def ssm_params_json = cmd.execute()

// def obj = new JsonSlurper().parseText(ssm_params_json.text)
// def parameters = obj.Parameters
// def neededParam = parameters[0]
// def list = neededParam.Value.split(',')
// list.each { println it }

// return list


//      when ssm param like ["ikea","translations","lazadaph","amway","ant"]
// import groovy.json.JsonSlurper

// def cmd = "aws ssm get-parameters-by-path --path /pgw/v4ui"
// def ssm_params_json = cmd.execute()

// def obj = new JsonSlurper().parseText(ssm_params_json.text)
// def parameters = obj.Parameters
// def neededParam = parameters[0]
// def list = new JsonSlurper().parseText(neededParam.Value)

// list.each { println it }

// return list


import groovy.json.JsonSlurper
def command = '''
    export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
    $(aws sts assume-role \
    --role-arn arn:aws:iam::891349355538:role/IT-DEVOPS \
    --role-session-name testsession \
    --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
    --output text))
	aws ssm get-parameters-by-path --path /pgw/v4ui
'''
def proc = ['bash', '-c', command].execute()
def obj = new JsonSlurper().parseText(proc.text)
def parameters = obj.Parameters
def neededParam = parameters[0]
def list = neededParam.Value.split(',')
list.each { println it }

import groovy.json.JsonSlurper
def command = '''
    export $(printf 'AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s' \
    $(aws sts assume-role \
    --role-arn arn:aws:iam::891349355538:role/IT-DEVOPS \
    --role-session-name testsession \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text))
	  aws ssm get-parameters-by-path --path /pgw/v4ui
'''
def proc = ['bash', '-c', command].execute()
def obj = new JsonSlurper().parseText(proc.text)
def parameters = obj.Parameters
def neededParam = parameters[0]
def list = neededParam.Value.split(',')
list.each { println it }