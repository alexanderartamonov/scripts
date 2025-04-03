import groovy.json.JsonSlurper
def ASG='dev_mock-team-sg-pgw-dev-autoscaling-group-fe-a'
def instance_ids = '''aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names dev_mock-team-sg-pgw-dev-autoscaling-group-fe-a --query 'AutoScalingGroups[].Instances[].InstanceId'  --output text'''
def check_instances_in_service = '''aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names dev_mock-team-sg-pgw-dev-autoscaling-group-fe-a \
--query "length(AutoScalingGroups[0].Instances[?LifecycleState=='InService'])" --output text
'''
def proc = ['sh', '-c', check_instances_in_service].execute()
def obj = new JsonSlurper().parseText(proc.text)
println obj