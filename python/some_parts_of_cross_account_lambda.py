# call ec2 client using the assumed role credentials
                ec2_threeds_uat_client = assume_aws_threedsuat() # Assumes threeds uat role
                private_ip = sns_message_ip
                threeds_uat_response = ec2_threeds_uat_client.describe_instances(
                        Filters=[{
                                  'Name': 'network-interface.addresses.private-ip-address', 'Values':[private_ip]
                            }
                        ]
                    )
                print(threeds_uat_response)
                if (threeds_uat_response == '200'):
                    instance_id = threeds_uat_response['Reservations'][0]['Instances'][0]['InstanceId']
                    return instance_id
                    print("threeds_uat_instance_id: " +instance_id) 
                else: 
                    uat_ec2_client = boto3.client('ec2')
                    private_ip = sns_message_ip
                    uat_response = uat_ec2_client.describe_instances(
                            Filters=[{
                                      'Name': 'network-interface.addresses.private-ip-address', 'Values':[private_ip]
                                }
                            ]
                        )
                print(uat_response)
                if (uat_response['Reservations'][0]['Instances'][0]['VpcId'] == 'vpc-2db45848'):
                    uat_instance_id = uat_response['Reservations'][0]['Instances'][0]['InstanceId']
                    return instance_id
                    print("uat_instance_id: " +instance_id) 
                