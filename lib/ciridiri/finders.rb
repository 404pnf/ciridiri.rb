module Ciridiri
  module Finders
    def find_by_uri(uri)
      content_path = path_from_uri(uri)
      File.exists?(content_path) ? Page.new(uri, File.open(content_path).read) : nil
    end

    def find_by_uri_or_empty(uri)
      find_by_uri(uri) or Page.new(uri, '')
    end

    def all
      Dir.chdir(content_dir) do
        files = Dir.glob(File.join("**", "*#{SOURCE_FILE_EXT}")).delete_if {|p| p =~ Regexp.new("\\.[0-9]+\\#{SOURCE_FILE_EXT}$")}
        files.collect {|f| Page.new(uri_from_path(f), File.open(f, 'r') {|b| b.read})}
      end
    end

  end
end
