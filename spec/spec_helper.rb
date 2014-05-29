require "rubygems"
require "bundler"

Bundler.require(:default, :test)
Dotenv.load

require File.join(File.dirname(__FILE__), '..', "highrise_endpoint")
Dir["./spec/support/**/*.rb"].each {|f| require f}
require "spree/testing_support/controllers"

def app
  HighriseEndpoint
end

VCR.configure do |config|
  # config.allow_http_connections_when_no_cassette = true
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.filter_sensitive_data("HIGHRISE_SITE_HOST") { URI(ENV["HIGHRISE_SITE_URL"]).host }
  config.filter_sensitive_data("HIGHRISE_API_TOKEN") { ENV["HIGHRISE_API_TOKEN"] }
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Spree::TestingSupport::Controllers
end