module S3ImageOptimizer::Bucket
  class ImageDownloader < Performer
    attr_accessor :downloaded_images

    def initialize(images: [], client:, bucket:, path:)
      super(bucket, path)
      @s3_client = client
      @images = images
      @downloaded_images = []
      download_images()
    end

    def download_images
      @images.select {|i| is_image?(i) }.each do |i|
        s3_object = @s3_client.get_object({:key => i, :bucket => @bucket.name})
        @downloaded_images << create_file(s3_object.body, i)
      end
    end

    private

    def is_image?(image)
      ['jpg','jpeg','gif','png'].include?(image.split('.').last)
    end

    def create_file(s3_object, path)
      @dir ||= FileUtils.mkdir_p("/tmp/s3imageoptimizer/downloaded_images")
      file = File.new("/tmp/s3imageoptimizer/downloaded_images/#{File.basename(path)}",'w')
      file.binmode
      file.write(s3_object.read)
      file.close
      puts "%-50s %s %40s" % ["#{path}", ('-'*3)+'>', "#{file.path}"]
      file
    end
  end
end