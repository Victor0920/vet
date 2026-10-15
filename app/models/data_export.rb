require "csv"

# Everything an enterprise has in the app, as a ZIP with one CSV per table.
# The layout never changes, so a clinic can take its data to another program whenever it wants
# (and the importer reads these same column names back).
class DataExport
  # A value that's just a phone number or an amount ("+34 666…", "-5") is safe in a spreadsheet
  HARMLESS = /\A[+-]?[\d\s().+-]*\z/

  def initialize(enterprise)
    @enterprise = enterprise
  end

  def filename
    "#{@enterprise.name.to_s.parameterize.presence || "export"}-#{Date.current.iso8601}.zip"
  end

  # The ZIP as a string, ready for send_data
  def to_zip
    Zip::OutputStream.write_buffer do |zip|
      tables.each do |name, (records, columns)|
        zip.put_next_entry("#{name}.csv")
        zip.write csv(records, columns)
      end
    end.string
  end

    private

  # file name => [records, columns]. Each column is header => how to read it from a record
  def tables
    e = @enterprise
    {
      "enterprise" => [ [ e ], read(:id, :name, :legal_name, :cif, :address, :created_at) ],
      "stores" => [ e.stores, read(:id, :name, :address, :post_code, :invoice_code, :color, :created_at) ],
      "rooms" => [ Room.where(store: e.stores), read(:id, :store_id, :name, :color) ],
      "opening_hours" => [ OpeningHour.where(store: e.stores), read(:id, :store_id, :weekday, :opens_at, :closes_at) ],
      "employees" => [ e.employees, read(:id, :username, :first_name, :last_name, :email_address, :phone, :role, :active, :created_at) ],
      "customers" => [ e.customers, read(:id, :first_name, :first_surname, :second_surname, :document_type, :document_number,
        :sex, :born_on, :address, :post_code, :province, :first_phone, :second_phone, :email, :created_at) ],
      "pets" => [ e.pets.includes(:customer, :pet_species).with_rich_text_notes,
        read(:id, :customer_id).merge(
          "customer_document_number" => ->(pet) { pet.customer.document_number },
          "customer_email" => ->(pet) { pet.customer.email },
          "customer_phone" => ->(pet) { pet.customer.first_phone },
          "species" => ->(pet) { pet.pet_species&.name }
        ).merge(read(:name, :breed, :sex, :born_on, :color, :sterilized, :transponder_number,
            :transponder_location, :usual_employee_id, :created_at)).merge(
            "notes" => ->(pet) { pet.notes&.to_plain_text }
          ) ],
      "pet_weights" => [ PetWeight.where(pet: e.pets), read(:id, :pet_id, :measured_on, :weight) ],
      "product_categories" => [ e.product_categories, read(:id, :name, :color) ],
      "products" => [ e.products.includes(:product_category),
        read(:id, :product_category_id).merge("category" => ->(product) { product.product_category&.name })
          .merge(read(:name, :reference, :description, :barcode, :price, :vat_rate, :stock, :show_warning_when_stock_under_x_items, :archived_at, :created_at)) ],
      "service_categories" => [ e.service_categories, read(:id, :name, :color) ],
      "services" => [ e.services.includes(:service_category),
        read(:id, :service_category_id).merge("category" => ->(service) { service.service_category&.name })
          .merge(read(:name, :description, :price, :vat_rate, :archived_at, :created_at)) ],
      "appointments" => [ e.appointments.with_rich_text_description,
        read(:id, :store_id, :room_id, :employee_id, :customer_id, :pet_id, :title, :starts_at, :ends_at).merge(
          "description" => ->(appointment) { appointment.description&.to_plain_text }
        ) ],
      "invoices" => [ e.invoices, read(:id, :number, :series, :sequence_number, :date, :store_id, :employee_id,
        :customer_id, :appointment_id, :original_invoice_id) ],
      "invoice_lines" => [ e.invoice_products, read(:id, :invoice_id, :product_id, :service_id, :description, :quantity, :price, :vat_rate) ],
      "messages" => [ Message.where(conversation: e.conversations).includes(:conversation),
        read(:id).merge("customer_id" => ->(message) { message.conversation.customer_id })
          .merge(read(:sender, :employee_id, :text, :created_at)) ]
    }
  end

  # read(:name, :price) => { "name" => ->(record) { record.name }, "price" => … }
  def read(*attributes)
    attributes.to_h { |attribute| [ attribute.to_s, ->(record) { record.public_send(attribute) } ] }
  end

  # The BOM at the start tells Excel the file is UTF-8, so accents show right
  def csv(records, columns)
    rows = records.respond_to?(:find_each) ? records.find_each : records
    CSV.generate(String.new("\uFEFF")) do |csv|
      csv << columns.keys
      rows.each { |record| csv << columns.values.map { |reader| cell(reader.call(record)) } }
    end
  end

  # One text format for every program: ISO dates, dot decimals, and no spreadsheet formulas
  def cell(value)
    case value
    when ActiveSupport::TimeWithZone, Time, Date then value.iso8601
    when BigDecimal then value.to_s("F")
    when String then value.match?(/\A[=+\-@\t\r]/) && !value.match?(HARMLESS) ? "'#{value}" : value
    else value
    end
  end
end
