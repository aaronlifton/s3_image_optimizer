module S3ImageOptimizer::Bucket
  class Performer
    def initialize(bucket, options={})
      @bucket = bucket
      @options = options
    end
  end
end