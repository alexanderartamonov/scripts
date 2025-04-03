import groovy.json.JsonSlurper
def command = '''
	  export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
    $(aws sts assume-role \
    --role-arn arn:aws:iam::891349355538:role/IT-DEVOPS \
    --role-session-name testsession \
    --query Credentials.[AccessKeyId,SecretAccessKey,SessionToken] \
    --output text))
	  aws ssm get-parameters-by-path --path /pgw/v4ui
'''
def proc = ['bash', '-c', command].execute()
def obj = new JsonSlurper().parseText(proc.text)
def parameters = obj.Parameters
def neededParam = parameters[0]
def list = neededParam.Value.split(',')
list.each { println it }