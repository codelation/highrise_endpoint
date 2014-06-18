require "rubygems"
require "bundler"

Bundler.require(:default, :test)
Dotenv.load

require File.join(File.dirname(__FILE__), '..', "highrise_endpoint")
Dir["./spec/support/**/*.rb"].each { |f| require f }
require "./lib/blueprint"
Dir["./lib/**/*.rb"].each { |f| require f }
require "spree/testing_support/controllers"

def app
  HighriseEndpoint::Application
end

VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = true
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.default_cassette_options = { match_requests_on: [:method, :path] }
  config.hook_into :webmock
  config.filter_sensitive_data("HIGHRISE_SITE_HOST") {
    URI(ENV["HIGHRISE_SITE_URL"].blank? ? "http://www.example.com" : ENV["HIGHRISE_SITE_URL"]).host
  }
  config.filter_sensitive_data("HIGHRISE_API_TOKEN") {
    ENV["HIGHRISE_API_TOKEN"].blank? ? "thisIsAFakeKey123" : ENV["HIGHRISE_API_TOKEN"]
  }
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Spree::TestingSupport::Controllers
end

Highrise::Base.site = ENV["HIGHRISE_SITE_URL"]
Highrise::Base.user = ENV["HIGHRISE_API_TOKEN"]

# This is used to override the generated request parameters, so that they are real values.
def set_highrise_parameters(request)
  request[:parameters]["highrise.api_token"] = ENV["HIGHRISE_API_TOKEN"]
  request[:parameters]["highrise.site_url"] = ENV["HIGHRISE_SITE_URL"]
end

def line_items_to_string(line_items)
  line_items.map{ |line_item|
    "##{line_item[:product_id]} - \"#{line_item[:name]}\" | #{line_item[:quantity]} @ #{line_item[:price]/100.00}/each"
  }.join("\n")
end
