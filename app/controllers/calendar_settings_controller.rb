class CalendarSettingsController < ApplicationController
  include AdminOnly
  before_action :set_enterprise

  def show
  end

  def edit
  end

  def update
    if @enterprise.update(calendar_settings_params)
      redirect_to calendar_settings_path, notice: t("flash.calendar_settings.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

    private

  def set_enterprise
    @enterprise = Current.enterprise
  end

  def calendar_settings_params
    params.expect(enterprise: [ :calendar_opens_at, :calendar_closes_at, :default_appointment_minutes ])
  end
end
