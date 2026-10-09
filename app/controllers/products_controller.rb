 class ProductsController < ApplicationController
   before_action :set_product, only: %i[ show edit update ]
   before_action :set_categories, only: %i[ index new create edit update ]

   def index
     @query = params[:q].to_s.strip
     @category_id = params[:category_id].presence
     @products = Current.enterprise.products
       .search(@query)
       .includes(:product_category, photo_attachment: :blob) # avoids one query per row for the category badge
       .order(:name)
     @products = @products.where(product_category_id: @category_id) if @category_id
   end

   def show
   end

   def new
     @product = Current.enterprise.products.new
   end

   def create
     @product = Current.enterprise.products.new(product_params)

     if @product.save
       redirect_to product_path(@product), notice: t("flash.products.created")
     else
       render :new, status: :unprocessable_entity
     end
   end

   def edit
   end

   def update
     if @product.update(product_params)
       redirect_to product_path(@product), notice: t("flash.products.updated")
     else
       render :edit, status: :unprocessable_entity
     end
   end

   private

   def set_product
     @product = Current.enterprise.products.find_by(id: params[:id])
     redirect_to products_url, alert: t("flash.products.not_found") if @product.nil?
   end

   def set_categories
     @categories = Current.enterprise.product_categories.order(:name)
   end

   def product_params
     params.expect(product: [ :name, :description, :price, :product_category_id, :photo ])
   end
 end
