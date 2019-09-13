require 'test_helper'

class QuestionCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @question_category = question_categories(:one)
  end

  test "should get index" do
    get question_categories_url, as: :json
    assert_response :success
  end

  test "should create question_category" do
    assert_difference('QuestionCategory.count') do
      post question_categories_url, params: { question_category: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show question_category" do
    get question_category_url(@question_category), as: :json
    assert_response :success
  end

  test "should update question_category" do
    patch question_category_url(@question_category), params: { question_category: {  } }, as: :json
    assert_response 200
  end

  test "should destroy question_category" do
    assert_difference('QuestionCategory.count', -1) do
      delete question_category_url(@question_category), as: :json
    end

    assert_response 204
  end
end
