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
end
