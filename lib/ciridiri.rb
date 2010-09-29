require 'rubygems'
require 'sinatra/base'

$:.unshift(File.dirname(__FILE__))
require 'ciridiri/page'

class Ciridiri::Application < Sinatra::Base
  include Ciridiri
  configure do
    set :app_file, __FILE__
    set :root, File.expand_path('..', File.dirname(__FILE__))
    enable :static
    enable :logging if development?

    Page.caching = false if development? || test?
    Page.content_dir = File.join(self.root, "pages", self.environment.to_s)
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
end
