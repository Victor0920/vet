class CustomersController < ApplicationController
  def index
    @customers = Customer.all
  end

  def show
    @customer = Customer.find_by(id: params[:id])
    # NOTE: Add validation to show customers only of current enterprise
    return redirect_to customers_url, alert: "Customer not found" if @customer.nil?

    @pets = @customer.pets
    @new_pet = Pet.new(customer_id: @customer.id)
  end
end
