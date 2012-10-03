$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "piggybak_realtime_shipping/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "piggybak_realtime_shipping"
  s.version     = PiggybakRealtimeShipping::VERSION
  s.authors     = ["Steph Skardal", "Tim Case"]
  s.email       = ["steph@endpoint.com", "tim@endpoint"]
  s.homepage    = "https://github.com/piggybak/piggybak_realtime_shipping"
  s.summary     = "Shipping Calculator for Piggybak"
  s.description = "Shipping Calculator for Piggybak"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "piggybak"
  s.add_dependency "active_shipping"

end
