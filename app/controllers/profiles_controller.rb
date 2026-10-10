class ProfilesController < ApplicationController
  before_action :set_employee

  def show
    @appointments = @employee.appointments.upcoming.includes(:customer, { pet: :customer }, :room)
  end

  def update
    if @employee.update(profile_params)
      key = @employee.saved_change_to_locale? ? "flash.employees.language_updated" : "flash.employees.updated"
      # This action still runs in the OLD language, so build the message in the new one
      notice = I18n.with_locale(@employee.locale) { t(key) }
      redirect_to profile_path, notice: notice
    else
      redirect_to profile_path, alert: @employee.errors.full_messages.to_sentence
    end
  end

  private

  # Always yourself: the URL has no id to change
  def set_employee
    @employee = Current.employee
  end

  # Only what you may change about yourself: no :role or :active, or anyone
  # could submit employee[role]=admin and promote themselves
  def profile_params
    params.expect(employee: [ :first_name, :last_name, :phone, :photo, :locale ])
  end
end
