class ProductCategory < ApplicationRecord
  include TracksUpdatedBy
  has_many :products, dependent: :restrict_with_error
  belongs_to :enterprise
end
