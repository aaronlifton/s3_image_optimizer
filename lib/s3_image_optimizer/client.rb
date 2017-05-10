require 'dotenv/load'
require_relative 'bucket/image_collector'
require_relative 'image_optimizer'

class S3ImageOptimizer::Client
  attr_accessor :image_collector, :image_downloader, :image_optimizer, :image_uploader

  DEFAULT_OPTIONS = {
    aws: {
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_REGION'],
      bucket: ENV['AWS_BUCKET'],
      dir: ENV['AWS_BUCKET_DIR'] || '/'
    }
  }
  def initialize(options = {})
    @options = DEFAULT_OPTIONS.merge(options)
    connect()
  end

  def perform
    download_bucket_images()
    optimize_downloaded_images()
    upload_optimized_images()
    cleanup()
  end

  def credentials
    @credentials ||= ::Aws::Credentials.new(@options[:aws][:access_key_id], @options[:aws][:secret_access_key])
  end

  def connect
    @s3_client = ::Aws::S3::Client.new(:credentials => credentials, :region => @options[:aws][:region])
    @s3_bucket = ::Aws::S3::Bucket.new(@options[:aws][:bucket], :client => @s3_client)
  end

  def download_bucket_images(path = @options[:aws][:dir])
    @image_collector = S3ImageOptimizer::Bucket::ImageCollector.new(@s3_bucket, path)
    @image_downloader = S3ImageOptimizer::Bucket::ImageDownloader.new(
      images: @image_collector.images, client: @s3_client, bucket: @s3_bucket,
      path: path
      )
  end

  def optimize_downloaded_images(path = @options[:aws][:dir])
    @image_optimizer = S3ImageOptimizer::ImageOptimizer.new
    @image_optimizer.optimize_all(@image_downloader.downloaded_images)
  end

  def upload_optimized_images(path = @options[:aws][:dir])
    @image_uploader = S3ImageOptimizer::Bucket::ImageUploader.new(
      client: @s3_client, bucket: @s3_bucket, path: path
      )
    @image_uploader.upload_all(@image_optimizer.optimized_images)
  end

  def cleanup
    FileUtils.rm_rf Dir.glob("/tmp/s3imageoptimizer/*")
  end
end