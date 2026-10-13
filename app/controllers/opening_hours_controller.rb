class OpeningHoursController < ApplicationController
  include AdminOnly

  before_action :set_store
  before_action :set_opening_hour, only: %i[ edit update destroy ]

  def new
    @opening_hour = @store.opening_hours.new(opens_at: "09:00", closes_at: "14:00")
    @weekdays = [ 1, 2, 3, 4, 5 ] # Monday to Friday ticked to start with
  end

  # The same period on every ticked day (e.g. 09:00–14:00 Monday to Friday): one row per day
  def create
    @opening_hour = @store.opening_hours.new(opening_hour_params)
    @weekdays = Array(params[:weekdays]).compact_blank.map(&:to_i) & OpeningHour::WEEKDAYS
    periods = @weekdays.map { |weekday| @store.opening_hours.new(opening_hour_params.merge(weekday: weekday)) }

    if periods.empty?
      @opening_hour.errors.add(:base, :no_weekdays)
      render :new, status: :unprocessable_entity
    elsif (invalid = periods.find(&:invalid?))
      @opening_hour.errors.merge!(invalid.errors)
      render :new, status: :unprocessable_entity
    else
      OpeningHour.transaction { periods.each(&:save!) }
      redirect_to store_path(@store), notice: t("flash.opening_hours.created", count: periods.size)
    end
  end

  def edit
  end

  def update
    if @opening_hour.update(opening_hour_params.merge(weekday: params.dig(:opening_hour, :weekday)))
      redirect_to store_path(@store), notice: t("flash.opening_hours.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @opening_hour.destroy
    redirect_to store_path(@store), notice: t("flash.opening_hours.deleted"), status: :see_other
  end

  private

  def set_store
    @store = Current.enterprise.stores.find_by(id: params[:store_id])
    redirect_to stores_url, alert: t("flash.stores.not_found") if @store.nil?
  end

  # Through the store, so changing the id in the URL can't reach another store's hours
  def set_opening_hour
    @opening_hour = @store.opening_hours.find_by(id: params[:id])
    redirect_to store_url(@store), alert: t("flash.opening_hours.not_found") if @opening_hour.nil?
  end

  def opening_hour_params
    params.expect(opening_hour: [ :opens_at, :closes_at ])
  end
end
