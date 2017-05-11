require 's3_image_optimizer/version'
require 's3_image_optimizer/client'
require 's3_image_optimizer/bucket'
require 'aws-sdk'

module S3ImageOptimizer
  class << self
    DEFAULT_OPTIONS = {
      bucket: ENV['AWS_BUCKET'],
      dir: nil
    }
    def optimize_bucket!(options = {})
      options = DEFAULT_OPTIONS.merge(options)
      client = S3ImageOptimizer::Client.new(options)
      client.optimize!
    end
  end
end
