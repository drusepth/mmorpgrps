require 'test_helper'

class WorldControllerTest < ActionController::TestCase
  test "should get map" do
    get :map
    assert_response :success
  end

  test "should get scoreboards" do
    get :scoreboards
    assert_response :success
  end

end
