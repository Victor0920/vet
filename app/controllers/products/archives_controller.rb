class Products::ArchivesController < ApplicationController
  include AdminOnly
  before_action :set_product

  def create
    @product.archive
    redirect_to product_path(@product), notice: t("flash.products.archived"), status: :see_other
  end

  def destroy
    @product.unarchive
    redirect_to product_path(@product), notice: t("flash.products.unarchived"), status: :see_other
  end

    private

  def set_product
    @product = Current.enterprise.products.find_by(id: params[:product_id])
    redirect_to products_url, alert: t("flash.products.not_found") if @product.nil?
  end
end
