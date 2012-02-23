# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rdf-virtuoso/version"

Gem::Specification.new do |s|
  s.name        = "rdf-virtuoso"
  s.version     = RDF::Virtuoso::VERSION
  s.authors     = ["Peter Kordel"]
  s.email       = ["pkordel@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "rdf-virtuoso"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec", "~> 2.8.0"
  s.add_development_dependency "rdf-spec", "~> 0.3.5"

  s.add_runtime_dependency "rdf", "~> 0.3.5"

end
