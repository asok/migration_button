# frozen_string_literal: true

module MigrationButton
  class Initializer
    def on!
      if !Rails.env.development? && ENV['MIGRATION_BUTTON'].nil?
        add_warn_hook
      else
        @on = true
        add_insert_middleware_hook
      end
    end

    def run(object)
      hooks.each do |hook|
        object.instance_exec(&hook)
      end
    end

    def add_hook(&hook)
      hooks << hook
    end

    def on?
      !!@on
    end

    protected

    def add_warn_hook
      add_hook do
        Rails.logger.warn(<<-ERR)
MigrationButton engine is considered to be dangeroues in other environments than 'development'.
To surpress this warning message remove line:
`config.active_record.migration_error = :migration_button`
from 'config/environments/#{Rails.env}.rb' file.
Or force using it by settting environment variable 'MIGRATION_BUTTON'.
ERR
      end
    end

    def add_insert_middleware_hook
      add_hook do
        if defined?(::BetterErrors::Middleware) &&
           defined?(::BetterErrors::Railtie) &&
           ::BetterErrors::Railtie.use_better_errors?

          Rails.application.middleware.insert_after ::BetterErrors::Middleware, MigrationButton::Middleware
        else
          config.app_middleware.insert_after ActionDispatch::Callbacks, MigrationButton::Middleware
        end
      end
    end

    def hooks
      @hooks ||= Set.new
    end
  end
end
