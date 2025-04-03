def getConfiguration(env) {
    def AWS_ENVIRONMENT = "${getVars(env).aws_environment}"
    def AWS_REGION = "${getVars(env).aws_region}"
    def AWS_ACCOUNT_ID = "${getVars(env).aws_account_id}"
    def AWS_IAM_ROLE_NAME = "${getVars(env).aws_iam_role_name}"
    def AWS_S3_BUCKET_NAME = "${getVars(env).s3_bucket_name}"
    def AWS_S3_PATH = "OpenSearchDLQProcessorLambda"
    def AWS_LAMBDA_FUNCTION_NAME = "${getVars(env).lambda_function_name}"

    return [
        AWS_ENVIRONMENT: AWS_ENVIRONMENT,
        AWS_REGION: AWS_REGION,
        AWS_ACCOUNT_ID: AWS_ACCOUNT_ID,
        AWS_IAM_ROLE_NAME: AWS_IAM_ROLE_NAME,
        AWS_S3_BUCKET_NAME: AWS_S3_BUCKET_NAME,
        AWS_S3_PATH: AWS_S3_PATH,
        AWS_LAMBDA_FUNCTION_NAME: AWS_LAMBDA_FUNCTION_NAME,
    ]
}

def getLambdaVersions(conf) {
    def lambdaListVersionsByFunction = """ \\
    export \$(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \\
    \$(aws sts assume-role --role-arn arn:aws:iam::${conf.AWS_ACCOUNT_ID}:role/${conf.AWS_IAM_ROLE_NAME} --role-session-name testsession --query Credentials.[AccessKeyId,SecretAccessKey,SessionToken] --output text))
    aws lambda list-versions-by-function --function-name ${conf.AWS_LAMBDA_FUNCTION_NAME} --query 'Versions' --output json
    """
    def jsonData = ['bash', '-c', lambdaListVersionsByFunction].execute()
    def parseData = new groovy.json.JsonSlurper().parseText(jsonData.text)
    def versions = parseData.Version.reverse()
    return versions
}

//call: choice(name: 'ROLLBACK_VERSION', choices: "${getLambdaVersions(getConfiguration(params.ENV)).join('\n')}", description: 'Specify Lambda function version for rollback\n')