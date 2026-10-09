class ServiceCategoriesController < ApplicationController
  before_action :set_category, only: %i[ show edit update ]

  def index
    # includes(:services) so category.services.size in the table doesn't run a query per row
    @categories = Current.enterprise.service_categories.includes(:services).order(:name)
  end

  def show
    @services = @category.services.order(:name)
  end

  def new
    @category = Current.enterprise.service_categories.new
  end


  def create
    @category = Current.enterprise.service_categories.new(category_params)

    if @category.save
      redirect_to service_category_path(@category), notice: t("flash.service_categories.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to service_category_path(@category), notice: t("flash.service_categories.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

    private

  def set_category
    @category = Current.enterprise.service_categories.find_by(id: params[:id])
    redirect_to service_categories_url, alert: t("flash.service_categories.not_found") if @category.nil?
  end

  # The form is built from a ServiceCategory, so its params arrive under :service_category
  def category_params
    params.expect(service_category: [ :name, :color ])
  end
end
