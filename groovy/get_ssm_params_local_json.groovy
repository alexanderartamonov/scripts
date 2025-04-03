//working solution
 import groovy.json.JsonSlurper
  def restResponse = "{\n    \"basepath\": [\n        \"ikea\",\n        \"translations\",\n        \"lazadaph\",\n        \"amway\",\n        \"ant\"\n    ]\n}"
  def obj = new JsonSlurper().parseText(restResponse)
  def list = obj.basepath
    list.each { println it }
    return list



