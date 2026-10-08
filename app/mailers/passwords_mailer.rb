def reset(employee)
  @employee = employee
  # No subject: here: Rails reads passwords_mailer.reset.subject from the YAML
  I18n.with_locale(employee.locale) do
    mail to: employee.email_address
  end
end
