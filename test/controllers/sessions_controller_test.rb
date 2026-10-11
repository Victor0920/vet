require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @employee = employees(:one) }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: { login_code: "one", username: "one", password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { login_code: "one", username: "one", password: "wrong" }

    assert_response :unprocessable_entity
    assert_nil cookies[:session_id]
  end

  test "create with another company's ID" do
    post session_path, params: { login_code: "two", username: "one", password: "password" }

    assert_response :unprocessable_entity
    assert_nil cookies[:session_id]
  end
end
