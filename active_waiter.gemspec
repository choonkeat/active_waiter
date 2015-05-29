$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "active_waiter/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "active_waiter"
  s.version     = ActiveWaiter::VERSION
  s.authors     = ["choonkeat"]
  s.email       = ["choonkeat@gmail.com"]
  s.homepage    = "https://github.com/choonkeat/active_waiter"
  s.summary     = "ActiveWaiter for background jobs to finish"
  s.description = "A simple mechanism allowing your users to wait for the completion of your `ActiveJob`"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.required_ruby_version = "~> 2.0"

  s.add_dependency "rails", "~> 4.2.0"

  s.add_development_dependency "guard"
  s.add_development_dependency "guard-minitest"
  s.add_development_dependency "rubocop"
end
