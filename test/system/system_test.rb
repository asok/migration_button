require "test_helper"

class SystemTest < MigrationButton::SystemTest
  driven_by :rack_test

  test "doing GET call, showing the errors page, migrating and resuming" do
    version = create_migration

    visit "/users"

    assert_equal "/users", current_path
    assert page.has_content?("There are pending migrations")

    click_on "Migrate"
    assert page.has_content?("There are no pending migrations")
    assert migration_context.current_version == version

    click_on "Resume"
    assert_equal "/users", current_path
    assert page.has_content?("Users#index")
  end

  test "doing POST call, showing the error page, migration and resuming" do
    visit "/users/new"

    version = create_migration

    fill_in "user[name]", with: "Test"
    click_on "Create User"

    assert_equal "/users", current_path
    assert_equal User.count, 0
    click_on "Migrate"
    assert page.has_content?("There are no pending migrations")
    assert migration_context.current_version == version

    click_on "Resume"
    assert_equal "/users", current_path
    assert_equal User.count, 1
    assert page.has_content?("Users#index")
  end
end
