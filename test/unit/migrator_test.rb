# frozen_string_literal: true

require 'test_helper'

class RunnerTest < MigrationButton::TestCase
  test "#run up" do
    version_a = create_migration
    version_b = create_migration
    version_c = create_migration

    output = migrator.run("up", version_a)

    assert_match    /#{version_a} Foo1: migrating/, output
    assert_no_match /#{version_b} Foo2: migrating/, output
    assert_no_match /#{version_c} Foo3: migrating/, output

    assert migration_context.current_version == version_a
  end

  test "#run down" do
    version_a = create_migration
    version_b = create_migration
    version_c = create_migration

    migrator.migrate
    output = migrator.run("down", version_b)

    assert_no_match /#{version_a} Foo1: reverting/, output
    assert_match    /#{version_b} Foo2: reverting/, output
    assert_no_match /#{version_c} Foo3: reverting/, output

    assert migration_context.current_version == version_c
  end

  test "#rollback" do
    version_a = create_migration
    version_b = create_migration

    migrator.migrate

    output = migrator.rollback
    assert_match    /#{version_b} Foo2: reverting/, output
    assert_no_match /#{version_a} Foo1: reverting/, output

    assert migration_context.current_version == version_a
  end
end
