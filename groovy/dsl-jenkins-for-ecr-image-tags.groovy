            'com.cwctravel.hudson.plugins.extended__choice__parameter.ExtendedChoiceParameterDefinition'(plugin: 'extended-choice-parameter@0.82') {
                delegate.name('ecr_images')
                delegate.defaultValue('')
                delegate.description('Choose ecr image by tag')
                delegate.quoteValue(false)
                delegate.saveJSONParameterToFile(false)
                delegate.type('PT_SINGLE_SELECT')
                delegate.groovyScript("""import com.amazonaws.services.ecr.AmazonECR;
                                          import com.amazonaws.services.ecr.AbstractAmazonECR;
                                          import com.amazonaws.services.ecr.AmazonECRClient;
                                          import com.amazonaws.services.ecr.model.ListImagesRequest;
                                          import com.amazonaws.services.ecr.model.ListImagesResult;
                                          import com.amazonaws.services.ecr.AmazonECRClientBuilder;
                                          import com.amazonaws.regions.Region;
                                          import com.amazonaws.regions.RegionUtils;
                                          import com.amazonaws.regions.Regions;
                                          import jenkins.model.*

                                          AmazonECR client = AmazonECRClientBuilder.standard().withRegion("ap-southeast-1").build();
                                          ListImagesRequest request = new ListImagesRequest().withRepositoryName("nearme_admin_api");
                                          res = client.listImages(request);


                                          def result = []
                                          for (image in res) {
                                          result.add(image.getImageIds());
                                          }

                                          return result[0].imageTag;
                                         """)
            }