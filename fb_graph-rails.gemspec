# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fb_graph/rails/version"

Gem::Specification.new do |s|
  s.name        = "fb_graph-rails"
  s.version     = FbGraph::Rails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Daisuke Fujimura"]
  s.email       = ["me@fujimuradaisuke.com"]
  s.homepage    = "https://github.com/fujimura/fb_graph-rails"
  s.summary     = %q{Lightweight FbGraph wrapper for Ruby on Rails}
  s.description = %q{Lightweight FbGraph wrapper for Ruby on Rails}
  s.add_dependency "fb_graph", '~> 2.4.0'
  s.add_dependency "rails", "> 3.0.0"
  s.add_development_dependency "sqlite3", "~> 1.3.4"
  s.add_development_dependency "database_cleaner", "~> 0.6.7"
  s.add_development_dependency "rspec", "~> 2.6.0"
  s.add_development_dependency "rspec-rails", "~> 2.6.1"
  s.add_development_dependency "rr", "~> 1.0.3"
  s.add_development_dependency "rcov", "~> 0.9.9"
  s.add_development_dependency "factory_girl", "~> 2.0.4"
  s.add_development_dependency "shoulda", "~> 2.11.3"

  #  s.rubyforge_project = "fb_graph-rails"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
