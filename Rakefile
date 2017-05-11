require "bundler/gem_tasks"
task :default => :spec

task :c do
  exec "pry -r s3_image_optimizer -I ./lib"
end

task :optimize do
  require 's3_image_optimizer'
  S3ImageOptimizer.optimize_bucket!({bucket: 'my-bucket', dir: 'images', upload_bucket: 'my-bucket-optimized'})
end

task :optimize_d do
  system "nohup rake optimize &"
end