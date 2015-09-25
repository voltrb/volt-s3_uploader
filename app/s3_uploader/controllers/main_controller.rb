module S3Uploader
  class MainController < Volt::ModelController
    reactive_accessor :progress
    reactive_accessor :message
    reactive_accessor :s3_url
    attr_accessor :uploading_promise

    if RUBY_PLATFORM == 'opal'

      def upload(event)
        target = event.target
        set_progress(0, 'Upload started')

        file = nil
        `
          var files = target.files;

          var output = [];
          for (var i = 0, f; file = files[i]; i++) {
            #{upload_file(file)}
          }
        `
      end

      def upload_file(file)
        self.uploading_promise = Promise.new

        S3UploadTasks.sign(`file.name`, `file.type`).then do |private_and_public|
          self.s3_url = private_and_public[1]
          upload_with_url(file, private_and_public[0])
        end.fail do |err|
          set_progress(0, 'Could not contact signing script. Status = ' + err.to_s)
        end
      end

      def upload_with_url(file, signed_url)
        # create PUT request to S3
        `
        console.log('type: ', file.type);
        var xhr = new XMLHttpRequest();
        xhr.open('PUT', signed_url);
        xhr.setRequestHeader('Content-Type', file.type);

        xhr.onload = function() {
          if (xhr.status == 200) {
            #{uploaded}
          }
        };

        xhr.onerror = function(err) {
          console.log('err1');
          console.log('err: ', err);
          #{error(err)}
        };

        xhr.upload.onprogress = function(e) {
          console.log('onprogress');

          if (e.lengthComputable) {
            #{percentLoaded = `Math.round((e.loaded / e.total) * 100)`};
            #{set_progress(percentLoaded, percentLoaded == 100 ? 'Finalizing.' : "Uploading: #{percentLoaded}")}
          }
        };

        xhr.send(file);
        `

        nil
      end

      # Resolve the uploading promise
      def uploaded
        promise = self.uploading_promise
        self.uploading_promise = nil

        set_progress(100, 'Uploaded...', true)
        promise.resolve(nil)
      end

      def error(msg)
        msg = msg.to_s
        promsise = self.uploading_promise
        self.upload_promise = nil

        set_progress(0, msg, true)
        uploading_promise.reject(msg)
      end

      def set_progress(progress, message, done=false)
        self.progress = progress
        self.message = message

        if attrs.respond_to?(:value)
          attrs.value = [progress, done ? s3_url : nil, @uploading_promise]
        end
      end
    end
  end
end
