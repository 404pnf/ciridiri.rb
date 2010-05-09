require 'rubygems'
require 'test/unit'
require 'lib/ciridiri/page'
begin; require 'turn'; rescue LoadError; end

Ciridiri::Page.content_dir = File.expand_path("../pages/test", __FILE__)

class PageTest < Test::Unit::TestCase
  include Ciridiri

  def test_truth
    assert true
  end

end
