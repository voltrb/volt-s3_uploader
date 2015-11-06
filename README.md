# S3 Uploader

This gem provides a simple way to upload files directly from the browser to s3.  Going straight to s3 simplifies serving and makes it easier to deploy to read only PaaS's like heroku.  While s3 upload is usually more compilcated, this gem tries to make it simple.  It only uploads files and does not do resizing.  You can handle resizing with the volt-s3_image_resizer gem.

## How it works

When an app with this gem boots, it checks the s3 api and if needed configures the buckets to support CORS.  Before a file upload starts, this gem hits a task that returns a signed upload url.  The url allows the browser to upload the file directly to s3.


TODO:
When the model does save on the server, the gem will add a meta-data to the file to mark it as a permenant file.  The gem includes a task to periodically clean uploaded files that never had their associated models saved.

## Setup

Signup for an S3 account, and generate a aws key and secret.

In ```config/app.rb``` add:

```ruby
Volt.config.s3.key = ''
Volt.config.s3.secret = ''
```

In the component you want to use the uploader from, add:

```ruby
component 's3_uploader'
```

In the model you wish to attach the file to, add:

```ruby
attachment :file, 'bucket_name_' + Volt.env.to_s
```

Make sure the bucket name is unique, otherwise it will be taken.  Adding the ENV helps make dev/testing work easier.