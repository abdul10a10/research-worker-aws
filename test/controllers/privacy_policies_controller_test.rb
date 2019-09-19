require 'test_helper'

class PrivacyPoliciesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @privacy_policy = privacy_policies(:one)
  end

  test "should get index" do
    get privacy_policies_url, as: :json
    assert_response :success
  end

  test "should create privacy_policy" do
    assert_difference('PrivacyPolicy.count') do
      post privacy_policies_url, params: { privacy_policy: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show privacy_policy" do
    get privacy_policy_url(@privacy_policy), as: :json
    assert_response :success
  end

  test "should update privacy_policy" do
    patch privacy_policy_url(@privacy_policy), params: { privacy_policy: {  } }, as: :json
    assert_response 200
  end

  test "should destroy privacy_policy" do
    assert_difference('PrivacyPolicy.count', -1) do
      delete privacy_policy_url(@privacy_policy), as: :json
    end

    assert_response 204
  end
end
