require 'rubygems'
require 'test/unit'
require 'lib/ciridiri/page'
begin; require 'turn'; rescue LoadError; end

Ciridiri::Page.content_dir = File.join(File.dirname(__FILE__), 'pages')
Ciridiri::Page.caching = false

class Test::Unit::TestCase
  include Ciridiri

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
