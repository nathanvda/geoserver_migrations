$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "geoserver_migrations/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "geoserver_migrations"
  s.version     = GeoserverMigrations::VERSION
  s.authors     = ["'nathanvda'"]
  s.email       = ["'nathan@dixis.com'"]
  s.homepage    = "https://github.com/nathanvda/geoserver_migrations"
  s.summary     = "manage your geoserver configuration using migrations"
  s.description = "Manage your geoserver configuration like you manage your database: with migrations"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.7"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec", "~> 3.7"
  s.add_development_dependency "rspec-rails", "~> 3.7"

  s.add_development_dependency "simplecov"
  # s.add_development_dependency "rake-version"
end
