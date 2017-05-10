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
    },
    bucket: nil,
    dir: nil,
    tmp_paths: {
      download_path: "/tmp/s3imageoptimizer/downloaded_images",
      optimize_path: "/tmp/s3imageoptimizer/optimized_images"
    },
    optimize: {
      rename: {
        append: '-o'
      }
    }
  }
  def initialize(options = {})
    @options = DEFAULT_OPTIONS.merge(options)
    if @options[:dir] && @options[:dir][-1] != '/'
      @options[:dir] += '/'
    end
    raise ArgumentError.new("bucket is required") unless @options[:bucket]
    connect()
  end

  def optimize!
    download_bucket_images()
    optimize_downloaded_images()
    upload_optimized_images()
    cleanup()
    true
  end

  def credentials
    @credentials ||= ::Aws::Credentials.new(@options[:aws][:access_key_id], @options[:aws][:secret_access_key])
  end

  def connect
    @s3_client = ::Aws::S3::Client.new(:credentials => credentials, :region => @options[:aws][:region])
    @s3_bucket = ::Aws::S3::Bucket.new(@options[:bucket], :client => @s3_client)
  end

  def download_bucket_images(path = @options[:dir])
    @image_collector = S3ImageOptimizer::Bucket::ImageCollector.new(@s3_bucket, path)
    @image_downloader = S3ImageOptimizer::Bucket::ImageDownloader.new(
      images: @image_collector.images, client: @s3_client, bucket: @s3_bucket,
      path: path, tmp_paths: @options[:tmp_paths], optimize_opts: @options[:optimize]
      )
  end

  def optimize_downloaded_images
    @image_optimizer = S3ImageOptimizer::ImageOptimizer.new(@options[:optimize],
      tmp_paths: @options[:tmp_paths]
      )
    @image_optimizer.optimize_all(@image_downloader.downloaded_images)
  end

  def upload_optimized_images(path = @options[:dir])
    @image_uploader = S3ImageOptimizer::Bucket::ImageUploader.new(
      client: @s3_client, bucket: @s3_bucket, path: path, tmp_paths: @options[:tmp_paths],

      )
    @image_uploader.upload_all(@image_optimizer.optimized_images)
  end

  def cleanup
    FileUtils.rm_rf Dir.glob("/tmp/s3imageoptimizer/*")
  end
end