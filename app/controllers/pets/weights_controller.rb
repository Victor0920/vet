class Pets::WeightsController < ApplicationController
  before_action :set_pet

  def new
    @weight = @pet.pet_weights.new(measured_on: Date.current)
  end

  def create
    # One weight per day: saving another one for the same date replaces it
    @weight = @pet.pet_weights.find_or_initialize_by(measured_on: weight_params[:measured_on])
    @weight.weight = weight_params[:weight]

    if @weight.save
      redirect_to customer_pet_path(@customer, @pet), notice: t("flash.pet_weights.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @pet.pet_weights.find(params[:id]).destroy
    redirect_to customer_pet_path(@customer, @pet), notice: t("flash.pet_weights.deleted"), status: :see_other
  end

  private

  # Scoped through the enterprise, so nobody can add weights to another clinic's pet
  def set_pet
    @customer = Current.enterprise.customers.find_by(id: params[:customer_id])
    @pet = @customer&.pets&.find_by(id: params[:pet_id])
    redirect_to customers_url, alert: t("flash.pets.not_found") if @pet.nil?
  end

  def weight_params
    params.expect(pet_weight: [ :weight, :measured_on ])
  end
end
