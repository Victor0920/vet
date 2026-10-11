# Everything about the invoice PDF: numbering, layout, highlight colour, logo and footer note.
# They're columns of the enterprise, so this edits Current.enterprise, like EnterprisesController
class InvoiceSettingsController < ApplicationController
  include AdminOnly
  before_action :set_enterprise

  def show
  end

  def edit
  end

  def update
    if @enterprise.update(invoice_settings_params)
      redirect_to invoice_settings_path, notice: t("flash.invoice_settings.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # The PDF with these settings, opened in a new tab. From the edit form it receives the form's
  # (unsaved) values, so you see your choice before saving; they're assigned, never saved
  def preview
    invoice = @enterprise.invoices.order(:created_at).last || sample_invoice
    invoice.enterprise.assign_attributes(preview_params)
    send_data InvoicePdf.for(invoice).render, type: :pdf, disposition: :inline, filename: "preview.pdf"
  end

  private

  def set_enterprise
    @enterprise = Current.enterprise
  end

  def invoice_settings_params
    params.expect(enterprise: [ :invoice_number_schema, :rectification_number_schema, :invoice_counter_reset,
      :invoice_layout, :invoice_color, :invoice_footer, :logo, :remove_logo ])
  end

  # fetch(…, {}): opening the preview from the show page sends no form values at all
  def preview_params
    params.fetch(:enterprise, {}).permit(:invoice_layout, :invoice_color, :invoice_footer)
  end

  # For companies without invoices yet: built in memory only, never saved
  def sample_invoice
    @enterprise.invoices.new(
      number: "#{Date.current.year}/0001", date: Date.current, employee: Current.employee,
      store: @enterprise.stores.first || @enterprise.stores.new(name: @enterprise.name)
    ).tap do |invoice|
      invoice.invoice_products.build(description: t(".sample_line"), price: 35, quantity: 1)
    end
  end
end
