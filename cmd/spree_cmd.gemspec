# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require_relative '../core/lib/spree/core/version.rb'

Gem::Specification.new do |s|
  s.name        = "spree_cmd"
  s.version     = Spree.version
  s.authors     = ['Chris Mar']
  s.email       = ['chris@spreecommerce.com']
  s.summary     = 'Spree Commerce command line utility'
  s.description = 'tools to create new Spree stores and extensions'
  s.homepage    = 'https://spreecommerce.org'
  s.license     = 'BSD-3-Clause'

  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/spree/spree/issues",
    "changelog_uri"     => "https://github.com/spree/spree/releases/tag/v#{s.version}",
    "documentation_uri" => "https://guides.spreecommerce.org/",
    "source_code_uri"   => "https://github.com/spree/spree/tree/v#{s.version}",
  }

  s.files         = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.bindir        = 'bin'
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rspec'
  s.add_dependency 'thor', '~> 1.0'
end
