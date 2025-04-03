import groovy.json.JsonSlurper

// Get all images with tags as JSON, the --filter is very important to get only images that have a tag
def cmd = "aws ecr list-images --registry-id 089465505731 --repository-name acsv2_authentication_api --region ap-southeast-1"
def ecr_images_json = cmd.execute()

// Parse JSON into Groovy object
def data = new JsonSlurper().parseText(ecr_images_json.text).imageIds
def result = data.imageTag.each { println it }




import groovy.json.JsonSlurper

def ecr = ['acsv2_authentication_api', 'acsv2_data_api','acsv2_challenge_api'] as String[]
// Get all images with tags as JSON, the --filter is very important to get only images that have a tag
if (ecr.contains('acsv2_authentication_api')) {
def cmd = "aws ecr list-images --registry-id 089465505731 --repository-name $ecr --region ap-southeast-1"
def ecr_images_json = cmd.execute()

// Parse JSON into Groovy object
def data = new JsonSlurper().parseText(ecr_images_json.text).imageIds
def result = data.imageTag.each { println it }
}