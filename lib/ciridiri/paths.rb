module Ciridiri
  module Paths
    def path_from_uri(uri)
      path = uri.split("/")
      filename = path.pop
      File.join(content_dir, path, "#{filename}#{Page::SOURCE_FILE_EXT}")
    end

    def uri_from_path(path)
      segments = path.split(File::Separator)
      filename = segments.pop
      segments.push(filename.gsub("#{Page::SOURCE_FILE_EXT}", ""))
      "/#{segments.join("/")}"
    end

  end
end
