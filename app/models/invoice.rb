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
  validate :enough_stock
  before_save :apply_stock_changes

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

  def stock_changes
    changes = Hash.new(0)
    invoice_products.each do |line|
      # Give back what this line took last time it was saved
      if updates_stock_in_database && line.persisted? && line.product_id_in_database
        changes[line.product_id_in_database] += line.quantity_in_database.to_i
      end
      # Take what it needs now
      if updates_stock && line.product_id && !line.marked_for_destruction?
        changes[line.product_id] -= line.quantity.to_i
      end
    end
    changes.reject { |_product_id, units| units.zero? }
  end

  # Friendly form error before saving: "Not enough stock for X: only 2 more in stock"
  def enough_stock
    stock_changes.each do |product_id, units|
      next if units >= 0
      product = enterprise.products.find_by(id: product_id)
      next if product.nil? # InvoiceProduct already reports a product from another enterprise
      if product.stock + units < 0
        errors.add(:base, :not_enough_stock, product: product.name, stock: product.stock)
      end
    end
  end

  # Runs inside save's transaction: if any product can't be updated, nothing is saved
  def apply_stock_changes
    stock_changes.each do |product_id, units|
      product = Product.find(product_id)
      next if product.adjust_stock(units)

      errors.add(:base, :not_enough_stock, product: product.name, stock: product.stock_in_database)
      throw :abort
    end
  end
end
