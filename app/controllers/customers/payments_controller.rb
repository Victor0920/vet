class Customers::PaymentsController < ApplicationController
  before_action :set_customer

  def new
    @payment = CustomerPayment.new(customer: @customer, amount: @customer.debt)
  end

  def create
    @payment = CustomerPayment.new(payment_params)
    @payment.customer = @customer
    @payment.employee = Current.employee

    if @payment.save
      redirect_to customer_path(@customer, history: "invoices"), notice: t("flash.payments.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_customer
    @customer = Current.enterprise.customers.find_by(id: params[:customer_id])
    redirect_to customers_url, alert: t("flash.customers.not_found") if @customer.nil?
  end

  def payment_params
    params.expect(customer_payment: [ :amount, :payment_method ])
  end
end
