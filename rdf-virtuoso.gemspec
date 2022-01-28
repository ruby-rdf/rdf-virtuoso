2# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = 'rdf-virtuoso'
  s.version     = File.read('VERSION').chomp
  s.platform    = Gem::Platform::RUBY
  s.date        = File.mtime('VERSION').strftime('%Y-%m-%d')
  s.authors     = ['Benjamin Rokseth', 'Peter Kordel']
  s.email       = ['benjamin.rokseth@kul.oslo.kommune.no']
  s.homepage    = 'https://github.com/ruby-rdf/rdf-virtuoso'
  s.summary     = %q{An RDF.rb extension library for interacting with a Virtuoso rdf store}
  s.description = %q{An RDF.rb extension library for interacting with a Virtuoso rdf store.\nSupports SPARQL 1.1 UPDATE extensions and some Virtuoso specific commands.}
  s.license     = 'Unlicense'
  gem.metadata           = {
    "documentation_uri" => "https://ruby-rdf.github.io/rdf-virtuoso",
    "bug_tracker_uri"   => "https://github.com/ruby-rdf/rdf-virtuoso/issues",
    "homepage_uri"      => "https://github.com/ruby-rdf/rdf-virtuoso",
    "mailing_list_uri"  => "https://lists.w3.org/Archives/Public/public-rdf-ruby/",
    "source_code_uri"   => "https://github.com/ruby-rdf/rdf-virtuoso",
  }

  s.files         = %w(README.md LICENSE VERSION) + Dir.glob('lib/**/*.rb')
  s.require_paths = ['lib']

  s.required_ruby_version      = '>= 2.6'

  s.add_runtime_dependency 'rdf',           '~> 3.2'
  s.add_runtime_dependency 'httparty',      '~> 0.20'
  s.add_runtime_dependency 'api_smith',     '~> 1.3.0'

  s.add_development_dependency 'rspec',     '~> 3.10'
  s.add_development_dependency 'rdf-spec',  '~> 3.2'
  s.add_development_dependency 'rdf-vocab', '~> 3.2'

end
