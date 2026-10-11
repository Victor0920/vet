class Invoice < ApplicationRecord
  belongs_to :customer, optional: true
  belongs_to :enterprise
  belongs_to :store
  belongs_to :employee
  belongs_to :original_invoice, class_name: "Invoice", optional: true
  has_many :corrective_invoices, class_name: "Invoice", foreign_key: :original_invoice_id,
           inverse_of: :original_invoice, dependent: :restrict_with_error
  has_many :invoice_products, dependent: :destroy
  accepts_nested_attributes_for :invoice_products, allow_destroy: true, reject_if: :blank_line?
  belongs_to :appointment, optional: true
  normalizes :number, with: ->(number) { number.strip.presence }

  validates :number, uniqueness: { scope: :enterprise_id }, allow_nil: true
  validate :enough_stock
  validate :refunds_match_original, if: :corrective?
  validates :date, presence: true
  validate :store_has_invoice_code, on: :create
  validate :date_and_store_unchanged, on: :update
  validate :customer_and_appointment_in_enterprise
  validate :customer_matches_appointment

  before_validation :assign_number, on: :create
  before_validation { self.customer ||= appointment&.customer }
  before_save :apply_stock_changes

  scope :search, ->(query) {
    query.present? ? where("invoices.number LIKE ?", "%#{sanitize_sql_like(query)}%") : all
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

  def corrective?
    original_invoice_id.present?
  end

  def locked?
    corrective? || corrective_invoices.exists?
  end

  def number_preview
    numbering&.format
  end

  def display_number
    (number.presence || id).to_s
   end

  # Creates the invoice, and if another invoice in the same series took this number between
  # working it out and saving (the unique index rejects the duplicate), tries the next one
  def save_with_number(attempts: 3)
    save
  rescue ActiveRecord::RecordNotUnique
    attempts -= 1
    retry if new_record? && attempts.positive?
    raise
  end


  private

  # An untouched empty row is ignored instead of failing validation
  def blank_line?(attributes)
    attributes.values_at("item", "product_id", "service_id", "description", "price").all?(&:blank?)
  end

  def refunds_match_original
    if original_invoice.nil? || original_invoice.enterprise_id != enterprise_id || original_invoice.corrective?
      return errors.add(:original_invoice, :invalid)
    end

    refunding = units_by_line(invoice_products.reject(&:marked_for_destruction?))
    return errors.add(:base, :refund_without_lines) if refunding.empty?

    sold = units_by_line(original_invoice.invoice_products)
    already_refunded = units_by_line(
      InvoiceProduct.where(invoice: original_invoice.corrective_invoices.where.not(id: id))
    )

    refunding.each do |line, units|
      # Refund quantities are negative, so -(…) is the number of units given back
      if -(units + already_refunded[line]) > sold[line]
        return errors.add(:base, :refund_exceeds_original)
      end
    end
  end

  # { [product_id, service_id, description, price] => total quantity }
  def units_by_line(lines)
    lines.each_with_object(Hash.new(0)) do |line, totals|
      totals[[ line.product_id, line.service_id, line.description, line.price ]] += line.quantity.to_i
    end
  end

  def stock_changes
    changes = Hash.new(0)
    invoice_products.each do |line|
      # Give back what this line took last time it was saved
      if line.persisted? && line.product_id_in_database
        changes[line.product_id_in_database] += line.quantity_in_database.to_i
      end
      if line.product_id && !line.marked_for_destruction?
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

  def numbering
    return if enterprise.nil? || store.nil? || date.nil?
    InvoiceNumber.new(enterprise: enterprise, store: store, date: date, rectification: corrective?)
  end

  # Set once, on create. series + sequence_number hold the counter; number is the printed number.
  def assign_number
    generator = numbering
    return if generator.nil?

    self.series = generator.series
    self.sequence_number = generator.next_sequence
    self.number = generator.format(sequence_number)
  end

  def store_has_invoice_code
    if numbering&.uses_store? && store.invoice_code.blank?
    end
  end

  # The number was built from them, so they can't change afterwards
  def date_and_store_unchanged
    errors.add(:date, :locked) if date_changed?
    errors.add(:store, :locked) if store_id_changed?
  end

  def store_has_invoice_code
    if numbering&.uses_store? && store.invoice_code.blank?
      errors.add(:store, :missing_invoice_code, store: store.name)
    end
  end

  def customer_and_appointment_in_enterprise
    errors.add(:customer, :invalid) if customer && customer.enterprise_id != enterprise_id
    errors.add(:appointment, :invalid) if appointment && appointment.enterprise_id != enterprise_id
  end

  def customer_matches_appointment
    if customer && appointment&.customer && appointment.customer_id != customer_id
      errors.add(:customer, :doesnt_match_appointment, customer: appointment.customer.full_name)
    end
  end
end
