$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "waiter/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "waiter"
  s.version     = Waiter::VERSION
  s.authors     = ["choonkeat"]
  s.email       = ["choonkeat@gmail.com"]
  s.homepage    = "https://github.com/choonkeat/waiter"
  s.summary     = "Waiter for background jobs to finish"
  s.description = "A simple mechanism allowing your users to wait for the completion of your `ActiveJob`"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.1"
  s.add_dependency "jquery-rails"
  s.add_dependency "turbolinks"

  s.add_development_dependency "guard"
  s.add_development_dependency "guard-minitest"
end
