require 'rubygems'
require 'bundler'

Bundler.require(:default)
require "./highrise_endpoint"
run HighriseEndpoint::Application
