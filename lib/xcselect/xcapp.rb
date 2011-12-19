module Xcselect

class XcApp

  attr_accessor :simulator
  attr_accessor :path
  attr_reader :app_name

  def initialize(sim, path)
    @simulator = sim
    @path = path
    @app_name = File.basename Dir["#{path}/*.app"].first.sub /\.app$/, ''
  end  

  def to_s
    "<#{self.class}: #{app_name}>"
  end
end


end
