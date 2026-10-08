class Invoice < ApplicationRecord
  belongs_to :customer, optional: true
  belongs_to :enterprise
  belongs_to :store
  belongs_to :employee
  has_many :invoice_products, dependent: :destroy
  accepts_nested_attributes_for :invoice_products, allow_destroy: true, reject_if: :blank_line?
  belongs_to :appointment, optional: true
  normalizes :invoice_id, with: ->(number) { number.strip.presence }

  validates :invoice_id, uniqueness: { scope: :enterprise_id }, allow_nil: true

  scope :search, ->(query) {
    query.present? ? where("invoices.invoice_id LIKE ?", "%#{sanitize_sql_like(query)}%") : all
  }

  # Either end may be nil: only "from" means "from that day onwards"
  scope :dated_between, ->(from, to) {
    scope = all
    scope = scope.where(date: from.beginning_of_day..) if from
    scope = scope.where(date: ..to.end_of_day) if to
    scope
  }

  def total
    invoice_products.sum(&:subtotal)
  end

 private

  # An untouched empty row is ignored instead of failing validation
  def blank_line?(attributes)
    attributes.values_at("product_id", "description", "price").all?(&:blank?)
  end
end
