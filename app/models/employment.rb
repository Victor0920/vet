class Employment < ApplicationRecord
  belongs_to :employee
  belongs_to :enterprise

  validates :employee_id, uniqueness: { scope: :enterprise_id }
end
