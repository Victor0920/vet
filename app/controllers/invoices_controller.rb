class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[ show edit update ]
  before_action :set_form_options, only: %i[ new create edit update ]

  def index
    @query = params[:q].to_s.strip
    @from = date_param(:from)
    @to = date_param(:to)
    @invoices = Current.enterprise.invoices
      .search(@query)
      .dated_between(@from, @to)
      .includes(:customer, :employee, invoice_products: :product) # one query per table, not per row
      .order(date: :desc)
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        send_data InvoicePdf.new(@invoice).render,
                  filename: "invoice-#{(@invoice.invoice_id.presence || @invoice.id).to_s.parameterize}.pdf",
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
      store: appointment&.store || @stores.first,
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
    @products = Current.enterprise.products.order(:name)
  end

  # Turns "2026-10-08" into a Date; blank or garbage becomes nil (no filter)
  def date_param(key)
    Date.parse(params[key].to_s)
  rescue Date::Error
    nil
  end

  def invoice_params
    params.expect(invoice: [ :invoice_id, :date, :store_id, :employee_id, :customer_id, :appointment_id, :updates_stock,
      invoice_products_attributes: [ [ :id, :product_id, :description, :price, :quantity, :_destroy ] ] ])
  end
end
