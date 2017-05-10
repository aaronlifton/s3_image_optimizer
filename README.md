# S3ImageOptimizer

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Run `rake c` for an interactive prompt.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aaronlifton2/s3_image_optimizer.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

