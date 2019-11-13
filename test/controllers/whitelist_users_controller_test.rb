require 'test_helper'

class WhitelistUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @whitelist_user = whitelist_users(:one)
  end

  test "should get index" do
    get whitelist_users_url, as: :json
    assert_response :success
  end

  test "should create whitelist_user" do
    assert_difference('WhitelistUser.count') do
      post whitelist_users_url, params: { whitelist_user: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show whitelist_user" do
    get whitelist_user_url(@whitelist_user), as: :json
    assert_response :success
  end

  test "should update whitelist_user" do
    patch whitelist_user_url(@whitelist_user), params: { whitelist_user: {  } }, as: :json
    assert_response 200
  end

  test "should destroy whitelist_user" do
    assert_difference('WhitelistUser.count', -1) do
      delete whitelist_user_url(@whitelist_user), as: :json
    end

    assert_response 204
  end
end
