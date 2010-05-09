require 'rubygems'
require 'sinatra'
require 'lib/ciridiri/page'

include Ciridiri

Page.content_dir = File.join(Sinatra::Application.root, "pages", Sinatra::Application.environment.to_s)

configure :development do
  Page.caching = false
end


helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  redirect '/index.html'
end

get '*.html' do
  uri = params[:splat].first
  if @page = Page.find_by_uri(uri)
    erb :show
  else
    redirect "#{uri}.html.e"
  end
end

get '*.html.e' do
  @page = Page.find_by_uri_or_empty(params[:splat].first)
  erb :edit
end

post '*.html' do
  @page = Page.find_by_uri_or_empty(params[:splat].first)
  @page.contents = params[:contents]
  @page.save
  redirect "#{@page.uri}.html"
end