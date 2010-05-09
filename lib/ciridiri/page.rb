$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))
%w[fileutils finders paths extensions].each {|r| require r}

module Ciridiri
  class Page
    extend Ciridiri::Finders, Ciridiri::Paths
    # ###Constants block
    # A regular expression for markdown-like headers (`#`, `##`, `###`, `=====`, `----`)
    MD_TITLE = Regexp.new("(^\#{1,3}\\s*?([^#].*?)#*$)|(^ {0,3}(\\S.*?)\\n(?:=|-)+(?=\\n+|\\Z))", Regexp::MULTILINE)
    # HTML headers (`<h1-3>`)
    HTML_TITLE = Regexp.new("^<h[1-3](.*)?>(.*)+</h[1-3]>")

    # ####File extensions
    SOURCE_FILE_EXT = ".text".freeze
    CACHED_FILE_EXT = ".html".freeze

    # Define attr_reader/accessors, class_accessors (we use them for configuring: `Page.content_dir = '/tmp'`)
    attr_accessor :title, :contents
    attr_reader :path, :uri

    # ###Default values for all options
    # Where all pages should be stored on a file system
    @@content_dir = '.'
    # Should we create backups (`filename.1278278364.text`, where `1278278364` -- current timestamp) or not.
    # Useful when you are not going to place `@@content_dir` under version control
    @@backups = false
    # Page fragments (formatted file `contents`) caching
    @@caching = true
    # ####Formatter block
    # You could use any formatter. For example:
    # Bluecloth:
    #     require 'bluecloth'
    #     Page.formatter = lambda {|text| Bluecloth.new(text).to_html)}
    #
    # RDiscount:
    #     require 'rdiscount'
    #     Page.formatter = lambda {|text| RDiscount.new(text).to_html)}
    #
    # Rutils with RDiscount:
    #     require 'rutils'
    #     require 'rdiscount'
    #     Page.formatter = lambda {|text| RuTils::Gilenson::Formatter.new(RDiscount.new(text).to_html).to_html}
    #
    # HTML escaping:
    #     Page.formatter = {|text| "<pre>#{Rack::Utils.escape_html(text)}</pre>"}
    #
    @@formatter = lambda {|text| text}

    cattr_accessor :content_dir, :backups, :caching, :formatter

    # Converts `uri` to `path`, finds the `title` in `contents`
    def initialize(uri, contents)
      @path, @uri, @title, @contents = Page.path_from_uri(uri), uri, Page.find_title(contents), contents
    end

    # Creates needed directory hierarchy and backups the file if needed.
    # Writes `@contents` to the file and returns `true`/`false`
    def save
      FileUtils.mkdir_p(File.dirname(@path)) unless File.exists?(@path)
      backup if Page.backups? && File.exists?(@path)

      begin
        File.open(@path, "w") {|f| f.write(@contents)}
        true
      rescue StandardError
        false
      end
    end

    # Saves `@contents` formatted with `Page.formatter` to the cache file
    # `index.text` -> `index.text.html`
    def cache!
      File.open(@path + CACHED_FILE_EXT, 'w') {|f| f.write(@@formatter.call(@contents))}
    end

    # Deletes the cache file
    def sweep!
      File.delete(@path + CACHED_FILE_EXT)
    end

    # Returns an array of the page revisions
    def revisions
      @revisions ||= find_revisions
    end

    # Returns `@contents` HTML representation.
    # If a page fragments caching enabled (`Page.caching = true`) then
    # regenerates the fragment cache (`index.text.html`) if needed (it's outdated or doesn't exist)
    # and returns the cached contents.
    # Otherwise (`Page.caching = false`) returns `@contents` formatted with `Page.formatter`
    def to_html
      if Page.caching?
        cached = @path + CACHED_FILE_EXT
        cache! if !File.exists?(cached) || File.mtime(@path) > File.mtime(cached)

        File.open(cached).read
      else
        @@formatter.call(@contents)
      end
    end

    # Tiny `attr_writer` for `@@content_dir` which creates the content directory if it doesn't exist
    def self.content_dir=(dir)
      @@content_dir = dir
      FileUtils.mkdir_p(@@content_dir) if !File.exists?(@@content_dir)
    end

    protected
    # Finds the title in contents (html or markdown variant).
    # Returns `""` if nothing found.
    def self.find_title(contents="")
      if contents.detect {|s| s.match(MD_TITLE)}
        $2.strip || $4.strip
      elsif contents.detect {|s| s.match(HTML_TITLE)}
        $2.strip
      else
        ""
      end
    end

    # Collects only time stamps of revisions.
    # `index.1273434670.text`, `index.1273434450.text` -> `["1273434670", "1273434450"]`
    def find_revisions
      Dir.chdir(File.dirname(@path)) do
        basename = File.basename(@path, SOURCE_FILE_EXT)
        Dir.glob(basename + ".*" + SOURCE_FILE_EXT).
                collect {|f| File.basename(f, SOURCE_FILE_EXT).sub(basename, '')}
      end
    end

    # Backups the file by copying it's current version to the same file but with the current time stamp.
    # `index.text` -> `index.1273434670.text`
    def backup
      FileUtils.cp(@path, @path.sub(Regexp.new("#{SOURCE_FILE_EXT}$"), ".#{Time.now.to_i.to_s}#{SOURCE_FILE_EXT}"))
    end
    
  end
end