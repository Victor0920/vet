class RoomsController < ApplicationController
  before_action :set_store
  before_action :set_room, only: %i[ edit update ]

  def edit
  end

  def new
    @room = @store.rooms.new
  end

  def update
    if @room.update(room_params)
      redirect_to store_path(@store), notice: t("flash.rooms.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    @room = @store.rooms.new(room_params)

    if @room.save
      redirect_to store_path(@store), notice: t("flash.rooms.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_store
    @store = Current.enterprise.stores.find_by(id: params[:store_id])
    redirect_to stores_url, alert: t("flash.stores.not_found") if @store.nil?
  end

  # Through the store, so changing the id in the URL can't reach another store's room
  def set_room
    @room = @store.rooms.find_by(id: params[:id])
    redirect_to store_url(@store), alert: t("flash.rooms.not_found") if @room.nil?
  end

  def room_params
    params.expect(room: [ :name, :color ])
  end
end
