
module Xcselect
  require 'pathname'
  require 'json'
  require "plist"

  class XcApp
    include Comparable
    attr_reader :path
    attr_reader :info_plist

    def initialize(path)
      @path = path
      @info_plist = JSON.parse read_plist(plist_path)
    end

    def to_s
      "#{name} (#{sim_version})"
    end

    def <=>(o)
      result = sim_version.to_f <=> o.sim_version.to_f 
      (!result.zero?) ? result : name <=> o.name
    end
  
    def sim_version
      path.split('/')[-4]
    end

    def [](k)
      @info_plist[k]
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

    def read_plist plist_path
      `plutil -convert json  -o - '#{plist_path}'`
    end
    
    def read_bin_plist_to_xml plist_path
      `plutil -convert xml1  -o - '#{plist_path}'`
    end
    
    def plist_path
      Dir[@path + "/*Info.plist"].first
    end

    def documents_path
      "#{base_dir}/Documents"
    end

    def cache_path
      "#{base_dir}/Library/Caches"
    end

    def oomph_app?
      File.exists? "#{path}/Oomph.plist"
    end
    
    def newsstand?
      self['UINewsstandApp'] || false
    end
    
    # Returns a hash of NKIssues in the form {"issue_name" => path }
    def newsstand_objects
      issues = {}
      return issues unless newsstand?
      # this is an NSKeyedArchiver plist
      ns_plist = Plist::parse_xml(read_bin_plist_to_xml("#{base_dir}/Library/Application Support/com.apple.newsstand-library.plist"))
      
      # this is the integer that we will use to filter all archived nkissue objects
      nk_issue_key =  ns_plist['$objects'].index(ns_plist['$objects'].select{|o| o['$classname'] == "NKIssue"}.last)
      
      # filter just the nkissue hashes
      object_array = ns_plist['$objects']
      obj_key_hashs = object_array.select{|o| o.class == Hash && o['$class'] && nk_issue_key == o['$class']['CF$UID'] }
      
      
      # load these paths as our apps have 1 folder inside the newsstand folders
      paths = newsstand_issue_paths if oomph_app?
      
      obj_key_hashs.each do |nskey|
        name = object_array[nskey['name']['CF$UID']]
        uuid = object_array[nskey['directory']['CF$UID']]
        next if name.nil?
        issues[name] = "#{newsstand_path}/#{uuid}"
        issues[name] = paths.select{|p| p[uuid] }.last if oomph_app? # specially for me :)
      end
      return issues
    end

    # path to the app's root newsstand folder
    def newsstand_path
      "#{base_dir}/Library/Caches/Newsstand"
    end

    # all directories in newsstand folder
    def newsstand_issue_paths
      #TODO: make this read the newsstand db and return a hash of names/paths
      if oomph_app? 
        Dir["#{newsstand_path}/*-*/*"]         
      else
        Dir["#{newsstand_path}/*-*"]
      end
    end
    
    def last_build_time
      File.mtime path
    end

    # Class methods
    
    # the iPhone Simulator support folder
    def self.app_support_folder
      File.expand_path("~/Library/Application Support/iPhone Simulator/")
    end
    
    # all applications for all simulator versions, unsorted
    def self.all_apps
      Dir["#{app_support_folder}/**/*.app"].map{|a| XcApp.new a }
    end
    
    # every newsstand application
    def self.all_newsstand_apps
      self.all_apps.select(&:newsstand?)
    end

    def self.last_built_newsstand_app
      all_newsstand_apps.sort_by!{|e| e.last_build_time }.last
    end

    def self.sort_by_touch_time array
      array.sort_by{|e| e.last_build_time }
    end
    
    def self.last_built_app
      XcApp.sort_by_touch_time(all_apps).last
    end
    
  end


end