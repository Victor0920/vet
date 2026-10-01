require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home requires sign in" do
    get root_url
    assert_redirected_to new_session_path
  end

  test "should get home when signed in" do
    sign_in_as(employees(:one))

    get root_url
    assert_response :success
  end
end
