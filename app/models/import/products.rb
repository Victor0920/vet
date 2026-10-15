# products.csv: "category" is the category's name (created if it doesn't exist yet)
class Import::Products < Import::Base
  REQUIRED_COLUMNS = %w[ name ].freeze
  TEXT_COLUMNS = %w[ name reference description barcode ].freeze

  private

  def existing_records = @enterprise.products

  def build(values, problems)
    Product.new(values.slice(*TEXT_COLUMNS)).tap do |product|
      product.enterprise = @enterprise
      product.product_category = category(ProductCategory, values["category"])
      product.price = decimal(values, "price", problems)
      # Missing or empty keeps the default (21 %)
      vat_rate = decimal(values, "vat_rate", problems)
      product.vat_rate = vat_rate if vat_rate
      product.stock = integer(values, "stock", problems) || 0
      warning = integer(values, "show_warning_when_stock_under_x_items", problems)
      product.show_warning_when_stock_under_x_items = warning if warning
    end
  end

  # The same product: same reference (any case), same barcode, or same name (archived ones count too)
  def keys(product)
    [ tagged(:reference, product.reference.to_s.strip.downcase), tagged(:barcode, product.barcode.to_s.strip),
      tagged(:name, product.name.to_s.downcase) ].compact
  end
end
