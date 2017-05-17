require "mimemagic"

module S3ImageOptimizer::Bucket
  class ImageUploader < Performer
    attr_accessor :uploaded_images

    DEFAULT_OPTIONS = {
      aws: {
        acl: ENV['AWS_ACL'] || 'public-read'
      }
    }


    def initialize(credentials, bucket, options = {})
      super(bucket, DEFAULT_OPTIONS.merge(options))
      @client = ::Aws::S3::Client.new(credentials: credentials, region: @options[:aws][:region])

      @marker_file = "uploaded.txt"
      @uploaded_files = []
      if File.exists?(File.join(Dir.pwd, @marker_file))
        File.foreach(File.join(Dir.pwd, @marker_file)) do |line|
          @uploaded_files << line
        end
        # @marker = File.open(File.join(Dir.pwd, @marker_file), 'w') {|f| f }
      else
        @marker = File.open(File.join(Dir.pwd, @marker_file), 'w') {|f| f.write('') }
      end
      @failed_marker_file = "failed.txt"
      @failed_marker = File.open(File.join(Dir.pwd, @failed_marker_file), 'w')

      if @options[:upload_bucket] && !@options[:upload_bucket].empty?
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
      puts "\nDone!"
    end

    def upload_image(image)
      return unless image
      if @uploaded_files.include?(image + "\n")
        puts "Already uploaded #{image}"
        return false
      end
      file_options = get_file_options(image)
      s3 = Aws::S3::Resource.new(client: @client, region: @options[:aws][:region])
      k = image.split(@options[:tmp_download_path]).last[1..-1]
      begin
        if s3.bucket(@upload_bucket).object(k).upload_file(image, file_options)
          puts "Uploaded #{image}"
          File.open(File.join(Dir.pwd, @marker_file), 'a') { |f| f << image + "\n" }
          true
        else
          handle_failure(image)
        end
      rescue
        handle_failure(image)
      end
    end

    def handle_failure(image)
      puts "Failed to upload #{image}"
      File.open(File.join(Dir.pwd, @failed_marker_file), 'a') { |f| f << image + "\n" }
      false
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
        begin
          mime_magic = MimeMagic.by_magic(f)
          typ = mime_magic.type if mime_magic
        rescue
        end
      end
      typ
    end
  end
end