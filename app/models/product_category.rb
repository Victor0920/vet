class ProductCategory < ApplicationRecord
  include TracksUpdatedBy
  include Colorable

  has_many :products, dependent: :restrict_with_error
  belongs_to :enterprise
end
