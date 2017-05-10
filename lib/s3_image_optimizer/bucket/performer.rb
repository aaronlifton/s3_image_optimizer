module S3ImageOptimizer::Bucket
  class Performer
    def initialize(bucket, path = '/', tmp_paths=nil)
      @bucket = bucket
      @path = path
      @tmp_paths = tmp_paths
    end
  end
end