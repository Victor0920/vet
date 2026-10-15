class Invoices::PaymentsController < ApplicationController
  before_action :set_invoice
  before_action :require_admin, only: :destroy

  def create
    payment = @invoice.payments.new(params.expect(payment: [ :amount, :payment_method ]))
    payment.enterprise = Current.enterprise
    payment.employee = Current.employee

    if payment.save
      redirect_to invoice_path(@invoice), notice: t("flash.payments.created")
    else
      redirect_to invoice_path(@invoice), alert: payment.errors.full_messages.to_sentence
    end
  end

  def destroy
    @invoice.payments.find(params[:id]).destroy
    redirect_to invoice_path(@invoice), notice: t("flash.payments.deleted")
  end

    private

  def set_invoice
    @invoice = Current.enterprise.invoices.find_by(id: params[:invoice_id])
    redirect_to invoices_url, alert: t("flash.invoices.not_found") if @invoice.nil?
  end
end
