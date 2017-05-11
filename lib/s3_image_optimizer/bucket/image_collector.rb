require_relative 'performer'
module S3ImageOptimizer::Bucket
  class ImageCollector < Performer
    attr_accessor :images

    def initialize(bucket, options)
      super
      @images = []
      collect_images(@options[:dir])
    end

    def collect_images(prefix)
      @images = @bucket.objects(:prefix => prefix).map(&:key)
    end
  end
end