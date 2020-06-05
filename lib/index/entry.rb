require "pathname"

class Index
  REGULAR_MODE = 0100644
  EXECUTABLE_MODE = 0100755
  MAX_PATH_SIZE = 0xfff

  # N10 means ten 32-bit unsigned big-endian numbers
  # H40 means a 40-character hex string, which will pack down to 20 bytes
  # n means a 16-bit unsigned big-endian number
  # Z* means a null-terminated string
  ENTRY_FORMAT    = "N10H40nZ*"
  ENTRY_BLOCK     = 8
  ENTRY_MIN_SIZE  = 64


  entry_fields = [
      :ctime, :ctime_nsec,
      :mtime, :mtime_nsec,
      :dev, :ino, :mode, :uid, :gid, :size,
      :oid, :flags, :path
  ]

  Entry = Struct.new(*entry_fields) do
    def self.create(pathname, oid, stat)
      path = pathname.to_s
      mode = stat.executable? ? EXECUTABLE_MODE : REGULAR_MODE
      flags = [path.bytesize, MAX_PATH_SIZE].min

      Entry.new(
          stat.ctime.to_i, stat.ctime.nsec,
          stat.mtime.to_i, stat.mtime.nsec,
          stat.dev, stat.ino, mode, stat.uid, stat.gid, stat.size,
          oid, flags, path
      )
    end

    def to_s
      #Calling to_a on a struct returns an array of the values of all its fields,
      # in the order they’re defined in Struct.new
      string = to_a.pack(ENTRY_FORMAT)
      string.concat("\0") until string.bytesize % ENTRY_BLOCK == 0
      string
    end

  end
end