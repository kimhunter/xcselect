module Xcselect


class XcSimulator
  attr_reader :path
  attr_reader :apps

  def initialize(path)
    @path = path
    @ver = path.sub /.*\//, ''
    @apps = load_apps
  end

  def app_folder_path
    "#{@path}/Applications"
  end

  def load_apps
    base_path = app_folder_path
    Dir.entries_nodots(base_path).map {|p| XcApp.new self, "#{base_path}/#{p}" }
  end

  def to_s
    "<#{self.class}: #{@ver} Apps:#{@apps.size}}>"
  end

  def self.get_sims
    self.find_sim_versions.map {|p| XcSimulator.new "#{self.simulators_base_path}/#{p}" }
  end

  def self.find_sim_versions
    Dir.entries_nodots(self.simulators_base_path).select {|p| p =~ /[0-9]/ }
  end
  
  def self.simulators_base_path
    File.expand_path "~/Library/Application Support/iPhone Simulator"  
  end

end

end
