class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ show edit update ]

  def index
    @customers = Current.enterprise.customers.all
  end

  def new
    @customer = Current.enterprise.customers.new
  end

  def show
    @pets = @customer.pets
    @new_pet = Pet.new(customer_id: @customer.id)
  end

  def edit
  end

  def create
    @customer = Current.enterprise.customers.new(customer_params)

    if @customer.save
      redirect_to customer_path(@customer), notice: "Customer created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # Back to the edit page, so you can keep editing other fields
    if @customer.update(customer_params)
      redirect_to edit_customer_path(@customer), notice: "Customer updated"
    else
      redirect_to edit_customer_path(@customer), alert: @customer.errors.full_messages.to_sentence
    end
  end

  private

  def set_customer
    @customer = Current.enterprise.customers.find_by(id: params[:id])
    redirect_to customers_url, alert: "Customer not found" if @customer.nil?
  end

  # Strong parameters: only these fields can be changed from a form
  def customer_params
    params.expect(customer: [ :first_name, :first_surname, :second_surname, :sex,
      :document_type, :document_number, :email, :first_phone, :second_phone,
      :born_on, :address, :post_code, :province, :photo ])
  end
end
