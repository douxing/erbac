require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :spec
task :test => :spec

desc "Run all specs"
task "spec" do
  exec "bundle exec rspec spec"
end

