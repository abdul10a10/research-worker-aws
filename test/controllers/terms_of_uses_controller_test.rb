require 'test_helper'

class TermsOfUsesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @terms_of_use = terms_of_uses(:one)
  end

  test "should get index" do
    get terms_of_uses_url, as: :json
    assert_response :success
  end

  test "should create terms_of_use" do
    assert_difference('TermsOfUse.count') do
      post terms_of_uses_url, params: { terms_of_use: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show terms_of_use" do
    get terms_of_use_url(@terms_of_use), as: :json
    assert_response :success
  end

  test "should update terms_of_use" do
    patch terms_of_use_url(@terms_of_use), params: { terms_of_use: {  } }, as: :json
    assert_response 200
  end

  test "should destroy terms_of_use" do
    assert_difference('TermsOfUse.count', -1) do
      delete terms_of_use_url(@terms_of_use), as: :json
    end

    assert_response 204
  end
end
