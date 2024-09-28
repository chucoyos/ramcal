require "test_helper"

class RoleTest < ActiveSupport::TestCase
  test "should not save role without name" do
    role = Role.new
    assert_not role.save, "Saved the role without a name"
  end

  test "should save role with name" do
    role = Role.new
    role.name = "admin"
    assert role.save, "Saved the role with a name"
  end
  test "should not save role with duplicate name" do
    role = Role.new
    role.name = "admin"
    role.save
    role2 = Role.new
    role2.name = "admin"
    assert_not role2.save, "Saved the role with a duplicate name"
  end
  test "should add user to role" do
    role = Role.new
    role.name = "admin"
    role.save
    user = User.new
    user.email = "admin@gmail.com"
    user.first_name = "Admin"
    user.last_name = "Admin"
    user.password = "password"
    user.username = "admin"
    user.save
    role.users << user
    assert role.users.count == 1, "User not added to role"
  end
  test "should remove user from role" do
    role = Role.new
    role.name = "admin"
    role.save
    user = User.new
    user.email = "admin@gmail.com"
    user.first_name = "Admin"
    user.last_name = "Admin"
    user.password = "password"
    user.username = "admin"
    user.save
    role.users << user
    role.users.delete(user)
    assert role.users.count == 0, "User not removed from role"
  end
  test "should add permission to role" do
    role = Role.new
    role.name = "admin"
    role.save
    permission = Permission.new
    permission.name = "create"
    permission.save
    role.permissions << permission
    assert role.permissions.count == 1, "Permission not added to role"
  end
  test "should remove permission from role" do
    role = Role.new
    role.name = "admin"
    role.save
    permission = Permission.new
    permission.name = "create"
    permission.save
    role.permissions << permission
    role.permissions.delete(permission)
    assert role.permissions.count == 0, "Permission not removed from role"
  end
end
