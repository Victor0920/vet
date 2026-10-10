class StoresController < ApplicationController
  before_action :set_store, only: %i[ show edit update ]

  def index
    @stores = Current.enterprise.stores.includes(:rooms, photo_attachment: :blob).order(:name)
  end

  def show
  end

  def edit
  end

  def new
    @store = Current.enterprise.stores.new
  end

  def update
    if @store.update(store_params)
      redirect_to store_path(@store), notice: t("flash.stores.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    @store = Current.enterprise.stores.new(store_params)

    if @store.save
      redirect_to store_path(@store), notice: t("flash.stores.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_store
    @store = Current.enterprise.stores.find_by(id: params[:id])
    redirect_to settings_url, alert: t("flash.stores.not_found") if @store.nil?
  end

  def store_params
    params.expect(store: [ :name, :address, :post_code, :photo ])
  end
end
