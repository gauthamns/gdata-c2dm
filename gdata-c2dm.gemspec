$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "gdata-c2dm/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "gdata-c2dm"
  s.version     = GdataC2dm::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of GdataC2dm."
  s.description = "TODO: Description of GdataC2dm."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1.3"

  s.add_development_dependency "sqlite3"
end
