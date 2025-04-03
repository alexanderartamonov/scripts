// import groovy.json.JsonSlurperClassic
// def PROJECT = 'AUTHENTICATION'
// def getImageTag(ecr_name) { 
//   def cmd ="aws ecr list-images --registry-id 089465505731 --repository-name $ecr_name --region ap-southeast-1"
//   def ecr_images_json = cmd.execute()
//   def data = new JsonSlurperClassic().parseText(ecr_images_json.text)
//   def result = data.imageIds.imageTag.findAll() { it =~ 'jenkins-' }
//   def customComparator = { a, b ->
//       def numberA = a.replaceAll(/[^0-9]/, '') as Integer
//       def numberB = b.replaceAll(/[^0-9]/, '') as Integer
//       return numberB - numberA
//   }
// return result.sort(customComparator)
// def top5Elements = [:]
// result.each { element ->
//     def format = element =~ 'jenkins-(w+)-'
//     if (format) {
//         format = format[0][1]
//         if (!top5Elements[format]) {
//             top5Elements[format] = []
//         }
//         if (top5Elements[format].size() < 5) {
//             top5Elements[format] << element
//         }
//     }
// }
// def finalList = top5Elements.values().flatten()[0..30]
// return finalList.join('\n')
// }
// if (PROJECT == 'ALL-SOLUTION') {
//     return null
// }
// if (PROJECT == 'AUTHENTICATION') {
//     getImageTag('acsv2_authentication_api')
// }
// else if (PROJECT == 'DATAAPI') {
//     getImageTag('acsv2_data_api')
// }
// else if (PROJECT == 'CHALLENGE') {
//     getImageTag('acsv2_challenge_api')
// }
// else if (PROJECT == 'DATAWRITER') {
//     getImageTag('acsv2_data_writer')
// }
// else if (PROJECT == 'DATAWRITERINITRX') {
//     getImageTag('acsv2_data_writer')
// }
// else if (PROJECT == 'PENDING') {
//     getImageTag('acsv2_pending_service')
// }
// else if (PROJECT == 'DECEXPTRANCOLLECTOR') {
//     getImageTag('acsv2_dec_exp_tran_collector')
// }
// else if (PROJECT == 'DECEXPTRANHANDLER') {
//     getImageTag('acsv2_dec_exp_tran_handler')
// }
// else if (PROJECT == 'DDC') {
//     getImageTag('acsv2_ddc_api')
// }


import groovy.json.JsonSlurper
def PROJECT = 'CHALLENGE'
def getImageTag(ecr_name) { 
  def aws_get_images = '''
  export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
  $(aws sts assume-role \
  --role-arn arn:aws:iam::089465505731:role/IT-DEVOPS \
  --role-session-name testsession \
  --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
  --output text))
  aws ecr list-images --repository-name $ecr_name --region ap-southeast-1
  '''
  def ecr_images_json = ['bash', '-c', aws_get_images].execute()
  def data = new JsonSlurper().parseText(ecr_images_json.text)
  def pattern = '(?:jenkins)(?:_|-|.)(?:develop|qa|master)(?:_|-|.)|(?:v)(?:_|-)'
  def result = data.imageIds.imageTag.findAll() { it =~ pattern }
  def customComparator = { a, b ->
      def numberA = a.replaceAll(/[^0-9]/, '') as Integer
      def numberB = b.replaceAll(/[^0-9]/, '') as Integer
      return numberB - numberA
  }
return result.sort(customComparator)
}
if (PROJECT == 'ALL-SOLUTION') {
    return null
}
if (PROJECT == 'AUTHENTICATION') {
    getImageTag('acsv2_authentication_api')
}
else if (PROJECT == 'DATAAPI') {
    getImageTag('acsv2_data_api')
}
else if (PROJECT == 'CHALLENGE') {
    getImageTag('acsv2_challenge_api')
}
else if (PROJECT == 'DATAWRITER') {
    getImageTag('acsv2_data_writer')
}
else if (PROJECT == 'DATAWRITERINITRX') {
    getImageTag('acsv2_data_writer')
}
else if (PROJECT == 'PENDING') {
    getImageTag('acsv2_pending_service')
}
else if (PROJECT == 'DECEXPTRANCOLLECTOR') {
    getImageTag('acsv2_dec_exp_tran_collector')
}
else if (PROJECT == 'DECEXPTRANHANDLER') {
    getImageTag('acsv2_dec_exp_tran_handler')
}
else if (PROJECT == 'DDC') {
    getImageTag('acsv2_ddc_api')
}


//######FOR ONE ECR######
// import groovy.json.JsonSlurper
// def ecr_repo='3dssv2_card_range_service_web_api'
// def aws_get_images = '''
//   export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
//   $(aws sts assume-role \
//   --role-arn arn:aws:iam::089465505731:role/IT-DEVOPS \
//   --role-session-name testsession \
//   --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
//   --output text))
//   aws ecr list-images --repository-name 3dssv2_card_range_service --region ap-southeast-1
// '''
// def ecr_images_json = ['bash', '-c', aws_get_images].execute()
// def data = new JsonSlurper().parseText(ecr_images_json.text)
// def pattern = '(?:jenkins)(?:_|-|.)(?:develop|qa|master)(?:_|-|.)|(?:v)(?:_|-)'
// def result = data.imageIds.imageTag.findAll() { it =~ pattern }
//   def customComparator = { a, b ->
//       def numberA = a.replaceAll(/[^0-9]/, '') as Integer
//       def numberB = b.replaceAll(/[^0-9]/, '') as Integer
//       return numberB - numberA
//   }
// return result.sort(customComparator)