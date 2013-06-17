# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "xcselect/version"

Gem::Specification.new do |s|
  s.name        = "xcselect"
  s.version     = Xcselect::VERSION
  s.authors     = ["Kim Hunter"]
  s.email       = ["bigkm1@gmail.com"]
  s.homepage    = "https://github.com/bigkm/xcselect"
  s.summary     = %q{xcselect - Xcode Select}
  s.description = %q{A more user friendly interface to the xcode-select command showing more info, xcsim - access the simulator application folders quickly}

  s.rubyforge_project = "xcselect"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency('plist', '>= 3.1.0')
  s.add_dependency('json', '>= 1.5.0')

end
