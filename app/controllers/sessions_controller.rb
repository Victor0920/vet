class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: t("flash.sessions.rate_limited") }

  def new
    # Remembered from the last sign-in on this computer: staff only type their own ID and password
    @login_code = cookies[:login_code]
  end

  def create
    enterprise = Enterprise.find_by(login_code: params[:login_code])
    # Employee.none when the company ID is wrong: authenticate_by still checks a password,
    # so a wrong company takes as long as a wrong password and gives no hint which one failed
    employees = enterprise ? enterprise.employees.active : Employee.none

    if employee = employees.authenticate_by(username: params[:username].to_s, password: params[:password].to_s)
      cookies.permanent[:login_code] = enterprise.login_code
      start_new_session_for employee
      redirect_to after_authentication_url
    else
      @login_code = params[:login_code]
      flash.now[:alert] = t("flash.sessions.invalid")
      render :new, status: :unprocessable_entity
    end
  end


  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
