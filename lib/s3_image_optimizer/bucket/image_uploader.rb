require "mimemagic"

module S3ImageOptimizer::Bucket
  class ImageUploader < Performer
    attr_accessor :uploaded_images

    DEFAULT_OPTIONS = {
      aws: {
        acl: ENV['AWS_ACL'] || nil
      }
    }


    def initialize(credentials, bucket, options = {})
      super(bucket, DEFAULT_OPTIONS.merge(options))
      @client = ::Aws::S3::Client.new(credentials: credentials, region: @options[:aws][:region])
      if @options[:upload_bucket]
        @upload_bucket = @options[:upload_bucket]
      else
        @upload_bucket = @bucket.name
      end
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
      s3 = Aws::S3::Resource.new(client: @client, region: @options[:aws][:region])
      k = image.split("#{@options[:tmp_download_path]}/s3imageoptimizer").last[1..-1]

      if s3.bucket(@upload_bucket).object(k).upload_file(image, file_options)
        puts "Uploaded #{image}"
      else
        puts "Failed to upload #{image}"
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