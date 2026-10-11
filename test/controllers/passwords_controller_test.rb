require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { @employee = employees(:one) }

  test "new" do
    get new_password_path
    assert_response :success
  end

  test "create" do
    post passwords_path, params: { email_address: @employee.email_address }
    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @employee ]
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice I18n.t("flash.passwords.instructions_sent")
  end

  test "create for an unknown employee redirects but sends no mail" do
    post passwords_path, params: { email_address: "missing-employee@example.com" }
    assert_enqueued_emails 0
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice I18n.t("flash.passwords.instructions_sent")
  end

  test "edit" do
    get edit_password_path(@employee.password_reset_token)
    assert_response :success
  end

  test "edit with invalid password reset token" do
    get edit_password_path("invalid token")
    assert_redirected_to new_password_path

    follow_redirect!
    assert_notice I18n.t("flash.passwords.invalid_token")
  end

  test "update" do
    assert_changes -> { @employee.reload.password_digest } do
      put password_path(@employee.password_reset_token), params: { password: "new", password_confirmation: "new" }
      assert_redirected_to new_session_path
    end

    follow_redirect!
    assert_notice I18n.t("flash.passwords.reset")
  end

  test "update with non matching passwords" do
    token = @employee.password_reset_token
    assert_no_changes -> { @employee.reload.password_digest } do
      put password_path(token), params: { password: "no", password_confirmation: "match" }
      assert_redirected_to edit_password_path(token)
    end

    follow_redirect!
    assert_notice I18n.t("flash.passwords.mismatch")
  end

  private

  def assert_notice(text)
    assert_select "div", /#{Regexp.escape(text)}/
  end
end
