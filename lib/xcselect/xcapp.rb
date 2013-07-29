
module Xcselect
  require 'pathname'
  require 'json'
  require "plist"
  require 'xcselect/nkissue'

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
      if result.zero?
        return -1 if name.nil?
        return 1 if o.name.nil?
        result = name.downcase <=> o.name.downcase
      end
      return result
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
      issues = NKIssue.parse "#{base_dir}/Library/Application Support/com.apple.newsstand-library.plist"

      return issues unless newsstand?
      paths = newsstand_issue_paths if oomph_app?      
      issues.values.each do |issue|
        issue.content_path = "#{newsstand_path}/#{issue.uuid}"
        issue.content_path = paths.select{|p| p[issue.uuid] }.last if oomph_app?
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
      dirs = Dir["#{app_support_folder}/**/*.app"].reject{|d| File.symlink? d }
      dirs.map{|a| XcApp.new a }
    end
    
    # every newsstand application
    def self.all_newsstand_apps
      self.all_apps.select(&:newsstand?)
    end

    def self.last_built_newsstand_app
      all_newsstand_apps.sort_by{|e| e.last_build_time }.last
    end

    def self.sort_by_touch_time array
      array.sort_by{|e| e.last_build_time }
    end
    
    def self.last_built_app
      XcApp.sort_by_touch_time(all_apps).last
    end
    
  end


end