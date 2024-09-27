require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "should not save user without email" do
    user = User.new
    assert_not user.save, "Saved the user without an email"
  end
  test "should not save user without password" do
    user = User.new
    assert_not user.save, "Saved the user without a password"
  end
  test "should not save user without username" do
    user = User.new
    assert_not user.save, "Saved the user without a username"
  end
  test "should not save user without first name" do
    user = User.new
    assert_not user.save, "Saved the user without a first name"
  end
  test "email should be unique" do
    user = User.new(email: users(:user_one).email)
    assert_not user.save, "Saved the user with a duplicate email"
  end
  test "username should be unique" do
    user = User.new(username: users(:user_one).username)
    assert_not user.save, "Saved the user with a duplicate username"
  end
end
