# Included into Volt::Model to provide ```attachment```
module S3Uploader
  module S3Attachment
    module ClassMethods
      def attachment(name, bucket)
        path_field_name = :"#{name}_path"
        field(path_field_name)

        upload_percent_field_name = :"#{name}_upload_percent"
        reactive_accessor(upload_percent_field_name)

        promise_field_name = :"#{name}_uploading_promise"
        attr_accessor(promise_field_name)

        # Create a method that returns the bucket passed in
        define_method(:"#{name}_bucket") do
          bucket
        end

        # An aggrate method is created for assigning to the value="{{ name }}"
        # property of the tag.
        define_method(name) do
          path = send(path_field_name)
          upload_percent = send(upload_percent_field_name)
          [path, upload_percent]
        end

        define_method(:"#{name}=") do |val|
          send(:"#{upload_percent_field_name}=", val[0])
          send(:"#{path_field_name}=", val[1])
          send(:"#{promise_field_name}=", val[2])
        end

        validate do
          # MainController (linked via the value attribute on the s3-upload tag)
          # will set a promise, which it resolves when the file is upload (if it
          # is uploading).
          send(promise_field_name)
        end
      end
    end

    def self.included(base)
      base.send(:extend, ClassMethods)
    end
  end
end

Volt::Model.include(S3Uploader::S3Attachment)