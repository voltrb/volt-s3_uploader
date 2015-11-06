module S3Uploader
  class S3BucketManager
    def self.ensure_bucket(bucket_name)
      prop_key = "s3_bucket_#{bucket_name}"
      unless Volt.current_app.properties[prop_key]
        Volt.logger.info("Creating/Setting up S3 Bucket: #{bucket_name}")

        creds = Aws::Credentials.new(Volt.config.s3.key, Volt.config.s3.secret)
        s3 = Aws::S3::Resource.new(region: 'us-east-1', credentials: creds)

        s3.create_bucket(
          {
            acl: "private", # accepts private, public-read, public-read-write, authenticated-read
            bucket: bucket_name, # required
            # create_bucket_configuration: {
            #   location_constraint: "us-east-1", # accepts EU, eu-west-1, us-west-1, us-west-2, ap-southeast-1, ap-southeast-2, ap-northeast-1, sa-east-1, cn-north-1, eu-central-1
            # },
            # grant_full_control: "GrantFullControl",
            # grant_read: "GrantRead",
            # grant_read_acp: "GrantReadACP",
            # grant_write: "GrantWrite",
            # grant_write_acp: "GrantWriteACP",
          }
        )

        bucket = s3.bucket(bucket_name)

        bucket.cors.put(
          {
            bucket: bucket_name,
            cors_configuration: {
              cors_rules: [
                {
                  allowed_origins: ["*"],
                  allowed_methods: ["GET", "POST", "PUT"], # required
                  allowed_headers: ["*"]
                },
              ],
            }
          }
        )

        Volt.current_app.properties[prop_key] = '1'
      end
    end
  end
end
