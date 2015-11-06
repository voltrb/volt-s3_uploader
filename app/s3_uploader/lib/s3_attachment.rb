# Included into Volt::Model to provide ```attachment```
require 's3_uploader/lib/s3_bucket_manager' unless RUBY_PLATFORM == 'opal'

module S3Uploader
  module S3Attachment
    module ClassMethods
      def attachment(name, bucket)
        unless RUBY_PLATFORM == 'opal'
          # Create the bucket and set the CORS policy if needed
          Volt.current_app.once('post_boot') do
            S3BucketManager.ensure_bucket(bucket)
          end
        end

        url_field_name = :"#{name}_url"
        field(url_field_name, String)

        upload_percent_field_name = :"#{name}_upload_percent"
        reactive_accessor(upload_percent_field_name)

        promise_field_name = :"#{name}_uploading_promise"
        attr_accessor(promise_field_name)

        # Create a method that returns the bucket passed in
        define_method(:"#{name}_bucket") do
          bucket
        end

        unless RUBY_PLATFORM == 'opal'
          s3 = Volt.config.s3
          current_buckets = (s3 ? s3.to_h[:buckets] : nil) || []
          current_buckets << bucket

          Volt.configure do |config|
            config.s3.buckets = current_buckets
          end
        end

        # An aggrate method is created for assigning to the value="{{ name }}"
        # property of the tag.
        define_method(name) do
          url = send(url_field_name)
          upload_percent = send(upload_percent_field_name)
          [url, upload_percent]
        end

        define_method(:"#{name}=") do |val|
          send(:"#{upload_percent_field_name}=", val[0])
          send(:"#{url_field_name}=", val[1])
          send(:"#{promise_field_name}=", val[2])
        end

        validate do
          # MainController (linked via the value attribute on the s3-upload tag)
          # will set a promise, which it resolves when the file is upload (if it
          # is uploading).
          promise = send(promise_field_name)

          if promise.is_a?(Promise) && !promise.realized?
            promise = promise.then do
              puts "Uploaded"
              trigger!("uploaded_#{name}")
            end
          end

          # return the promise
          promise
        end
      end
    end

    def self.included(base)
      base.send(:extend, ClassMethods)
    end
  end
end

Volt::Model.include(S3Uploader::S3Attachment)
