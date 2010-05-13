require 'test_helper'

class PageTest < Test::Unit::TestCase
  it "should_create_correct_page" do
    @page = page_stub
    assert_not_nil @page.contents
    assert_not_nil @page.title
    assert_equal 'awesome title', @page.title
  end

  it "should_save_page" do
    @page = page_stub
    assert @page.save
    assert File.exists?(@page.path)
    assert File.size(@page.path) > 0
  end

  it "should_parse_html_and_md_titles" do
    @page = page_stub
    @else_one_page = page_stub("index", "<h3 class=\"title\">awesome title</h3>\n hello, everyone!")
    assert_equal @page.title, "awesome title"
    assert_equal @page.title, @else_one_page.title
  end

  it "should_update_page" do
    @page = page_stub
    @page.save
    @page.contents = "#new title\nand new content"
    assert @page.save
    assert File.open(@page.path).read.include?('and new content')
  end

  it "should_find_page_by_uri" do
    @page = page_stub("hidden/blah")
    @page.save

    @p = Page.find_by_uri('hidden/blah')
    assert_not_nil @p
    assert_not_nil @p.title
    assert_not_nil @p.contents
  end

  it "should_return_nil_if_page_is_not_found" do
    assert_nil Page.find_by_uri('nonexistent-uri')
  end

  it "should_return_empty_page_if_needed" do
    assert_not_nil Page.find_by_uri_or_empty('nonexistent-uri')
  end

  it "should_respect_uri_hierarchy" do
    @page = page_stub('about/team/boris')
    @page.save

    target_path = File.expand_path(File.join(Page.content_dir, %w[about team], "boris#{Page::SOURCE_FILE_EXT}"))
    assert File.exists?(target_path)
    assert_equal target_path, File.expand_path(@page.path)
  end

  it "should_create_backups_if_needed" do
    begin
      Page.backups = true
      @page = page_stub
      assert @page.save
      @page.contents = "foo bar"
      assert @page.save

      assert_not_nil @page.revisions
      assert_equal @page.revisions.length, 1
    ensure
      Page.backups = false
    end
  end

  it "should_format_contents" do
    begin
      @page = page_stub
      @page.save
      assert_equal @page.contents, @page.to_html
      Page.formatter = lambda {|t| "<censored />"}
      assert_equal @page.to_html, "<censored />"
    ensure
      Page.formatter = lambda {|t| t}
    end
  end

  it "should_cache_page" do
    begin
      Page.caching = true
      @page = page_stub
      @page.save
      assert_not_nil @page.to_html
      assert File.exists?(@page.path + Page::CACHED_FILE_EXT)
      assert File.size(@page.path + Page::CACHED_FILE_EXT) > 0
    ensure
      Page.caching = false
    end
  end
end
