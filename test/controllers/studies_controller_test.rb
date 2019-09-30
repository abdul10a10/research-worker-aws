require 'test_helper'

class StudiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @study = studies(:one)
  end

  test "should get index" do
    get studies_url, as: :json
    assert_response :success
  end

  test "should create study" do
    assert_difference('Study.count') do
      post studies_url, params: { study: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show study" do
    get study_url(@study), as: :json
    assert_response :success
  end

  test "should update study" do
    patch study_url(@study), params: { study: {  } }, as: :json
    assert_response 200
  end

  test "should destroy study" do
    assert_difference('Study.count', -1) do
      delete study_url(@study), as: :json
    end

    assert_response 204
  end
end
