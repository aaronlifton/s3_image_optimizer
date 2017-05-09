require 'dotenv/load'
require_relative 'bucket/image_collector'

class S3ImageOptimizer::Client
  attr_accessor :image_collector

  DEFAULT_OPTIONS = {
    aws: {
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_REGION'],
      bucket: ENV['AWS_BUCKET'],
      dir: ENV['AWS_BUCKET_DIR']
    }
  }
  def initialize(options = {})
    @options = DEFAULT_OPTIONS.merge(options)
    connect()
    collect_bucket_images()
  end

  def credentials
    @credentials ||= ::Aws::Credentials.new(@options[:aws][:access_key_id], @options[:aws][:secret_access_key])
  end

  def connect
    @s3_client = ::Aws::S3::Client.new(:credentials => credentials, :region => @options[:aws][:region])
    @s3_bucket = ::Aws::S3::Bucket.new(@options[:aws][:bucket], :client => @s3_client)
  end

  def collect_bucket_images(path = @options[:aws][:dir])
    @image_collector = S3ImageOptimizer::Bucket::ImageCollector.new(@s3_bucket, path)
  end
end