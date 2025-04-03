from pprint import pprint
import inquirer
import subprocess

eks_cluster = [
    inquirer.List(
        "name",
        message="Choose EKS Cluster context for switch:",
        choices=["prod-jenkins-cluster", 
                 "uat-jenkins",
                 "emv3ds-uat", 
                 "emv3ds-loadtest",
                 "demo-emvacs-new-demo",  
                 "emv3ds-stg",
                 "emv3ds-a", 
                 "sit-cluster_a-acsv2", 
                 "win-cluster-a-incubator",
                 "mgmt-monitoring-cluster-a",
                 "loadtest-2c2p-cluster-a-sit",
                 "client-loadtest-cluster",
                 "playground-devops-cluster",
                 "sit-kbank-acsv2",
                 "dev-2c2p-cluster-a-sit"
                 ],
    ),
]

aws_region = input("Enter desired aws region: ")

answers = inquirer.prompt(eks_cluster)
eks = list(answers.values())
       
print('\033[38;5;220mSwitching to EKS Cluster: {0}'.format('\033[38;5;202m'+eks[0]+'\033[0;0m\n'))
push=subprocess.call(['aws', 'eks', 'update-kubeconfig', '--region', aws_region ,'--name', eks[0]])