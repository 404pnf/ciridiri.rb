module Ciridiri
  module Paths
    # Convert `uri` to `path` in a file system including `content_dir` and a source file extension
    # `/team/pro/chuck-norris` -> `content_dir/team/pro/chuck-norris.text`
    def path_from_uri(uri)
      path = uri.split("/")
      filename = path.pop
      File.join(content_dir, path, "#{filename}#{Page::SOURCE_FILE_EXT}")
    end

  end
end
