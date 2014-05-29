require 'rubygems'
require 'bundler'

Bundler.require(:default)

desc "Retrieve the environment of the application"
task :environment do
  require File.expand_path('highrise_endpoint', File.dirname(__FILE__)) # your Sinatra app
end

desc "Start the server"
task :start => :environment do
  case ENV["RACK_ENV"]
    when "production"
      exec 'foreman start'
    else
      exec 'PORT=3000 foreman start'
  end
end

desc "Test the application"
task :test => :environment do
  exec 'RACK_ENV=test bundle exec rspec'
end
