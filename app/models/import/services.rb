# services.csv: "category" is the category's name (created if it doesn't exist yet)
class Import::Services < Import::Base
  REQUIRED_COLUMNS = %w[ name ].freeze
  TEXT_COLUMNS = %w[ name description ].freeze

  private

  def existing_records = @enterprise.services

  def build(values, problems)
    Service.new(values.slice(*TEXT_COLUMNS)).tap do |service|
      service.enterprise = @enterprise
      service.service_category = category(ServiceCategory, values["category"])
      service.price = decimal(values, "price", problems)
    end
  end

  # The same service: same name (archived ones count too)
  def keys(service)
    [ tagged(:name, service.name.to_s.downcase) ].compact
  end
end
