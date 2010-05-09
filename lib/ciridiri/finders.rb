module Ciridiri
  module Finders
    # Firstly, converts `uri` to a path and returns a new `Page` instance if the corresponding file exists.
    # Returns nil otherwise
    def find_by_uri(uri)
      content_path = path_from_uri(uri)
      File.exists?(content_path) ? Page.new(uri, File.open(content_path).read) : nil
    end

    # Returns a new empty `Page` instance if the corresponding file doesn't exists
    def find_by_uri_or_empty(uri)
      find_by_uri(uri) or Page.new(uri, '')
    end

    # Returns an array of all `Page`s excluding backups
    def all
      Dir.chdir(content_dir) do
        files = Dir.glob(File.join("**", "*#{SOURCE_FILE_EXT}")).delete_if {|p| p =~ Regexp.new("\\.[0-9]+\\#{SOURCE_FILE_EXT}$")}
        files.collect {|f| Page.new(uri_from_path(f), File.open(f, 'r') {|b| b.read})}
      end
    end

  end
end
