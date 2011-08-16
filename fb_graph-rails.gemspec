# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fb_graph/rails/version"

Gem::Specification.new do |s|
  s.name        = "fb_graph-rails"
  s.version     = FbGraph::Rails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["TODO: Write your name"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}
  s.add_dependency("fb_graph")
  s.add_dependency("rails", ["~> 3.0.9"])
  s.add_development_dependency("sqlite3")
  s.add_development_dependency("rspec")
  s.add_development_dependency("rspec-rails")
  s.add_development_dependency("ruby-debug")
  s.add_development_dependency("rr")
  s.add_development_dependency("factory_girl")
  s.add_development_dependency("shoulda")

  #  s.rubyforge_project = "fb_graph-rails"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
