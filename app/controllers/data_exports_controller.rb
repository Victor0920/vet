class DataExportsController < ApplicationController
  include AdminOnly
  rate_limit to: 5, within: 1.hour, only: :create,
    with: -> { redirect_to data_export_path, alert: t("flash.data_exports.rate_limited") }

  def show
  end

  # Asks for the password again: whoever downloads this gets every customer's personal data
  def create
    if Current.employee.authenticate(params[:password].to_s)
      export = DataExport.new(Current.enterprise)
      Rails.logger.info "[DataExport] enterprise=#{Current.enterprise.id} employee=#{Current.employee.id}"
      send_data export.to_zip, filename: export.filename, type: "application/zip"
    else
      redirect_to data_export_path, alert: t("flash.data_exports.wrong_password")
    end
  end
end
