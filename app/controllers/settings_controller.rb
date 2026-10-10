class SettingsController < ApplicationController
  before_action :require_admin

  def show
  end

  private

  def require_admin
    redirect_to root_path, alert: t("flash.not_authorized") unless Current.employee&.role === "admin"
  end
end
