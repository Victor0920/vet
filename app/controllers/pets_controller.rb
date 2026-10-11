class PetsController < ApplicationController
  before_action :set_customer
  before_action :set_pet, only: %i[ show edit update ]

  def show
  end

  def edit
  end

  def new
    @pet = @customer.pets.new
  end

  def update
    if @pet.update(pet_params)
      redirect_to customer_pet_path(@customer, @pet), notice: t("flash.pets.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    @pet = @customer.pets.new(pet_params)

    if @pet.save
      redirect_to customer_path(@customer), notice: t("flash.pets.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_customer
    @customer = Current.enterprise.customers.find_by(id: params[:customer_id])
    redirect_to customers_url, alert: t("flash.customers.not_found") if @customer.nil?
  end

  def set_pet
    @pet = @customer.pets.find_by(id: params[:id])
    redirect_to customers_url, alert: t("flash.pets.not_found") if @pet.nil?
  end

  # Strong parameters: only these fields can be changed from a form
  def pet_params
    params.expect(pet: [ :name, :species, :breed, :sex, :born_on, :color,
                         :transponder_number, :transponder_location, :notes, :photo, :sterilized ])
  end
end
