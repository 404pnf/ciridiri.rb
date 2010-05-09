require 'rubygems'
require 'sinatra'
require 'ciridiri'

set :raise_errors, true
set :show_exceptions, false
set :logging, false

run Sinatra::Application