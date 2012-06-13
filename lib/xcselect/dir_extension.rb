# module Xcselect

class Dir
  def self.entries_nodots path
    Dir.entries(path).select { |p| !(p =~ /^\.\.?$/) }
  end
end

# end
