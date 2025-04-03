import math
import time

# Mock function to get the desired number of instances to scale
def get_desired_instances_to_scale():
    # You need to implement this function to get the desired number of instances to scale
    # This can be from any data source such as a database, API, or manual input
    # For this example, I'll just return a static value
    return 200  # Assuming you want to scale 47 instances in total

def scale_ec2_instances():
    # Set the maximum number of instances per iteration
    max_instances_per_iteration = 20
    
    # Get the desired number of instances to scale
    desired_instances_to_scale = get_desired_instances_to_scale()
    
    # Calculate the number of iterations required
    iterations = math.ceil(desired_instances_to_scale / max_instances_per_iteration)
    
    # Loop through each iteration
    for i in range(iterations):
        # Calculate the number of instances to scale in this iteration
        instances_to_scale = min(max_instances_per_iteration, desired_instances_to_scale - (i * max_instances_per_iteration))
        
        # Perform scaling operations here, for example, launching new instances
        # Here, we just print the action for demonstration purposes
        print(f"Scaling {instances_to_scale} instances in iteration {i + 1}...")
        
        # Sleep for some time before the next iteration
        # This can be adjusted based on your requirements
        time.sleep(2)  # Example: Sleep for 10 seconds

# Call the function to start scaling EC2 instances
scale_ec2_instances()
