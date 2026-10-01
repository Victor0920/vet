class PasswordsMailer < ApplicationMailer
  def reset(employee)
    @employee = employee
    mail subject: "Reset your password", to: employee.email_address
  end
end
