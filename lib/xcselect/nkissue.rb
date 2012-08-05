
module Xcselect
  require "plist"

  # Seams apple stores there internal dates with the base of 2001-01-01
  NSTimeIntervalSince1970 = 978307200.0

  class NKIssue
    include Comparable
    attr_accessor :name
    attr_accessor :uuid
    attr_accessor :date

    def self.find_class_key hash
      hash['$objects'].index(hash['$objects'].select{|o| o['$classname'] == "NKIssue"}.first)
    end

    def self.parse file_name
      ns_plist = Plist::parse_xml(read_bin_plist_to_xml(file_name))
      # this is the integer that we will use to filter all archived nkissue objects
      nk_issue_key =  find_class_key(ns_plist)

      # filter just the nkissue hashes
      object_array = ns_plist['$objects']
      obj_key_hashs = object_array.select{|o| o.class == Hash && o['$class'] && nk_issue_key == o['$class']['CF$UID'] }
      
      issues = {}
      obj_key_hashs.each do |nskey|
        issue = NKIssue.new
        issue.name = object_array[nskey['name']['CF$UID']]
        issue.uuid = object_array[nskey['directory']['CF$UID']]
        issue.date = self.archive_time_to_time(object_array[nskey['date']['CF$UID']]['NS.time'])
        issues[issue.name] = issue # unless name.nil?
      end
      return issues
    end
    
    def to_s
      "<NKIssue:#{name}:#{date} #{uuid}>"
    end

    # convert a date offset from 2001 to epoch
    def self.archive_time_to_time t
      Time.at(t + NSTimeIntervalSince1970)
    end

    def self.read_bin_plist_to_xml plist_path
      `plutil -convert xml1  -o - '#{plist_path}'`
    end
  
  end
  
end

