# S3ImageOptimizer

## Requirements

OSX
```
$ brew install jpegoptim
```

Debin/Ubuntu
```
$ sudo apt-get install -y jpegoptim gifsicle jhead pngquant
```

Other
```
$ JPEGOPTIM_VERSION=X.Y.Z
$ cd /tmp
$ curl -O http://www.kokkonen.net/tjko/src/jpegoptim-$JPEGOPTIM_VERSION.tar.gz
$ tar zxf jpegoptim-$JPEGOPTIM_VERSION.tar.gz
$ cd jpegoptim-$JPEGOPTIM_VERSION
$ ./configure && make && make install
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 's3_image_optimizer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install s3_image_optimizer

## Usage

```ruby
require 's3_image_optimizer'

# optimize an entire bucket
S3ImageOptimizer.optimize_bucket!({bucket: 'my-bucket'})

# optimize a certain folder in a bucket
S3ImageOptimizer.optimize_bucket!({bucket: 'my-bucket', dir: 'images'})
```

## Use on command line

```
$ s3imageoptimizer [command] bucket=my_bucket tmp=/tmp ...

    Commands
    [optimize_daemon]   - run in background
    [optimize]          - run in foreground
    [upload]            - upload downloaded/optimized images
    [upload_daemon]     - upload in background
    [optimize_dir]      - optimize images in current or specified directory
    [dir]               - specify dir for optimize_dir
    [help]              - show this message

    Arguments
    [bucket]            - bucket name
    [tmp]               - tmp path
    [key_contains]      - only download keys that include
    [only_filenames]    - x.jpg
    [upload_bucket]     - upload bucket name
    [tmp_download_path] - download path for upload mode
    [skip_filenames]    - x.jpg, y.jpg

    [only_nice]         - false, nice settings for only_filenames
    [settings]          - lossy:true,quality:50
    [nice_settings]     - lossy:true,quality:75

Happy optimizing! ¯\_(ツ)_/¯
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Run `rake c` for an interactive prompt.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aaronlifton2/s3_image_optimizer.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

