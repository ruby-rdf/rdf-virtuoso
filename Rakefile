require "bundler/gem_tasks"

namespace :gem do
  desc "Build the rdf-virtuoso-#{File.read('VERSION').chomp}.gem file"
  task :build do
    sh "gem build rdf-virtuoso.gemspec && mv rdf-virtuoso-#{File.read('VERSION').chomp}.gem pkg/"
  end

  desc "Release the rdf-virtuoso-#{File.read('VERSION').chomp}.gem file"
  task :release do
    sh "gem push pkg/rdf-virtuoso-#{File.read('VERSION').chomp}.gem"
  end
end
