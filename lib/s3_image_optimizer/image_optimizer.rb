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

  def initialize(options = {}, tmp_paths: nil)
    @options = DEFAULT_OPTIONS.merge(options)
    @tmp_paths = tmp_paths
    @image_optim = ImageOptim.new(@options[:image_optim])
  end

  def optimize_all(images = [])
    puts "\nOptimizing..."
    optimized_path = @tmp_paths[:optimize_path]
    @dir ||= FileUtils.mkdir_p(optimized_path)
    @optimized_images = images.map do |i|
      original_path = i.path
      optimized_image = @image_optim.optimize_image(i)
      if optimized_image
        new_path = "#{i.path.split('/')[0...-1].join('/')}".gsub("downloaded_images", "optimized_images")
        FileUtils.mkdir_p(new_path)
        mv_loc = File.join(new_path, rename(File.basename(i)))
        FileUtils.mv(optimized_image, mv_loc)
        puts "%-50s %s %40s" % ["#{i.path}", ('-'*3)+'>', mv_loc]
        mv_loc
      else
        puts "Failed to optimize #{original_path}"
      end
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