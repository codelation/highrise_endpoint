require 'rubygems'
require 'bundler'

Bundler.require(:default)

require "./lib/blueprint"
Dir["./lib/**/*.rb"].each { |f| require f }

require "./highrise_endpoint"
use Rack::Logger
run HighriseEndpoint::Application
