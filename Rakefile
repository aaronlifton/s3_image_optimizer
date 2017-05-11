require "bundler/gem_tasks"
task :default => :spec

task :c do
  exec "pry -r s3_image_optimizer -I ./lib"
end

task :optimize, [:bucket, :path] do |t, args|
  require 's3_image_optimizer'
  bucket = args[:bucket] || ENV['AWS_BUCKET']
  tmp = args[:path]
  S3ImageOptimizer.optimize_bucket!({
    bucket: bucket, dir: ENV['AWS_BUCKET_DIR'],
    upload_bucket: ENV['AWS_UPLOAD_BUCKET'],
    tmp: tmp
    })
end

task :optimize_d do
  system "nohup rake optimize &"
end