source "https://rubygems.org"

# Specify your gem's dependencies in rdf-virtuoso.gemspec
gemspec

gem "rdf",       github: "ruby-rdf/rdf",       branch: "develop"

group :development, :test do
  gem 'rdf-isomorphic', git: "https://github.com/ruby-rdf/rdf-isomorphic",  branch: "develop"
  gem "rdf-spec",  github: "ruby-rdf/rdf-spec",  branch: "develop"
  gem "rdf-vocab", github: "ruby-rdf/rdf-vocab", branch: "develop"
end

group :debug do
  gem "byebug", platforms: :mri
end
