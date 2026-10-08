module Products
  class StocksController < ApplicationController
    before_action :set_product

    def update
      quantity = params[:quantity].to_i
      amount = params[:direction] == "sell" ? -quantity : quantity

      if quantity.positive? && @product.adjust_stock(amount)
        redirect_back_or_to products_path, notice: t("flash.products.stock_updated", name: @product.name, stock: @product.stock)
      else
        redirect_back_or_to products_path, alert: t("flash.products.stock_invalid", name: @product.name)
      end
    end

    private

    def set_product
      @product = Current.enterprise.products.find_by(id: params[:product_id])
      redirect_to products_path, alert: t("flash.products.not_found") if @product.nil?
    end
  end
end
