# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 's3_image_optimizer/version'

Gem::Specification.new do |spec|
  spec.name          = "s3_image_optimizer"
  spec.version       = S3ImageOptimizer::VERSION
  spec.authors       = ["Aaron Lifton"]
  spec.email         = ["aaronlifton@gmail.com"]

  spec.summary       = %q{optimize images in a s3 bucket with image_optim}
  spec.homepage      = "http://github.com/aaronlifton2/s3_image_optimizer"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["s3imageoptimizer"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
end
