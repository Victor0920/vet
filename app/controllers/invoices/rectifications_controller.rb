class Invoices::RectificationsController < ApplicationController
  before_action :set_original
  before_action :set_form_options

  # Starts as a full refund: every line of the original, quantity negated
  def new
    @invoice = new_rectification(store: @original.store, employee: Current.employee, date: Time.current)
    @original.invoice_products.each do |line|
      @invoice.invoice_products.build(product: line.product, service: line.service,
        description: line.description, price: line.price, quantity: -line.quantity)
    end
  end

  def create
    @invoice = new_rectification(rectification_params)

    if @invoice.save
      redirect_to invoice_path(@invoice), notice: t("flash.invoices.rectification_created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Only a regular invoice of this enterprise can be rectified
  def set_original
    @original = Current.enterprise.invoices.find_by(id: params[:invoice_id])
    if @original.nil?
      redirect_to invoices_url, alert: t("flash.invoices.not_found")
    elsif @original.corrective?
      redirect_to invoice_path(@original), alert: t("flash.invoices.cannot_rectify_rectification")
    end
  end

  def set_form_options
    @stores = Current.enterprise.stores.order(:name)
    @employees = Current.enterprise.employees.order(:first_name)
  end

  # Enterprise and customer always come from the original, never from the form
  def new_rectification(attributes)
    @original.corrective_invoices.new(attributes).tap do |invoice|
      invoice.enterprise = Current.enterprise
      invoice.customer = @original.customer
    end
  end

  def rectification_params
    params.expect(invoice: [ :date, :store_id, :employee_id,
      invoice_products_attributes: [ [ :product_id, :service_id, :description, :price, :quantity, :_destroy ] ] ])
  end
end
