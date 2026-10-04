class PetsController < ApplicationController
  before_action :set_pet

  def show
  end

  def edit
  end

  def update
    # Back to the edit page, so you can keep editing other fields
    if @pet.update(pet_params)
      redirect_to edit_customer_pet_path(@customer, @pet), notice: "Pet updated"
    else
      redirect_to edit_customer_pet_path(@customer, @pet), alert: @pet.errors.full_messages.to_sentence
    end
  end

  private

  # Looking the pet up through the customer means /customers/1/pets/5
  # only works if pet 5 really belongs to customer 1.
  def set_pet
    @customer = Customer.find_by(id: params[:customer_id])
    @pet = @customer&.pets&.find_by(id: params[:id])
    redirect_to customers_url, alert: "Pet not found" if @pet.nil?
  end

  # Strong parameters: only these fields can be changed from a form
  def pet_params
    params.expect(pet: [ :name, :species, :breed, :sex, :born_on, :color,
                         :transponder_number, :transponder_location, :notes, :photo ])
  end
end
