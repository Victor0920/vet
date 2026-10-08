class Invoices::EmailsController < ApplicationController
  before_action :set_invoice

  def new
    @email = @invoice.customer&.email
  end

  def create
    @email = params[:email].to_s.strip
    @message = params[:message].to_s.strip

    if @email.match?(URI::MailTo::EMAIL_REGEXP)
      InvoiceMailer.invoice(@invoice, to: @email, message: @message.presence).deliver_later
      redirect_to invoice_path(@invoice), notice: t("flash.invoices.email_sent", email: @email)
    else
      @error = t("flash.invoices.email_invalid")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_invoice
    @invoice = Current.enterprise.invoices.find_by(id: params[:invoice_id])
    redirect_to invoices_url, alert: t("flash.invoices.not_found") if @invoice.nil?
  end
end
