class InvoiceMailer < ApplicationMailer
  # InvoiceMailer.invoice(invoice, to: "ana@example.com", message: "…").deliver_later
  def invoice(invoice, to:, message: nil)
    @invoice = invoice
    @message = message
    @number = invoice.display_number

    attachments["invoice-#{@number.parameterize}.pdf"] = InvoicePdf.new(invoice).render
    mail to: to, subject: t(".subject", number: @number,
                                         name: invoice.enterprise.legal_name.presence || invoice.enterprise.name)
  end
end
