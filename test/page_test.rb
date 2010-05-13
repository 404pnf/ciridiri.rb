require 'test_helper'

class PageTest < Test::Unit::TestCase
  describe "Ciridiri::Page" do
    should "create correct page" do
      @page = page_stub
      assert_not_nil @page.contents
      assert_not_nil @page.title
      assert_equal 'awesome title', @page.title
    end

    should "save page" do
      @page = page_stub
      assert @page.save
      assert File.exists?(@page.path)
      assert File.size(@page.path) > 0
    end

    should "parse html and md titles" do
      @page = page_stub
      @else_one_page = page_stub("index", "<h3 class=\"title\">awesome title</h3>\n hello, everyone!")
      assert_equal @page.title, "awesome title"
      assert_equal @page.title, @else_one_page.title
    end

    should "update page" do
      @page = page_stub
      @page.save
      @page.contents = "#new title\nand new content"
      assert @page.save
      assert File.open(@page.path).read.include?('and new content')
    end

    should "find page by uri" do
      @page = page_stub("hidden/blah")
      @page.save

      @p = Page.find_by_uri('hidden/blah')
      assert_not_nil @p
      assert_not_nil @p.title
      assert_not_nil @p.contents
    end

    should "return nil if page is not found" do
      assert_nil Page.find_by_uri('nonexistent-uri')
    end

    should "return empty page if needed" do
      assert_not_nil Page.find_by_uri_or_empty('nonexistent-uri')
    end

    should "respect uri hierarchy" do
      @page = page_stub('about/team/boris')
      @page.save

      target_path = File.expand_path(File.join(Page.content_dir, %w[about team], "boris#{Page::SOURCE_FILE_EXT}"))
      assert File.exists?(target_path)
      assert_equal target_path, File.expand_path(@page.path)
    end

    should "create backups if needed" do
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

    should "format contents" do
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

    should "cache page" do
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
end
