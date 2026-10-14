# customers.csv: the columns DataExport writes (id and created_at are ignored), or the template's
class Import::Customers < Import::Base
  REQUIRED_COLUMNS = %w[ first_name ].freeze
  TEXT_COLUMNS = %w[ first_name first_surname second_surname document_type document_number
                     address post_code province first_phone second_phone email ].freeze

  private

  def existing_records = @enterprise.customers

  def build(values, problems)
    Customer.new(values.slice(*TEXT_COLUMNS)).tap do |customer|
      customer.enterprise = @enterprise
      customer.sex = sex(values, problems)
      customer.born_on = date(values, "born_on", problems)
    end
  end

  # The same person: same ID document, same email, or same name and phone
  def keys(customer)
    person = [ customer.first_name, customer.first_surname, normalized_phone(customer.first_phone) ].join("/").downcase
    [
      tagged(:document, normalized_document(customer.document_number)),
      tagged(:email, normalized_email(customer.email)),
      tagged(:person, (person if customer.first_phone.present?))
    ].compact
  end
end
