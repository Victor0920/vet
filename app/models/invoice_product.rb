 class InvoiceProduct < ApplicationRecord
   belongs_to :invoice
   belongs_to :product, optional: true # nil means a service or a custom item (description + price)
   belongs_to :service, optional: true

   before_validation :use_catalog_details

   validates :quantity, numericality: { only_integer: true, greater_than: 0 }
   validates :description, :price, presence: true, unless: :catalog_item
   validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
   validate :product_or_service
   validate :catalog_item_in_same_enterprise

   def subtotal
     quantity.to_i * (price || 0)
   end

   # The product or service this line sells, or nil for a custom item
   def catalog_item
     product || service
   end

   # The form uses one select for both: "product-5", "service-3", or "" for a custom item
   def item
     if product_id then "product-#{product_id}"
     elsif service_id then "service-#{service_id}"
     end
   end

   def item=(value)
     type, id = value.to_s.split("-", 2)
     self.product_id = (id if type == "product")
     self.service_id = (id if type == "service")
   end

   private

   # A product/service line copies its price when it's picked (or changed).
   # Saved on the line, so later price changes don't rewrite old invoices.
   def use_catalog_details
     return if catalog_item.nil?
     self.description = nil
     self.price = catalog_item.price if price.nil? || product_id_changed? || service_id_changed?
   end

   def product_or_service
     errors.add(:base, :product_and_service) if product_id && service_id
   end

   def catalog_item_in_same_enterprise
     if catalog_item && catalog_item.enterprise_id != invoice&.enterprise_id
       errors.add(product ? :product : :service, :invalid)
     end
   end
 end
