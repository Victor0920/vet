class InvoiceMailerPreview < ActionMailer::Preview
  def invoice
    InvoiceMailer.invoice(Invoice.last, to: "customer@example.com",
      message: "Here's the invoice for today's visit.\nSee you next month!")
  end
end
