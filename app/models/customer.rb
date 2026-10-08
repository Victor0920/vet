class Customer < ApplicationRecord
  has_many :pets, dependent: :destroy
  has_many :appointments, dependent: :destroy
  belongs_to :enterprise
  has_one_attached :photo

  def full_name
    [ first_name, first_surname ].compact_blank.join(" ").presence || "Customer ##{id}"
  end


  SEARCHABLE_COLUMNS = %w[ first_name first_surname second_surname first_phone second_phone document_number email ].freeze

  # Every word has to appear in at least one column: "ana garcia" finds Ana García López
  scope :search, ->(query) {
    query.to_s.split.reduce(all) do |customers, word|
      pattern = "%#{sanitize_sql_like(word)}%"
      customers.where(SEARCHABLE_COLUMNS.map { |column| "#{column} LIKE :pattern" }.join(" OR "), pattern: pattern)
    end
  }
end
