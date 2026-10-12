class Enterprise < ApplicationRecord
  has_many :employees, dependent: :destroy
  # dependent: :destroy because a product cannot live without it's enterprise
  has_many :products, dependent: :destroy
  has_many :product_categories, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :conversations, through: :customers
  has_many :pets, through: :customers
  has_many :appointments, dependent: :destroy
  has_many :stores, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :invoice_products, through: :invoices
  has_many :services, dependent: :destroy
  has_many :service_categories, dependent: :destroy
  has_one_attached :logo do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 320, 320 ], preprocessed: true
  end
  enum :invoice_counter_reset, { yearly: "yearly", monthly: "monthly" }, prefix: true, validate: true

  # Highlight colours for the invoice PDF: the app's palette names (Colorable::COLORS), each mapped
  # to a dark shade, so white text on it (the Modern header band) stays readable when printed
  INVOICE_COLORS = {
    "red" => "B91C1C", "orange" => "C2410C", "amber" => "B45309", "green" => "15803D", "teal" => "0F766E",
    "blue" => "1D4ED8", "indigo" => "4338CA", "purple" => "7E22CE", "pink" => "BE185D", "gray" => "3F3F46"
  }.freeze

  enum :invoice_layout, { classic: "classic", modern: "modern", compact: "compact" }, prefix: true, validate: true
  validates :invoice_color, inclusion: { in: INVOICE_COLORS.keys }

  normalizes :invoice_footer, with: ->(text) { text.strip.presence }
  validates :invoice_footer, length: { maximum: 500 }

  # Logo: same rules as the store logo (Prawn only reads PNG/JPG), plus the "Remove" toggle
  attribute :remove_logo, :boolean, default: false
  before_save { self.logo = nil if remove_logo && logo.persisted? }
  validate :logo_is_png_or_jpg

  normalizes :invoice_number_schema, :rectification_number_schema, with: ->(schema) { schema.strip.presence }
  validates :invoice_number_schema, presence: true
  validate :invoice_number_schemas_are_valid

  normalizes :login_code, with: ->(code) { code.strip.downcase }
  validates :login_code, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]{3,30}\z/ }

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

  def logo_is_png_or_jpg
    if logo.attached? && !logo.content_type.in?(%w[image/png image/jpeg])
      errors.add(:logo, :png_or_jpg_only)
    end
  end
end
