module S3ImageOptimizer::Bucket
  class ImageCollector
    attr_accessor :images

    def initialize(bucket, path='/')
      @bucket = bucket
      @images = []
      @path = path
      collect_images()
    end

    def collect_images
      binding.pry
      @images = @bucket.objects(:prefix => @path).map(&:key)
      # aws_image_list.each do |aws_image|
      #   if aws_image_list.present?
      #     dir_path.images.create(:path => aws_image)}
      #   end
      # end
    end
  end
end