# Products, services and invoice lines keep the price without VAT (price, 4 decimals)
# and the VAT percentage (vat_rate: 21 means 21 %)
module Taxable
  extend ActiveSupport::Concern

  included do
    validates :vat_rate, numericality: { greater_than_or_equal_to: 0, less_than: 100 }
  end

  # What the customer pays for one unit: 8.2645 at 21 % → 10.00
  def price_with_vat
    (price * (1 + vat_rate / 100)).round(2) if price && vat_rate
  end
end
