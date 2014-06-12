require 'rubygems'
require 'bundler'

Bundler.require(:default)

require "./lib/blueprint"
Dir["./lib/**/*.rb"].each { |f| require f }

require "./highrise_endpoint"
run HighriseEndpoint::Application
