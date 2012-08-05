require "../lib/xcselect/nkissue"
require "test/unit"
require "time"

include Xcselect


class NKIssueTest < Test::Unit::TestCase
  attr_accessor :issues
  def setup
    @issues = NKIssue.parse "big_cats.plist"
  end
  
  
  def test_parser    
    
    versions = {"Panther"       => "October 24, 2003",
                "Tiger"         => "April 29, 2005",
                "Leopard"       => "October 26, 2007",
                "Snow Leopard"  => "August 28, 2009",
                "Lion"          => "July 20, 2011",
                "Mountain Lion" => "July 25, 2012",
                "Jaguar"        => "May 6, 2002" }
    versions.each_key do |k|
      nkissue = issues[k]
      release_date = Time.strptime(versions[k], "%b %d, %Y")
      
      # test correct date
      assert_equal(nkissue.date, release_date)
      
      # test uuid is set
      assert(!nkissue.uuid.size.zero?)

      assert_equal(7, issues.size)
    end
    
  end

end


