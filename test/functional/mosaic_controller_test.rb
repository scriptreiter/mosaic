require 'test_helper'

class MosaicControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get portal" do
    get :portal
    assert_response :success
  end

end
