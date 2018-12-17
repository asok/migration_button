# frozen_string_literal: true

require 'test_helper'

class RunningMigrationsTest < MigrationButton::IntegrationTest
  test "the request for migrating" do
    version_a = create_migration
    version_b = create_migration

    post "#{MigrationButton.mount_path}/migrate"

    assert_response :success
    assert_match "#{version_a} Foo1: migrated", @response.body
    assert_match "#{version_b} Foo2: migrated", @response.body

    assert migration_context.current_version == version_b
  end

  test "the request for migrating a specific version" do
    version_a = create_migration
    create_migration

    post "/#{MigrationButton.mount_path}/up/#{version_a}"

    assert_response :success
    assert_match "#{version_a} Foo1: migrated", @response.body
    assert migration_context.current_version == version_a
  end

  test "the request for rolling back a specific version" do
    version_a = create_migration
    version_b = create_migration

    migrator.migrate

    post "/#{MigrationButton.mount_path}/down/#{version_a}"

    assert_response :success
    assert_match "#{version_a} Foo1: reverted", @response.body
    assert migration_context.current_version == version_b
  end
end
