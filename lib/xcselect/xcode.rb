
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

  # Get an array of all installed xcode objects
  def self.find_all
    xcode_builds = `mdfind -name xcodebuild`.chomp.split
    #TODO: move this checking to init method
    xcode_builds = xcode_builds.select {|x| x =~ /\/xcodebuild$/ && !(x =~ /^\/(Volumes|usr\/bin\/)/) && File.exists?(x) }
    xcode_objs = xcode_builds.map {|p| Xcode.new p.sub( /\/usr\/bin.*/, '').chomp.strip }
    xcode_objs.sort
  end

  def self.current_xcode
    `xcode-select -print-path`.chomp
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
    res = Float(version) <=> Float(o.version) 
    return res == 0 ?  o.build <=> build : res;
  end
  
end


end