require 's3_image_optimizer/version'
require 's3_image_optimizer/client'
require 's3_image_optimizer/bucket'
require 'aws-sdk'
require 'pry'
module S3ImageOptimizer
  class << self
    DEFAULT_OPTIONS = {
      bucket: ENV['AWS_BUCKET'],
      dir: ENV['AWS_BUCKET_DIR']
    }
    def optimize_bucket!(options = {})
      options = DEFAULT_OPTIONS.merge(options)
      client = S3ImageOptimizer::Client.new(options)
      client.optimize!
    end

    def upload_all!(options = {})
      options = DEFAULT_OPTIONS.merge(options)
      client = S3ImageOptimizer::Client.new(options)
      client.upload_optimized_images
    end

    def optimize_dir!(path = Dir.pwd)
      images = Dir.glob("#{path}/**/*.*")
      @image_optimizer = S3ImageOptimizer::ImageOptimizer.new
      images.each do |i|
        @image_optimizer.optimize_image(i)
      end
    end
  end
end
