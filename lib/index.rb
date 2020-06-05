# The job of the index is to manage the list of chache
# entires stored inthe file .git/index.  As such,
# we'll instantiate it with a hash called @entries to store its data
# and a Lockfile to handle saving this data to disk.

require "digest/sha1"

require_relative './index/entry'
require_relative './lockfile'

class Index
  # a 4-byte string followed by two 32-bit big endian numbers
  HEADER_FORMAT = "a4N2"

  def initialize(pathname)
    @entries = {}
    @lockfile = Lockfile.new(pathname)
  end

  def add(pathname, oid, stat)
    entry = Entry.create(pathname, oid, stat)
    @entries[pathname.to_s] = entry
  end

  def write_updates
    return false unless @lockfile.hold_for_update

    begin_write
    header = ["DIRC", 2, @entries.size].pack(HEADER_FORMAT)
    write(header)
    @entries.each { |key, entry| write(entry.to_s)}
    finish_write

    true
  end

  def begin_write
    @digest = Digest::SHA1.new
  end

  def write(data)
    @lockfile.write(data)
    @digest.update(data)
  end

  def finish_write
    @lockfile.write(@digest.digest)
    @lockfile.commit
  end
end