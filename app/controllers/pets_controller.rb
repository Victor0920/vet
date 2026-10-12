class PetsController < ApplicationController
  before_action :set_customer, except: :index
  before_action :set_species_options, only: %i[ index new create edit update ]
  before_action :set_pet, only: %i[ show edit update ]
  before_action :set_employees, only: %i[ new create edit update ]

  def index
    @query = params[:q].to_s.strip
    @species_id = params[:species_id].presence
    @pets = Current.enterprise.pets
      .search(@query)
      .includes(:pet_species, :customer, photo_attachment: :blob) # avoids a query per row
      .order(:name)
    @pets = @pets.where(pet_species_id: @species_id) if @species_id
  end

  def show
    @weights = @pet.pet_weights.order(:measured_on)
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

  # Active staff, plus the pet's current usual vet even if they've been deactivated
  def set_employees
    employees = Current.enterprise.employees
    @employees = employees.active.or(employees.where(id: @pet&.usual_employee_id)).order(:first_name, :last_name)
  end

  def set_species_options
    @species_options = PetSpecies.all.sort_by(&:display_name)
  end

  # Strong parameters: only these fields can be changed from a form
  def pet_params
    params.expect(pet: [ :name, :pet_species_id, :breed, :sex, :born_on, :color, :usual_employee_id,
      :transponder_number, :transponder_location, :notes, :photo, :sterilized ])
  end
end
