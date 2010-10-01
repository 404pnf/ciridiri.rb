$:.unshift File.expand_path("#{File.dirname(__FILE__)}/lib")
require 'rubygems'
require 'sinatra'
require 'ciridiri'

# require 'rdiscount'
# Ciridiri::Page.formatter = lambda {|text| RDiscount.new(text).to_html}

set :raise_errors, true
set :show_exceptions, false
set :logging, false

run Ciridiri::Application
