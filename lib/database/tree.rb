
class Database
  class Tree
    ENTRY_FORMAT = "Z*H40"
    MODE = "100644"

    attr_accessor :oid

    def initialize
      @entries = {}
    end

    def self.build(entries)
      entries.sort_by! { |entry| entry.name.to_s}
      root = Tree.new

      entries.each do |entry|
        root.add_entry(entry.parent_directories, entry)
      end
      root
    end

    def type
      "tree"
    end

    def mode
      Entry::DIRECTORY_MODE
    end

    def to_s
      # • Z*: this encodes the first string, "#{ MODE } #{ entry.name }",
      #     as an arbitrary-length null- padded string, that is, it
      #     represents the string as-is with a null byte appended to the end
      # • H40: this encodes a string of forty hexadecimal digits, entry.oid,
      #     by packing each pair of digits into a single byte
      entries = @entries.map do |name, entry|
        ["#{ entry.mode } #{name}", entry.oid].pack(ENTRY_FORMAT)
      end

      entries.join("")
    end

    def add_entry(parents, entry)
      if parents.empty?
        @entries[entry.basename] = entry
      else
        tree = @entries[parents.first.basename] ||= Tree.new
        tree.add_entry(parents.drop(1), entry)
      end
    end

    def traverse(&block)
      @entries.each do |name, entry|
        entry.traverse(&block) if entry.is_a?(Tree)
      end
      block.call(self)
    end

  end
end