 class InvoiceProduct < ApplicationRecord
   belongs_to :invoice
   belongs_to :product, optional: true # nil means a custom item (description + price)

   before_validation :use_product_details

   validates :quantity, numericality: { only_integer: true, greater_than: 0 }
   validates :description, :price, presence: true, unless: :product
   validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
   validate :product_in_same_enterprise

   def subtotal
     quantity.to_i * (price || 0)
   end

    private

   # A product line copies the product's price when the product is picked (or changed).
   # Saved on the line, so later price changes don't rewrite old invoices.
   def use_product_details
     return if product.nil?
     self.description = nil
     self.price = product.price if price.nil? || product_id_changed?
   end

   def product_in_same_enterprise
     if product && product.enterprise_id != invoice&.enterprise_id
       errors.add(:product, :invalid)
     end
   end
 end
