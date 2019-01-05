$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "migration_button/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "migration_button"
  spec.version     = MigrationButton::VERSION
  spec.authors     = ["Adam Sokolnicki"]
  spec.email       = ["adam.sokolnicki@gmail.com"]
  spec.homepage    = "https://github.com/asok/migration_button"
  spec.summary     = "Rails engine for running migrations via browser"
  spec.description = "Rails engine that checks for pending migrations and presents an error screen that allows you to manage your migrations."
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.1"

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "capybara-screenshot"
  spec.add_development_dependency "selenium-webdriver"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "puma"
end
