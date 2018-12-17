# frozen_string_literal: true

require 'test_helper'

class VisitingMigrationsStatusPageTest < MigrationButton::IntegrationTest
  test "showing the app's page when there's no pending migrations" do
    get "/users"

    assert_response :success
    assert_equal "/users", path
    assert_select "body", /Users#index/
  end

  test "showing the engine's migration status page when there's a pending migration" do
    create_migration

    get "/users"

    assert_response :error
    assert_equal "/users", path
    assert_select "body", /There are pending migrations/
  end

  test "visiting mounted migration status page" do
    get MigrationButton.mount_path

    assert_response :success
    assert_equal "#{MigrationButton.mount_path}/", path

    assert_select "body", /There are no pending migrations/
  end

  test "visiting mounted migration status page where there's a pending migration" do
    create_migration

    get MigrationButton.mount_path

    assert_response :success
    assert_equal "#{MigrationButton.mount_path}/", path

    assert_select "body", /There are pending migrations/
  end
end
