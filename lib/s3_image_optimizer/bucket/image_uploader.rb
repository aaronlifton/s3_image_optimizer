require "mimemagic"

module S3ImageOptimizer::Bucket
  class ImageUploader < Performer
    attr_accessor :uploaded_images

    DEFAULT_OPTIONS = {
      aws: {
        acl: ENV['AWS_ACL'] || nil
      }
    }


    def initialize(client:, bucket:, path:, options: {})
      super(bucket, path)
      @s3_client = client
      @options = DEFAULT_OPTIONS.merge(options)
      @uploaded_images = []
    end

    def upload_all(images = [])
      @uploaded_images = images.each do |i|
        upload_image(i)
      end
    end

    def upload_image(image)
      file_options = get_file_options(image)
      binding.pry
      s3_obj = Aws::S3::Object.new(@bucket.name, @path, :client => @s3_client)
      s3_obj.upload_file(image.path, file_options)
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