# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../db/migrate', __dir__)

Rails.application.config.active_record.maintain_test_schema = false

require "rails/test_help"
require 'capybara/rails'
require 'capybara/minitest'
require 'capybara-screenshot/minitest'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

module MigrationButton
  module TestHelper
    extend ActiveSupport::Concern

    cattr_accessor :last_version

    def gen_new_version
      self.last_version ||= Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
      self.last_version += 1
    end

    def create_migration
      version = gen_new_version

      File.open(Rails.root.join("db/migrate/#{version}_foo_#{version}.rb"), "w") do |f|
        f.write("class Foo#{version} < ActiveRecord::Migration[5.2];end")
      end

      version
    end

    def migration_context
      ActiveRecord::MigrationContext.new(Rails.root.join("db/migrate"))
    end

    def migrator
      MigrationButton::Runner.new
    end

    included do
      setup do
        ActiveRecord::Base.connection.execute("DELETE FROM schema_migrations")

        migrator.migrate
      end

      teardown do
        Dir["#{Rails.root.join('db/migrate')}/*"]
          .select { |file| file =~ /[0-9]+_foo_[0-9]+\.rb/ }
          .each   { |file| FileUtils.remove file }
      end
    end
  end

  class IntegrationTest < ActionDispatch::IntegrationTest
    include TestHelper
  end

  class SystemTest < ActionDispatch::SystemTestCase
    include TestHelper
    include Capybara::Screenshot::MiniTestPlugin

    # Make the Capybara DSL available in all integration tests
    include Capybara::DSL
    # Make `assert_*` methods behave like Minitest assertions
    include Capybara::Minitest::Assertions

    def teardown
      Capybara.reset_sessions!
      Capybara.use_default_driver
    end
  end

  class TestCase < ActiveSupport::TestCase
    include TestHelper
  end
end
