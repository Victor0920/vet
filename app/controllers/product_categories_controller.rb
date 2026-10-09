class ProductCategoriesController < ApplicationController
  before_action :set_category, only: %i[ show edit update ]

  def index
    # includes(:products) so category.products.size in the table doesn't run a query per row
    @categories = Current.enterprise.product_categories.includes(:products).order(:name)
  end

  def show
    @products = @category.products.order(:name)
  end

  def new
    @category = Current.enterprise.product_categories.new
  end


  def create
    @category = Current.enterprise.product_categories.new(category_params)

    if @category.save
      redirect_to product_categories_path(), notice: t("flash.product_categories.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to product_category_path(@category), notice: t("flash.product_categories.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

    private

  def set_category
    @category = Current.enterprise.product_categories.find_by(id: params[:id])
    redirect_to product_categories_url, alert: t("flash.product_categories.not_found") if @category.nil?
  end

  # The form is built from a ProductCategory, so its params arrive under :product_category
  def category_params
    params.expect(product_category: [ :name ])
  end
end
