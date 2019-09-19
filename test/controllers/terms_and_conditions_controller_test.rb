require 'test_helper'

class TermsAndConditionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @terms_and_condition = terms_and_conditions(:one)
  end

  test "should get index" do
    get terms_and_conditions_url, as: :json
    assert_response :success
  end

  test "should create terms_and_condition" do
    assert_difference('TermsAndCondition.count') do
      post terms_and_conditions_url, params: { terms_and_condition: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show terms_and_condition" do
    get terms_and_condition_url(@terms_and_condition), as: :json
    assert_response :success
  end

  test "should update terms_and_condition" do
    patch terms_and_condition_url(@terms_and_condition), params: { terms_and_condition: {  } }, as: :json
    assert_response 200
  end

  test "should destroy terms_and_condition" do
    assert_difference('TermsAndCondition.count', -1) do
      delete terms_and_condition_url(@terms_and_condition), as: :json
    end

    assert_response 204
  end
end
