require 'image_optim'

class S3ImageOptimizer::ImageOptimizer
  attr_accessor :optimized_images

  DEFAULT_OPTIONS = {
      image_optim: {
        skip_missing_workers: true,
        advpng: false,
        gifsicle: false,
        jhead: false,
        jpegoptim: {
          allow_lossy: true,
          max_quality: 50
        },
        jpegrecompress: false,
        jpegtran: false,
        optipng: false,
        pngcrush: false,
        pngout: false,
        pngquant: false,
        svgo: false
      },
      rename: {
        append: '-o'
      }
  }.freeze

  def initialize(options = {})
    @options = DEFAULT_OPTIONS.merge(options)
    @image_optim = ImageOptim.new(@options[:image_optim])
  end

  def optimize_all(images = [])
    @dir ||= FileUtils.mkdir_p("/tmp/s3imageoptimizer/optimized_images")
    @optimized_images = images.each do |i|
      original_name = File.basename(i)
      new_name = rename(original_name)
      optimized_image = @image_optim.optimize_image(i)
      puts "%-50s %s %40s" % ["#{i.path}", ('-'*3)+'>', "/tmp/s3imageoptimizer/optimized_images/#{new_name}"]
      FileUtils.mv(optimized_image, "/tmp/s3imageoptimizer/optimized_images/#{new_name}")
    end
  end

  def rename(filename)
    if @options[:rename]
      if @options[:rename][:append]
        filename.split('.').first + @options[:rename][:append] + '.' + filename.split('.')[1..-1].join('.')
      else
        filename
      end
    else
      filename
    end
  end
end