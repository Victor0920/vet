class AddAppointmentToInvoices < ActiveRecord::Migration[8.1]
  def change
    add_reference :invoices, :appointment, foreign_key: true
  end
end
