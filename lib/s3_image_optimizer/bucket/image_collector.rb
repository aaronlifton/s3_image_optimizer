require_relative 'performer'
module S3ImageOptimizer::Bucket
  class ImageCollector < Performer
    attr_accessor :images

    def initialize(bucket, path)
      super
      @images = []
      collect_images()
    end

    def collect_images
      @images = @bucket.objects(:prefix => @path).map(&:key)
    end
  end
end