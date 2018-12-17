# frozen_string_literal: true

require "migration_button/middleware"
require "migration_button/engine"
require "migration_button/runner"

module MigrationButton
  mattr_accessor :mount_path
  self.mount_path = "/__migration_button"
end
