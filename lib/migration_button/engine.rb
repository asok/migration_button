# frozen_string_literal: true

require 'migration_button/initializer'

module MigrationButton
  class Engine < ::Rails::Engine
    isolate_namespace MigrationButton

    mattr_accessor :_initializer
    self._initializer = MigrationButton::Initializer.new

    config.before_initialize do
      # Config entry `config.active_record.migration_error` is deleted
      # by active record's railtie initializer.
      # So we have to read it in `before_initialize` block,
      # but we need to insert the middleware during initialization.
      if config.active_record.migration_error == :migration_button
        _initializer.on!
      end
    end

    initializer "migration_button.setup" do
      _initializer.add_hook do # rubocop:disable Style/MultilineIfModifier
        config.after_initialize do |app|
          app.routes.prepend do
            mount MigrationButton::Engine => MigrationButton.mount_path, internal: true
          end
        end
      end if _initializer.on?

      _initializer.run(self)

      config.after_initialize do
        MigrationButton::Engine._initializer = nil
      end
    end
  end
end
