gem 'minitest'
require 'rubygems'
require 'test/unit'
require 'contest'
require './lib/ciridiri'
begin; require 'turn'; rescue LoadError; end

Ciridiri::Page.content_dir = File.join(File.dirname(__FILE__), 'pages')
Ciridiri::Page.caching = false

class Test::Unit::TestCase
  include Ciridiri

  class << self
    alias_method :it, :test
  end

  def teardown
    #recreate an empty content directory
    FileUtils.rm_rf(Page.content_dir)
    FileUtils.mkdir(Page.content_dir)
  end

  protected
  def page_stub(uri = '/index', body = "##awesome title\n hello, everyone!")
    Page.new(uri, body)
  end

end
