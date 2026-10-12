class Services::ArchivesController < ApplicationController
  include AdminOnly
  before_action :set_service

  def create
    @service.archive
    redirect_to service_path(@service), notice: t("flash.services.archived"), status: :see_other
  end

  def destroy
    @service.unarchive
    redirect_to service_path(@service), notice: t("flash.services.unarchived"), status: :see_other
  end

    private

  def set_service
    @service = Current.enterprise.services.find_by(id: params[:service_id])
    redirect_to services_url, alert: t("flash.services.not_found") if @service.nil?
  end
end
