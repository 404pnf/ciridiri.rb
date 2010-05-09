require 'fileutils'

module Ciridiri
  class Page
    MD_TITLE = Regexp.new("(^\#{1,3}\\s*?([^#].*?)#*$)|(^ {0,3}(\\S.*?)\\n(?:=|-)+(?=\\n+|\\Z))", Regexp::MULTILINE)
    HTML_TITLE = Regexp.new("^<h[1-3](.*)?>(.*)+</h[1-3]>")
    SOURCE_FILE_EXT = ".text".freeze

    attr_accessor :title, :content
    attr_reader :path, :uri

    @@content_dir = '.'
    @@backups = false

    def initialize(uri, contents)
      @path, @uri, @title, @content = Page.path_from_uri(uri), uri, Page.find_title(contents), contents
    end

    def save
      create_needed_dirs unless File.exists?(@path)
      backup_file if @@backups && File.exists?(@path)

      begin
        File.open(@path, "w") {|f| f.write(@content)}
        true
      rescue StandardError
        false
      end
    end

    def revisions
      @revisions ||= find_revisions
    end

    def self.content_dir=(dir)
      @@content_dir = dir
      FileUtils.mkdir_p(@@content_dir) if !File.exists?(@@content_dir)
    end

    def self.content_dir; @@content_dir; end

    def self.backups=(backups)
      @@backups = backups
    end

    def self.backups; @@backups; end

    def self.find_by_uri(uri)
      content_path = path_from_uri(uri)
      File.exists?(content_path) ? Page.new(uri, File.open(content_path).read) : nil
    end

    def self.find_by_uri_or_empty(uri)
      find_by_uri(uri) or Page.new(uri, '')
    end

    def self.all
      Dir.chdir(@@content_dir) do
        files = Dir.glob(File.join("**", "*#{SOURCE_FILE_EXT}")).delete_if {|p| p =~ Regexp.new("\\.[0-9]+\\#{SOURCE_FILE_EXT}$")}
        files.collect {|f| Page.new(uri_from_path(f), File.open(f, 'r') {|b| b.read})}
      end
    end

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

    def self.path_from_uri(uri)
      path = uri.split("/")
      filename = path.pop
      File.join(@@content_dir, path, "#{filename}#{SOURCE_FILE_EXT}")
    end

    def self.uri_from_path(path)
      segments = path.split(File::Separator)
      filename = segments.pop
      segments.push(filename.gsub("#{SOURCE_FILE_EXT}", ""))
      "/#{segments.join("/")}"
    end

    def find_revisions
      Dir.chdir(File.dirname(@path)) do
        basename = File.basename(@path, SOURCE_FILE_EXT)
        Dir.glob(basename + ".*" + SOURCE_FILE_EXT).
                collect {|f| File.basename(f, SOURCE_FILE_EXT).sub(basename, '')}
      end
    end

    def create_needed_dirs
      FileUtils.mkdir_p(File.dirname(@path))
    end

    def backup_file
      FileUtils.cp(@path, @path.sub(Regexp.new("#{SOURCE_FILE_EXT}$"), ".#{Time.now.to_i.to_s}#{SOURCE_FILE_EXT}"))
    end
    
  end
end