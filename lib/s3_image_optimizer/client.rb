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
    dir: ENV['AWS_BUCKET_DIR'],
    tmp: "/tmp",
    optimize: {
      rename: {
        enabled: false,
        append: '-o'
      }
    },
    upload_bucket: ENV['AWS_UPLOAD_BUCKET']
  }
  def initialize(options = {})
    @options = DEFAULT_OPTIONS.merge(options)
    if @options[:dir].empty?
      @options[:dir] = nil
    elsif @options[:dir][-1] != '/'
      @options[:dir] += '/'
    end
    @options[:tmp_download_path] = "#{@options[:tmp]}/s3imageoptimizer"
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
    @s3_client = ::Aws::S3::Client.new(credentials: credentials, region: @options[:aws][:region])
    @s3_bucket = ::Aws::S3::Bucket.new(@options[:bucket], client: @s3_client)
  end

  def download_bucket_images
    @image_collector = S3ImageOptimizer::Bucket::ImageCollector.new(@s3_bucket, @options)
    @image_downloader = S3ImageOptimizer::Bucket::ImageDownloader.new(
      images: @image_collector.images, client: @s3_client, bucket: @s3_bucket,
      options: @options
      )
  end

  def optimize_downloaded_images
    @image_optimizer = S3ImageOptimizer::ImageOptimizer.new(@options)
    @image_optimizer.optimize_all(@image_downloader.downloaded_images)
  end

  def upload_optimized_images
    @image_uploader = S3ImageOptimizer::Bucket::ImageUploader.new(credentials, @s3_bucket, @options)
    @image_uploader.upload_all(@image_optimizer.optimized_images)
  end

  def cleanup
    FileUtils.rm_rf Dir.glob("#{@options[:tmp]}/s3imageoptimizer/*")
  end
end