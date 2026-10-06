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
    # Back to the edit page, so you can keep editing other fields
    if @pet.update(pet_params)
      redirect_to edit_customer_pet_path(@customer, @pet), notice: "Pet updated"
    else
      redirect_to edit_customer_pet_path(@customer, @pet), alert: @pet.errors.full_messages.to_sentence
    end
  end

  def create
    @pet = @customer.pets.new(pet_params)

    if @pet.save
      redirect_to customer_path(@customer), notice: "Pet created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_customer
    @customer = Customer.find_by(id: params[:customer_id])
    redirect_to customers_url, alert: "Customer not found" if @customer.nil?
  end

  def set_pet
    @pet = @customer.pets.find_by(id: params[:id])
    redirect_to customers_url, alert: "Pet not found" if @pet.nil?
  end

  # Strong parameters: only these fields can be changed from a form
  def pet_params
    params.expect(pet: [ :name, :species, :breed, :sex, :born_on, :color,
                         :transponder_number, :transponder_location, :notes, :photo ])
  end
end
