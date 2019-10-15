require 'test_helper'

class EligibleCandidatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @eligible_candidate = eligible_candidates(:one)
  end

  test "should get index" do
    get eligible_candidates_url, as: :json
    assert_response :success
  end

  test "should create eligible_candidate" do
    assert_difference('EligibleCandidate.count') do
      post eligible_candidates_url, params: { eligible_candidate: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show eligible_candidate" do
    get eligible_candidate_url(@eligible_candidate), as: :json
    assert_response :success
  end

  test "should update eligible_candidate" do
    patch eligible_candidate_url(@eligible_candidate), params: { eligible_candidate: {  } }, as: :json
    assert_response 200
  end

  test "should destroy eligible_candidate" do
    assert_difference('EligibleCandidate.count', -1) do
      delete eligible_candidate_url(@eligible_candidate), as: :json
    end

    assert_response 204
  end
end
