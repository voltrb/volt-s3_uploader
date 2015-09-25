# If you need to require in code in the gem's app folder, keep in mind that
# the app is not on the load path when the gem is required.  Use
# app/{gemname}/config/initializers/boot.rb to require in client or server
# code.
#
# Also, in volt apps, you typically use the lib folder in the
# app/{componentname} folder instead of this lib folder.  This lib folder is
# for setting up gem code when Bundler.require is called. (or the gem is
# required.)
#
# If you need to configure volt in some way, you can add a Volt.configure block
# in this file.

require 'aws-sdk'

module Volt
  module S3Uploader
    def self.setup(key, secret)
      Aws.config.update({
        region: 'us-east-1',
        credentials: Aws::Credentials.new(key, secret),
      })

      s3 = Aws::S3::Client.new

      # Create incase it doesn't exist
      # MOVE TO CREATE ON FAIL
      s3.create_bucket({
        acl: "public-read", # accepts private, public-read, public-read-write, authenticated-read
        bucket: "volt-test1", # required
        # create_bucket_configuration: {
        #   location_constraint: "us-east-1", # accepts EU, eu-west-1, us-west-1, us-west-2, ap-southeast-1, ap-southeast-2, ap-northeast-1, sa-east-1, cn-north-1, eu-central-1
        # },
        # grant_full_control: "GrantFullControl",
        # grant_read: "GrantRead",
        # grant_read_acp: "GrantReadACP",
        # grant_write: "GrantWrite",
        # grant_write_acp: "GrantWriteACP",
      })

      # TEST_BUCKET = s3.bucket

      # s3.get_bucket_cors(bucket: 'volt-test1')

      s3.put_bucket_cors({
        bucket: 'volt-test1', # required
        cors_configuration: {
          cors_rules: [
            {
              allowed_headers: ["*"],
              allowed_methods: ["GET", "POST", "PUT"],
              allowed_origins: ["*"]
            },
          ],
        }
      })
    end
  end
end
