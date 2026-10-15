# "The customer pays 40 €": spreads the amount over their unpaid invoices, oldest first, as one
# Payment per invoice it reaches. 40 € over two invoices of 50 € → 40 € on the first, 0 on the second.
class CustomerPayment
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :amount, :decimal
  attribute :payment_method, :string, default: "cash"
  attr_accessor :customer, :employee

  validates :amount, numericality: { greater_than: 0 }
  validates :payment_method, inclusion: { in: Payment::METHODS }
  validate :not_more_than_the_debt

  # All or nothing: if one payment fails, none is saved
  def save
    return false unless valid?

    customer.with_lock do
      left = amount
      unpaid_invoices.each do |invoice|
        break if left.zero?

        part = [ left, invoice.amount_due ].min
        invoice.payments.create!(enterprise: customer.enterprise, employee: employee,
                                 amount: part, payment_method: payment_method)
        left -= part
      end
    end
    true
  end

    private

  def unpaid_invoices
    customer.invoices.regular.includes(:invoice_products, :payments, corrective_invoices: :invoice_products)
      .order(:date, :id).reject(&:paid?)
  end

  def not_more_than_the_debt
    debt = customer.debt
    errors.add(:amount, :more_than_owed, due: debt) if amount.present? && amount > debt
  end
end
