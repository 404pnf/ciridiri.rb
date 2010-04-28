require 'rubygems'
require 'sinatra'
require 'ciridiri'

set :raise_errors, true
set :show_exceptions, false
set :logging, false

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/log/production.log')
run Sinatra::Application