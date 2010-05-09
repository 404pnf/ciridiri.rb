require 'rubygems'
require 'test/unit'
require 'lib/ciridiri/page'
begin; require 'turn'; rescue LoadError; end

Ciridiri::Page.content_dir = File.join(File.dirname(__FILE__), 'pages')

class PageTest < Test::Unit::TestCase
  include Ciridiri

  def teardown
    #recreate an empty content directory
    FileUtils.rm_rf(Page.content_dir)
    FileUtils.mkdir(Page.content_dir)
  end

  def test_it_should_create_correct_page
    @page = page_stub
    assert_not_nil @page.content
    assert_not_nil @page.title
    assert_equal 'awesome title', @page.title
  end

  def test_it_should_save_page
    @page = page_stub
    assert @page.save
    assert File.exists?(@page.path)
    assert File.size(@page.path) > 0
  end

  def test_it_should_parse_html_and_md_titles
    @page = page_stub
    @else_one_page = page_stub("index", "<h3 class=\"title\">awesome title</h3>\n hello, everyone!")
    assert_equal @page.title, "awesome title"
    assert_equal @page.title, @else_one_page.title
  end

  def test_it_should_update_page
    @page = page_stub
    @page.save
    @page.content = "#new title\nand new content"
    assert @page.save
    assert File.open(@page.path).read.include?('and new content')
  end

  def test_it_should_find_page_by_uri
    @page = page_stub("hidden/blah")
    @page.save

    @p = Page.find_by_uri('hidden/blah')
    assert_not_nil @p
    assert_not_nil @p.title
    assert_not_nil @p.content
  end

  def test_it_should_return_nil_if_page_is_not_found
    assert_nil Page.find_by_uri('nonexistent-uri')
  end

  def test_it_should_return_empty_page_if_needed
    assert_not_nil Page.find_by_uri_or_empty('nonexistent-uri')
  end

  def test_it_should_respect_uri_hierarchy
    @page = page_stub('about/team/boris')
    @page.save

    target_path = File.expand_path(File.join(Page.content_dir, %w[about team], "boris#{Page::SOURCE_FILE_EXT}"))
    assert File.exists?(target_path)
    assert_equal target_path, File.expand_path(@page.path)
  end

  def test_it_should_create_backups_if_needed
    begin
      Page.backups = true
      @page = page_stub
      assert @page.save
      @page.content = "foo bar"
      assert @page.save

      assert_not_nil @page.revisions
      assert_equal @page.revisions.length, 1
    ensure
      Page.backups = false
    end
  end

  protected
  def page_stub(title = 'index', body = "##awesome title\n hello, everyone!")
    Page.new(title, body)
  end

end
