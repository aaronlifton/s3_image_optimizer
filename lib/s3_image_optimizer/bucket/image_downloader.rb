module S3ImageOptimizer::Bucket
  class ImageDownloader < Performer
    attr_accessor :downloaded_images

    def initialize(images: [], client:, bucket:, options: {})
      super(bucket, options)
      @s3_client = client
      @images = images
      @downloaded_images = []
      @optimize_opts = @options[:optimize]
      download_images()
    end

    def download_images
      puts "\nDownloading..."
      @images.select {|i| is_image?(i) && !is_already_optimized?(i) }.each do |i|
        if File.exist?(File.join(@options[:tmp_download_path], i))
          puts "Already downloaded #{i}"
          @downloaded_images << File.open(File.join(@options[:tmp_download_path], i))
          next
        end
        s3_object = @s3_client.get_object({:key => i, :bucket => @bucket.name})
        @downloaded_images << create_file(s3_object.body, i)
      end
    end

    private

    def is_image?(image)
      ['jpg','jpeg','gif','png'].include?(image.split('.').last)
    end

    def is_already_optimized?(image)
      return false unless @optimize_opts[:rename][:append]
      image.split('.')[-2][-@optimize_opts[:rename][:append].length..-1] == @optimize_opts[:rename][:append]
    end

    def create_file(s3_object, key)
      download_path = @options[:tmp_download_path]
      @dir ||= FileUtils.mkdir_p(download_path)
      FileUtils.mkdir_p("#{download_path}/#{key.split('/')[0...-1].join('/')}")
      file = File.new("#{download_path}/#{key}",'w')
      file.binmode
      file.write(s3_object.read)
      file.close
      puts "%-50s %s %40s" % ["#{key}", ('-'*3)+'>', "#{file.path}"]
      file
    end
  end
end