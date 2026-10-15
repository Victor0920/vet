# Money received for one invoice. What an invoice still owes is worked out from its payments
# (Invoice#amount_due), never stored. CustomerPayment spreads one amount over several invoices.
class Payment < ApplicationRecord
  METHODS = %w[ cash card transfer bizum ].freeze

  belongs_to :enterprise
  belongs_to :invoice
  belongs_to :employee # who took the money

  validates :amount, numericality: { greater_than: 0 }
  validates :payment_method, inclusion: { in: METHODS }
  validates :paid_at, presence: true
  validate :invoice_can_take_it, on: :create

  before_validation { self.paid_at ||= Time.current }

  private

  # Only this clinic's regular invoices, and never more than what's still owed
  def invoice_can_take_it
    return if invoice.nil?

    if invoice.enterprise_id != enterprise_id || invoice.corrective?
      errors.add(:invoice, :invalid)
    elsif amount.present? && amount > invoice.amount_due
      errors.add(:amount, :more_than_owed, due: invoice.amount_due)
    end
  end
end
