require "bundler/gem_tasks"
task :default => :spec

task :c do
  exec "pry -r s3_image_optimizer -I ./lib"
end

task :optimize do
  require 's3_image_optimizer'
  S3ImageOptimizer.optimize_bucket!({bucket: ENV['AWS_BUCKET'], dir: nil, upload_bucket: ENV['AWS_UPLOAD_BUCKET']})
end

task :optimize_d do
  system "nohup rake optimize &"
end