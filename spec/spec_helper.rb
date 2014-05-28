require "rubygems"
require "bundler"

# require 'spree/testing_support/controllers'

Bundler.require(:default, :test)

# ENV['ENDPOINT_KEY'] = 'x123'

require File.join(File.dirname(__FILE__), '..', "highrise_endpoint")
Dir["./spec/support/**/*.rb"].each {|f| require f}

Sinatra::Base.environment = "test"

def app
  HighriseEndpoint
end

VCR.configure do |c|
  # c.allow_http_connections_when_no_cassette = true
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
