require 'image_optim'

class S3ImageOptimizer::ImageOptimizer
  attr_accessor :optimized_images

  DEFAULT_OPTIONS = {
    image_optim: {
      skip_missing_workers: true,
      advpng: false,
      gifsicle: {
        level: 3,
        careful: false
      },
      jhead: true,
      jpegoptim: {
        allow_lossy: true,
        max_quality: 50
      },
      jpegrecompress: false,
      jpegtran: false,
      optipng: false,
      # pngcrush: {
      #   chunks: :alla,
      #   fix: false,
      #   brute: false,
      #   blacken: true
      # },
      pngcrush: false,
      # pngquant: {
      #   allow_lossy: true,
      #   quality: 10..100,
      #   speed: 3
      # },
      pngout: false,
      pngquant: false,
      svgo: false
    },
    nice_image_optim: {
      jpegoptim: {
        allow_lossy: true,
        max_quality: 85
      }
    }
  }.freeze

  def initialize(options = {})
    @options = options.merge(DEFAULT_OPTIONS)
    @image_optim = ImageOptim.new(@options[:image_optim])
    if @options[:nice_settings]
      @options[:nice_image_optim][:jpegoptim] = {
        allow_lossy: @options[:nice_settings][:lossy],
        max_quality: @options[:nice_settings][:quality]
      }
    end
    @nice_image_optim = ImageOptim.new(@options[:image_optim].merge(@options[:nice_image_optim]))
  end

  def optimize_all(images = [])
    puts "\nOptimizing..."
    @optimized_images = images.map do |i|
      original_path = i.path
      if @options[:skip_filenames].any? { |str|
          str.include?(File.basename(i))
        }
        next
      else
        if @options[:only_filenames].any { |str|
          str.include?(File.basename(i))
          } && @options[:only_nice]
          optimized_image = @nice_image_optim.optimize_image(i)
        else
          optimized_image = @image_optim.optimize_image(i)
        end
      end
      new_path = "#{i.path.split('/')[0...-1].join('/')}"
      mv_loc = File.join(new_path, rename(File.basename(i)))
      if optimized_image
        FileUtils.mkdir_p(new_path)
        FileUtils.mv(optimized_image, mv_loc)
        puts "%-50s %s %40s" % ["Optimizing #{i.path}", ('-'*3)+'>', mv_loc]
        mv_loc
      else
        puts "Failed to optimize or already optimized #{original_path}"
        mv_loc
      end
    end
  end

  def optimize_image(image)
    puts "\nOptimizing..."
    original_path = image
    optimized_image = @image_optim.optimize_image(image)
    mv_loc = original_path
    if optimized_image
      FileUtils.mv(optimized_image, mv_loc)
      puts "%-50s %s %40s" % ["Optimizing #{image}", ('-'*3)+'>', mv_loc]
      mv_loc
    else
      puts "Failed to optimize or already optimized #{original_path}"
      mv_loc
    end
  end

  def rename(filename, options = {})
    options = @options.merge(options)
    return filename unless options[:optimize] && options[:optimize][:rename][:enabled]
    if options[:optimize][:rename]
      if options[:optimize][:rename][:append]
        [
          filename.split('.').first + options[:optimize][:rename][:append],
          filename.split('.')[1..-1].join('.')
        ].join('.')
      else
        filename
      end
    else
      filename
    end
  end
end