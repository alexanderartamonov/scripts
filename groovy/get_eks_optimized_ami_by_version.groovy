    // stringParam('AWS_REGION', 'ap-southeast-1')
    // stringParam('EKS_VERSION', '1.31')
    // choiceParam('ENV', ['UAT','STAGE','PROD'], 'Choose env tag for ami')
    // choiceParam('PRODUCT', ['CIS-COMPLIANCE','SHARED','DEVOPS','PGW','ACSCORE'], 'Choose product tag for ami')
    // choiceParam('AMI_TYPE', [
    //                         'amazon-linux-2-arm64', 
    //                         'amazon-linux-2', 
    //                         'amazon-linux-2023/arm64/standard', 
    //                         'amazon-linux-2023/x86_64/standard'], 'Choose AMI type')


def get_ami_from_ssm_with_assume = """
export \\$(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \\
\\$(aws sts assume-role --role-arn arn:aws:iam::${UAT_AWS_ACCOUNT_ID}:role/IT-DEVOPS --role-session-name testsession --query Credentials.[AccessKeyId,SecretAccessKey,SessionToken] --output text))
aws ssm get-parameter --name /aws/service/eks/optimized-ami/${EKS_VERSION}/${AMI_TYPE}/recommended/image_id \
    --region ${AWS_REGION}  --query "Parameter.Value" --output text
"""
def SsmAmiIdProcess = ['bash', '-c', get_ami_from_ssm_with_assume].execute()
SsmAmiIdProcess.waitFor()
def SsmGetAmi = SsmAmiIdProcess.text
def SsmGetAmiSplitted = SsmGetAmi.split('\\\\n').collect { line ->
     def SsmGetAmiId = line.split('\\\\s+')
     return SsmGetAmiId[-1]
}