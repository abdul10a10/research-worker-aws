require 'test_helper'

class BlacklistUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @blacklist_user = blacklist_users(:one)
  end

  test "should get index" do
    get blacklist_users_url, as: :json
    assert_response :success
  end

  test "should create blacklist_user" do
    assert_difference('BlacklistUser.count') do
      post blacklist_users_url, params: { blacklist_user: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show blacklist_user" do
    get blacklist_user_url(@blacklist_user), as: :json
    assert_response :success
  end

  test "should update blacklist_user" do
    patch blacklist_user_url(@blacklist_user), params: { blacklist_user: {  } }, as: :json
    assert_response 200
  end

  test "should destroy blacklist_user" do
    assert_difference('BlacklistUser.count', -1) do
      delete blacklist_user_url(@blacklist_user), as: :json
    end

    assert_response 204
  end
end
