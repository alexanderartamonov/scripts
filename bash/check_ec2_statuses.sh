#!/bin/bash
AUTO_SCALING_GROUP_NAME="dev_mock-team-sg-pgw-dev-autoscaling-group-fe-a"
check_instances_health() {
    instance_ids=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names $AUTO_SCALING_GROUP_NAME \
    --query 'AutoScalingGroups[0].Instances[*].InstanceId' --output text)
    for instance_id in $instance_ids; do
        health_status=$(aws ec2 describe-instance-status \
        --instance-ids $instance_id \
        --query 'InstanceStatuses[0].SystemStatus.Details[0].Status' --output text)
        if [ "$health_status" != "passed" ]; then
            echo "$instance_id is not in 'passed' state. Let's wait.."
            return 1
        else echo "$instance_id is in 'passed' state. Let's continue.."
        fi
    done
    return 0
}
while true; do
    if check_instances_health; then
        echo "All instances are in 'passed' state. Proceeding with script execution."
        break  
    else
        echo "Waiting for instances to reach 'passed' state..."
        sleep 5  
    fi
done
