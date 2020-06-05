
class Workspace
  IGNORE = [".", "..", ".git", ".idea", ".DS_Store"]

  def initialize(pathname)
    @pathname = pathname
  end

  def list_files(dir = @pathname)
    filenames = Dir.entries(dir) - IGNORE

    filenames.flat_map do |name|
      path = dir.join(name)

      if File.directory?(path)
        list_files(path)
      else
       path.relative_path_from(@pathname)
      end
    end
  end

  def read_file(path)
    puts path
    File.read(@pathname.join(path))
  rescue Errno::EACCES
    raise NoPermission, "open('#{ path }'): Permission denied"
  end

  def stat_file(path)
    File.stat(@pathname.join(path))
  end
end