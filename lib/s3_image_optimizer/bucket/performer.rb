module S3ImageOptimizer::Bucket
  class Performer
    def initialize(bucket, path = '/')
      @bucket = bucket
      @path = path
    end
  end
end