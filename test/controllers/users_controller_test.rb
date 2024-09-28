require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
    @role = roles(:role_one)
    @role.users << @user
    sign_in @user
  end
  test "should get index" do
    get users_url
    assert_response :success
  end
  test "should get new" do
    get new_user_url
    assert_response :success
  end
  test "should edit user" do
    get edit_user_url(@user)
    assert_response :success
  end
  test "should show user" do
    get user_url(@user)
    assert_response :success
  end
  test "should create user" do
    assert_difference("User.count") do
      post members_url, params: { user: { email: "uno@gmail.com", first_name: "Uno", last_name: "Dos", password: "password", role_id: @role.id, username: "uno" } }
    end
  end
end
