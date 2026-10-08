class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_employee_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: t("flash.passwords.rate_limited") }

  def new
  end

  def create
    if employee = Employee.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(employee).deliver_later
    end

    redirect_to new_session_path, notice: t("flash.passwords.instructions_sent")
  end

  def edit
  end

  def update
    if @employee.update(params.permit(:password, :password_confirmation))
      @employee.sessions.destroy_all
      redirect_to new_session_path, notice: t("flash.passwords.reset")
    else
      redirect_to edit_password_path(params[:token]), alert: t("flash.passwords.mismatch")
    end
  end

  private
  def set_employee_by_token
    @employee = Employee.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path, alert: t("flash.passwords.invalid_token")
  end
end
