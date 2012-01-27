$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "gdata-c2dm/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "gdata-c2dm"
  s.version     = GdataC2dm::VERSION
  s.authors     = ["Gautham NS"]
  s.email       = ["gautham@ppprep.com"]
  s.homepage    = "http://gauthamns.com"
  s.summary     = "GData for Google data."
  s.description = "GData clone with C2DM included."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "gdata_19"

end
