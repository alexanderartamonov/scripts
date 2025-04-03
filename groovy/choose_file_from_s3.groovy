def s3ls_with_assume = """
export \\$(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \\
\\$(aws sts assume-role --role-arn arn:aws:iam::891349355538:role/IT-DEVOPS --role-session-name testsession --query Credentials.[AccessKeyId,SecretAccessKey,SessionToken] --output text))
aws s3 ls ${S3_BUCKET_PATH} --region ap-southeast-1
"""
def s3lsProcess = ['bash', '-c', s3ls_with_assume].execute()
s3lsProcess.waitFor()
def s3ListFiles = s3lsProcess.text
def s3SplittedList = s3ListFiles.split('\\\\n').collect { line ->
    def s3ListObj = line.split('\\\\s+')
    return s3ListObj[-1]
}