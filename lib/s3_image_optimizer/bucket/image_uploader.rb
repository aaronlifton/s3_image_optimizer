require "mimemagic"

module S3ImageOptimizer::Bucket
  class ImageUploader < Performer
    attr_accessor :uploaded_images

    DEFAULT_OPTIONS = {
      aws: {
        acl: ENV['AWS_ACL'] || nil
      }
    }


    def initialize(client:, bucket:, path:, options: {}, tmp_paths:)
      super(bucket, path, tmp_paths)
      @s3_client = client
      @options = DEFAULT_OPTIONS.merge(options)
      @uploaded_images = []
    end

    def upload_all(images = [])
      puts "\nUploading..."
      @uploaded_images = images.each do |i|
        upload_image(i)
      end
    end

    def upload_image(image)
      return unless image
      file_options = get_file_options(image)
      s3 = Aws::S3::Resource.new
      k = image.split(@tmp_paths[:optimize_path]).last[1..-1]
      s3.bucket(@bucket.name).object(k).upload_file(image, file_options)
      puts "Uploaded #{image}"
    end

    def get_file_options(image)
      opts = {:content_type => get_content_type(image)}
      if @options[:aws][:acl]
        opts[:acl] = @options[:aws][:acl]
      end
      opts
    end


    def get_content_type(file)
      typ = nil
      File.open(file, 'r') do |f|
        mime_magic = MimeMagic.by_magic(f)
        typ = mime_magic.type if mime_magic
      end
      typ
    end
  end
end