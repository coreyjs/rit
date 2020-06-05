
class Entry
  attr_reader :name, :oid

  REGULAR_MODE = "100644"
  EXECUTABLE_MODE = "100755"
  DIRECTORY_MODE = "40000"

  def initialize(name, oid, stat)
    @name = name
    @oid = oid
    @stat = stat
  end

  def mode
    @stat.executable? ? EXECUTABLE_MODE : REGULAR_MODE
  end

  def parent_directories
    # Pathname#descend yields the names of the directories leading to the given path; the subscript [0..-2]
    # means all but the last item, the entry’s path itself, are returned
    @name.descend.to_a[0..-2]
  end

  def basename
    @name.basename
  end
end