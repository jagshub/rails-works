# frozen_string_literal: true

# API Docs
# - https://docs.aws.amazon.com/sdkforruby/api/Aws/S3/Client.html#put_object-instance_method
# - https://docs.aws.amazon.com/sdkforruby/api/Aws/S3/Client.html#delete_object-instance_method
module External::S3Api
  extend self

  S3_ACCESS_KEY = ENV.fetch('AWS_FILES_UPLOAD_ACCESS_KEY_ID')
  S3_SECRET_KEY = ENV.fetch('AWS_FILES_UPLOAD_SECRET_ACCESS_KEY')

  BUCKETS = {
    images: OpenStruct.new(
      access_key_id: S3_ACCESS_KEY,
      secret_access_key: S3_SECRET_KEY,
      region: 'us-east-1',
      bucket: 'ph-files',
      acl: 'public-read',
    ),
    avatars: OpenStruct.new(
      access_key_id: S3_ACCESS_KEY,
      secret_access_key: S3_SECRET_KEY,
      region: 'us-west-2',
      bucket: 'ph-avatars',
      acl: 'public-read',
    ),
    exports: OpenStruct.new(
      access_key_id: ENV.fetch('S3_AWS_ACCESS_KEY_ID'),
      secret_access_key: ENV.fetch('S3_AWS_SECRET_ACCESS_KEY'),
      region: 'us-east-1',
      bucket: 'ph-production-us-east-1-file-exports',
      acl: 'private',
    ),
    data_migrations: OpenStruct.new(
      access_key_id: ENV.fetch('S3_AWS_ACCESS_KEY_ID'),
      secret_access_key: ENV.fetch('S3_AWS_SECRET_ACCESS_KEY'),
      region: 'us-east-1',
      bucket: 'producthunt',
      acl: 'private',
    ),
    insights: OpenStruct.new(
      access_key_id: ENV.fetch('S3_AWS_ACCESS_KEY_ID'),
      secret_access_key: ENV.fetch('S3_AWS_SECRET_ACCESS_KEY'),
      region: 'us-east-1',
      bucket: 'ph-insights',
      acl: 'authenticated-read',
    ),
  }.freeze

  def generate_key
    SecureRandom.uuid
  end

  def presign(extname)
    uuid = SecureRandom.uuid
    filename = "#{ uuid }.#{ extname }"
    upload_key = Pathname.new('').join(filename).to_s

    config = config_for_bucket(:images)
    obj = config.resource.bucket('ph-files').object(upload_key)

    params = { acl: 'public-read' }

    {
      uuid: uuid,
      presigned_url: obj.presigned_url(:put, params),
      public_url: obj.public_url,
      filename: filename,
      error: nil,
    }
  end

  def put_object(bucket:, key:, body:, content_type:)
    config = config_for_bucket(bucket)
    config.client.put_object(
      bucket: config.bucket,
      key: key,
      acl: config.acl,
      content_type: content_type,
      body: body,
    )

    key
  end

  def delete_object(bucket:, key:)
    config = config_for_bucket(bucket)
    config.client.delete_object(
      bucket: config.bucket,
      key: key,
    )

    key
  end

  def copy_object(bucket:, existing_key:, new_key:)
    config = config_for_bucket(bucket)
    config.client.copy_object(
      bucket: config.bucket,
      acl: config.acl,
      copy_source: "/#{ config.bucket }/#{ existing_key }",
      key: new_key,
    )

    new_key
  end

  def get_object(bucket:, key:)
    config = config_for_bucket(bucket)
    config.client.get_object(bucket: bucket, key: key)
  end

  def signed_url(bucket:, key:, expires_in: 900, file_name: nil)
    config = config_for_bucket(bucket)

    object = config.resource.bucket(config.bucket).object(key)
    object.presigned_url(:get, response_content_disposition: disposition_for(file_name), expires_in: expires_in)
  end

  private

  def config_for_bucket(bucket)
    Config.new(BUCKETS.fetch(bucket))
  end

  def disposition_for(file_name)
    if file_name.present?
      %(inline; filename="#{ file_name }")
    else
      'inline'
    end
  end

  class Config
    delegate :bucket, :acl, to: '@config'

    def initialize(config)
      @config = config
    end

    def client
      @client ||= Aws::S3::Client.new(
        access_key_id: @config.access_key_id,
        secret_access_key: @config.secret_access_key,
        region: @config.region,
      )
    end

    def resource
      @resource ||= Aws::S3::Resource.new(
        access_key_id: @config.access_key_id,
        secret_access_key: @config.secret_access_key,
        region: @config.region,
      )
    end
  end
end
