class Enterprise < ApplicationRecord
  has_many :employees, dependent: :destroy
  # dependent: :destroy because a product cannot live without it's enterprise
  has_many :products, dependent: :destroy
  has_many :product_categories, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :stores, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :invoice_products, through: :invoices
  has_many :services, dependent: :destroy
  has_many :service_categories, dependent: :destroy
  enum :invoice_counter_reset, { yearly: "yearly", monthly: "monthly" }, prefix: true, validate: true

  normalizes :invoice_number_schema, :rectification_number_schema, with: ->(schema) { schema.strip.presence }
  validates :invoice_number_schema, presence: true
  validate :invoice_number_schemas_are_valid

  private

  # Each schema needs [n], plus enough of the date that numbers never repeat after the counter resets
  def invoice_number_schemas_are_valid
    { invoice_number_schema: invoice_number_schema, rectification_number_schema: rectification_number_schema }.each do |attribute, schema|
      next if schema.blank?

      tokens = schema.scan(/\[(\w+)\]/).flatten.map { |token| token.sub(/\An\d\z/, "n") }
      unknown = tokens - InvoiceNumber::TOKENS
      errors.add(attribute, :unknown_tokens, tokens: unknown.map { |token| "[#{token}]" }.join(", ")) if unknown.any?
      errors.add(attribute, :missing_counter) unless tokens.include?("n")
      errors.add(attribute, :missing_year) unless tokens.include?("y")
      errors.add(attribute, :missing_month) if invoice_counter_reset_monthly? && !tokens.include?("m")
    end

    if rectification_number_schema.present? && rectification_number_schema == invoice_number_schema
      errors.add(:rectification_number_schema, :same_as_invoices)
    end
  end
end
