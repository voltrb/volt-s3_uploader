require 'cgi'

class S3UploadTasks < Volt::Task
  EXPIRE_TIME=(60 * 5) # 5 minutes
  S3_URL='http://s3.amazonaws.com'
  S3_BUCKET = 'volt-test1'
  PREFIX = 'something'
  LIMIT = 100 * 1024 * 1024 # 100 MB

  def sign(filename, mime_type)
    extname = File.extname(filename)
    filename = "#{SecureRandom.uuid}#{extname}"
    upload_key = Pathname.new(PREFIX).join(filename).to_s

    creds = Aws::Credentials.new(S3_KEY, S3_SECRET)
    s3 = Aws::S3::Resource.new(region: 'us-east-1', credentials: creds)
    obj = s3.bucket(S3_BUCKET).object(upload_key)

    params = { acl: 'public-read' }
    # params[:content_length] = LIMIT if LIMIT

    [obj.presigned_url(:put, params), obj.public_url]
  end
end