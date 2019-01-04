# frozen_string_literal: true

module MigrationButton
  class Middleware < ActiveRecord::Migration::CheckPending
    cattr_accessor :last_request

    def call(env)
      case env['PATH_INFO']
      when /#{MigrationButton.mount_path}/,
           %r(\A/{0,2}#{::Rails.application.config.assets.prefix})
        @app.call env
      else
        protected_app_call(env) { super }
      end
    end

    def protected_app_call(env)
      yield.tap do
        self.class.last_request = nil
      end
    rescue ActiveRecord::PendingMigrationError
      self.class.last_request = Rack::Request.new(env)
      migrations_status_response
    end

    def migrations_status_response
      [
        500,
        {'Content-Type' => 'text/html; charset=utf-8'},
        [render_migrations_status]
      ]
    end

    def render_migrations_status
      MigrationButton::RunnerController
        .render('index',
                assigns: {
                  page: MigrationButton::RunnerController.page
                })
    end
  end
end
