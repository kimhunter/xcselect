
module Xcselect
  require 'pathname'
  require 'json'

  class XcApp
    # include Comparable
    attr_reader :path
    attr_reader :plist

    def initialize(path)
      @path = path
      @plist = JSON.parse read_plist(plist_path)
    end

    def to_s
      "App: #{bundle_id} - #{name}"
    end

    # sort by version number and fallback to build number after   
    # def <=>(o)
    #   res = version.to_f <=> o.version.to_f
    #   return res == 0 ?  o.build <=> build : res;
    # end
  
    def sim_version
      path.split('/')[-4]
    end

    def [](k)
      @plist[k]
    end

    def base_dir
      File.dirname path
    end

    def bundle_id
      self['CFBundleIdentifier']
    end

    def name
      self['CFBundleName']
    end

    def read_plist path
      `plutil -convert json  -o - '#{path}'`
    end

    def plist_path
      Dir[@path + "/*Info.plist"].first
    end

    def newsstand?
      self['UINewsstandApp'] || false
    end

    def newsstand_path
      "#{base_dir}/Library/Caches/Newsstand"
    end

    def newsstand_issue_paths
      Dir["#{newsstand_path}/*-*/*"]
    end

    def last_build_time
      File.mtime path
    end
    
    def self.app_support_folder
      File.expand_path("~/Library/Application Support/iPhone Simulator/")
    end
    
    def self.all_apps
      Dir["#{app_support_folder}/**/*.app"].map{|a| XcApp.new a }
    end
    
    def self.last_built_app
      XcApp.all_apps.sort_by!{|e| e.last_build_time }.last
    end
    
  end


end