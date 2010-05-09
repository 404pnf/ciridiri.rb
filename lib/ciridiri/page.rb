$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))
%w[fileutils finders paths].each {|r| require r}

module Ciridiri
  class Page
    extend Ciridiri::Finders, Ciridiri::Paths
    MD_TITLE = Regexp.new("(^\#{1,3}\\s*?([^#].*?)#*$)|(^ {0,3}(\\S.*?)\\n(?:=|-)+(?=\\n+|\\Z))", Regexp::MULTILINE)
    HTML_TITLE = Regexp.new("^<h[1-3](.*)?>(.*)+</h[1-3]>")
    SOURCE_FILE_EXT = ".text".freeze
    CACHED_FILE_EXT = ".html".freeze

    attr_accessor :title, :content
    attr_reader :path, :uri

    @@content_dir = '.'
    @@backups = false
    @@caching = true
    @@formatter = lambda {|text| text}

    def initialize(uri, contents)
      @path, @uri, @title, @content = Page.path_from_uri(uri), uri, Page.find_title(contents), contents
    end

    def save
      FileUtils.mkdir_p(File.dirname(@path)) unless File.exists?(@path)
      backup if @@backups && File.exists?(@path)

      begin
        File.open(@path, "w") {|f| f.write(@content)}
        true
      rescue StandardError
        false
      end
    end

    def cache!
      File.open(@path + CACHED_FILE_EXT, 'w') {|f| f.write(@@formatter.call(@content))}
    end

    def sweep!
      File.delete(@path + CACHED_FILE_EXT)
    end

    def revisions
      @revisions ||= find_revisions
    end

    def to_html
      if @@caching
        cached = @path + CACHED_FILE_EXT
        cache! if !File.exists?(cached) || File.mtime(@path) > File.mtime(cached)

        File.open(cached).read
      else
        @@formatter.call(@content)
      end
    end

    def self.content_dir=(dir)
      @@content_dir = dir
      FileUtils.mkdir_p(@@content_dir) if !File.exists?(@@content_dir)
    end

    def self.content_dir; @@content_dir; end

    def self.backups=(backups); @@backups = backups; end
    def self.backups; @@backups; end

    def self.caching=(caching); @@caching = caching; end
    def self.caching; @@caching; end

    def self.formatter=(formatter); @@formatter = formatter; end
    def self.formatter; @@formatter; end

    protected
    def self.find_title(content="")
      if content.detect {|s| s.match(MD_TITLE)}
        $2.strip || $4.strip
      elsif content.detect {|s| s.match(HTML_TITLE)}
        $2.strip
      else
        ""
      end
    end

    def find_revisions
      Dir.chdir(File.dirname(@path)) do
        basename = File.basename(@path, SOURCE_FILE_EXT)
        Dir.glob(basename + ".*" + SOURCE_FILE_EXT).
                collect {|f| File.basename(f, SOURCE_FILE_EXT).sub(basename, '')}
      end
    end

    def backup
      FileUtils.cp(@path, @path.sub(Regexp.new("#{SOURCE_FILE_EXT}$"), ".#{Time.now.to_i.to_s}#{SOURCE_FILE_EXT}"))
    end
    
  end
end