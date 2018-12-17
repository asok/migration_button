# frozen_string_literal: true

require 'active_record'

module MigrationButton
  module RunnerHelper
    protected

    def capture_output
      logger                      = ActiveRecord::Base.logger
      ::ActiveRecord::Base.logger = nil
      stdout                      = $stdout

      $stdout = StringIO.new

      yield

      $stdout.string || ""
    ensure
      ::ActiveRecord::Base.logger = logger
      $stdout = stdout
    end

    def migrations_paths
      Rails.application.paths['db/migrate'].to_a
    end
  end

  class Implementation
    include RunnerHelper

    def initialize
      @migrator = ActiveRecord::MigrationContext.new(migrations_paths)
    end

    def migrations_status
      @migrator.migrations_status
    end

    def migrate
      capture_output do
        @migrator.migrate
      end
    end

    def rollback
      capture_output do
        @migrator.rollback
      end
    end

    def run(direction, version)
      capture_output do
        @migrator.run(direction.intern, version.to_i)
      end
    end
  end

  class LegacyImplementation
    include RunnerHelper

    def migrations_status
      ActiveRecord::Migrator.migrations_status(migrations_paths)
    end

    def migrate
      capture_output do
        ActiveRecord::Migrator.migrate(migrations_paths)
      end
    end

    def rollback
      capture_output do
        ActiveRecord::Migrator.rollback(migrations_paths)
      end
    end

    def run(direction, version)
      capture_output do
        ActiveRecord::Migrator.run(direction.intern, migrations_paths, version.to_i)
      end
    end
  end

  # rubocop:disable Naming/ConstantName
  Runner = if Gem::Version.new(Rails.version) >= Gem::Version.new('5.2.1.1')
             Implementation
           else
             LegacyImplementation
           end
end
