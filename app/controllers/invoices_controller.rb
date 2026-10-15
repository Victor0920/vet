class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[ show edit update ]
  before_action :set_form_options, only: %i[ new create edit update ]
  before_action :forbid_editing_locked_invoices, only: %i[ edit update ]

  def index
    @query = params[:q].to_s.strip
    @from = date_param(:from)
    @to = date_param(:to)
    @customer_id = params[:customer_id].presence
    # For the customer filter's options
    @customers = Current.enterprise.customers.order(:first_name, :first_surname)
    @invoices = Current.enterprise.invoices
      .search(@query)
      .dated_between(@from, @to)
      .includes(:customer, :employee, :payments, invoice_products: :product, corrective_invoices: :invoice_products)
      .order(date: :desc)
    @invoices = @invoices.where(customer_id: @customer_id) if @customer_id
  end

  def show
    @payments = @invoice.payments.includes(:employee).order(:paid_at)
    respond_to do |format|
      format.html
      format.pdf do
        send_data InvoicePdf.for(@invoice).render,
                  filename: "invoice-#{@invoice.display_number.parameterize}.pdf",
                  type: :pdf,
                  disposition: :attachment
      end
    end
  end

  # /invoices/new?appointment_id=5 or ?customer_id=3 pre-fills the form
  def new
    appointment = Current.enterprise.appointments.find_by(id: params[:appointment_id])
    customer = appointment&.customer || Current.enterprise.customers.find_by(id: params[:customer_id])
    @invoice = Current.enterprise.invoices.new(
      appointment: appointment,
      customer: customer,
      employee: appointment&.employee || Current.employee,
      store: appointment&.store || Current.employee.default_store || @stores.first,
      date: Time.current
    )
    @invoice.invoice_products.build(quantity: 1)
  end

  def create
    @invoice = Current.enterprise.invoices.new(invoice_params)

    if @invoice.save
      redirect_to invoice_path(@invoice), notice: t("flash.invoices.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to invoice_path(@invoice), notice: t("flash.invoices.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_invoice
    @invoice = Current.enterprise.invoices.find_by(id: params[:id])
    redirect_to invoices_url, alert: t("flash.invoices.not_found") if @invoice.nil?
  end

  def set_form_options
    @stores = Current.enterprise.stores.order(:name)
    @employees = Current.enterprise.employees.order(:first_name)
    @customers = Current.enterprise.customers.order(:first_name)
    @appointments = Current.enterprise.appointments.includes(:customer).order(starts_at: :desc)

    # Archived items can't be picked for new lines, but lines that already use one
    # (when editing) still need it in the select. @invoice is only set on edit/update.
    lines = @invoice ? @invoice.invoice_products : []
    products = Current.enterprise.products
    services = Current.enterprise.services
    @products = products.active.or(products.where(id: lines.map(&:product_id))).order(:name)
    @services = services.active.or(services.where(id: lines.map(&:service_id))).order(:name)
  end

  def invoice_params
    params.expect(invoice: [ :date, :store_id, :employee_id, :customer_id, :appointment_id, :paid_now, :payment_method,
      invoice_products_attributes: [ [ :id, :item, :description, :price, :vat_rate, :quantity, :_destroy ] ] ])
  end

  def forbid_editing_locked_invoices
    return unless @invoice.locked?

    message = @invoice.corrective? ? "flash.invoices.rectification_locked" : "flash.invoices.rectified_locked"
    redirect_to invoice_path(@invoice), alert: t(message)
  end
end
