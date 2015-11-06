require 'cgi'
require 'securerandom'

class S3UploadTasks < Volt::Task
  EXPIRE_TIME = (60 * 5) # 5 minutes
  S3_URL = 'http://s3.amazonaws.com'
  LIMIT = 100 * 1024 * 1024 # 100 MB

  BUCKETS = Volt.config.s3.buckets

  def sign(bucket_name, filename, mime_type)
    s3 = Volt.config.s3.to_h

    buckets = s3[:buckets]
    key = s3[:key]
    secret = s3[:secret]

    [:buckets, :key, :secret].each do |prop|
      unless s3[prop]
        raise "s3_upload configure issue: Please configure Volt.config.s3.#{prop.to_s}"
      end
    end

    unless buckets.include?(bucket_name)
      raise "The bucket passed in (#{bucket_name.inspect}) does not match the list of supported buckets"
    end

    extname = File.extname(filename)
    filename = "#{SecureRandom.uuid}#{extname}"
    upload_key = Pathname.new(filename).to_s

    creds = Aws::Credentials.new(Volt.config.s3.key, Volt.config.s3.secret)
    s3 = Aws::S3::Resource.new(region: 'us-east-1', credentials: creds)
    bucket = s3.bucket(bucket_name)

    obj = bucket.object(upload_key)

    params = { acl: 'public-read' }
    # params[:content_length] = LIMIT if LIMIT

    [obj.presigned_url(:put, params), obj.public_url]
  end
end
