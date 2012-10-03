$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "piggybak_realtime_shipping/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "piggybak_realtime_shipping"
  s.version     = PiggybakRealtimeShipping::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of PiggybakRealtimeShipping."
  s.description = "TODO: Description of PiggybakRealtimeShipping."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.6"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
