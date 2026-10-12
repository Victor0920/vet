class PagesController < ApplicationController
  def home
    # Loaded once (to_a), then split in Ruby: one query for both tabs and the "to bill" list
    @clinic_appointments = Current.enterprise.appointments.on_day(Date.current)
      .includes(:room, :store, :invoice, :employee, :customer, pet: :customer)
      .to_a
    @my_appointments = @clinic_appointments.select { |appointment| appointment.employee_id == Current.employee.id }
    @next_appointment = @my_appointments.find { |appointment| appointment.starts_at > Time.current }
    # Finished today with no invoice yet
    @unbilled_appointments = @clinic_appointments.select { |appointment| appointment.ends_at <= Time.current && appointment.invoice.nil? }
    @show_store = Current.enterprise.stores.count > 1

    low_stock = Current.enterprise.products.active.low_stock
    @low_stock_count = low_stock.count
    @low_stock_products = low_stock.order(:stock).limit(5)

    @recent_conversations = Conversation.includes(:user, :messages).order(updated_at: :desc).limit(5)
  end
end
