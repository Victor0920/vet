class ServicesController < ApplicationController
  before_action :set_service, only: %i[ show edit update ]
  before_action :set_categories, only: %i[ index new create edit update ]

  def index
    @query = params[:q].to_s.strip
    @category_id = params[:category_id].presence
    @services = Current.enterprise.services
      .search(@query)
      .includes(:service_category) # avoids one query per row for the category badge
      .order(:name)
    @services= @services.where(service_category_id: @category_id) if @category_id
  end

  def show
  end

  def new
    @service= Current.enterprise.services.new
  end

  def create
    @service= Current.enterprise.services.new(service_params)

    if @service.save
      redirect_to service_path(@service), notice: t("flash.services.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @service.update(service_params)
      redirect_to service_path(@service), notice: t("flash.services.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

   private

  def set_service
    @service = Current.enterprise.services.find_by(id: params[:id])
    redirect_to services_url, alert: t("flash.services.not_found") if @service.nil?
  end

  def set_categories
    @categories = Current.enterprise.service_categories.order(:name)
  end

  def service_params
    params.expect(service: [ :name, :description, :price, :service_category_id ])
  end
end
