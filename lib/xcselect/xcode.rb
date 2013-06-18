
module Xcselect
  

class Xcode
  include Comparable
  attr_accessor :folder, :version, :build
  def initialize(fld)
    @folder = fld
    ver_output = `#{xcodebuild_path} -version`
    @version = ver_output.match(/Xcode (.*)$/)[1]
    @build = ver_output.match(/Build version (.*)$/)[1]
  end

  def xcodebuild_path
    "#{folder}/usr/bin/xcodebuild"
  end

  def to_s
    "Xcode: #{folder} - #{version} (#{build})"
  end

  # Get an array of all self contained .app style xcode objects
  def self.find_all
    # Xcode is now in a single application, look for that and use that as a candidate
    newXcodes = `mdfind 'kMDItemCFBundleIdentifier = com.apple.dt.Xcode'`.chomp.split
    newXcodes = newXcodes.select do |x| 
      File.exists? x + "/Contents/Developer/usr/bin/xcodebuild"
    end
    newXcodes.map {|x| Xcode.new(x + "/Contents/Developer") }.sort
  end
  
  def self.current_xcode
    `xcode-select -print-path`.chomp
  end
  
  def self.current_xcode_path
    path = self.current_xcode
    if path =~ /(.*Xcode(.*DP.*)?.app)/
      path = $1
    else
      path += "/Applications/Xcode.app"
    end
    return path
  end
  
  def eql?(o)
    return false if o.nil? 
    return (o.folder == folder && o.version == version && o.build == build)
  end

  def sdks
    `#{xcodebuild_path} -showsdks`
  end

  # sort by version number and fallback to build number after   
  def <=>(o)
    res = version.to_f <=> o.version.to_f
    return res == 0 ?  o.build <=> build : res;
  end
  
end


end