class AppointmentsController < ApplicationController
  VIEWS = %w[ day week month rooms ].freeze

  before_action :set_appointment, only: %i[ edit update destroy ]
  before_action :set_store
  before_action :set_form_options, only: %i[ new create edit update ]

  helper_method :calendar_return_params

  def index
    @view = params[:view].presence_in(VIEWS) || "week"
    @date = requested_date
    @days = calendar_days
    @rooms = @store.rooms.order(:name)
    @appointments = @store.appointments
                          .overlapping(@days.first.beginning_of_day, @days.last.end_of_day)
                          .includes(:room, :customer, pet: :customer)
                          .order(:starts_at)
  end

  def new
    starts_at = requested_start
    @appointment = Appointment.new(starts_at: starts_at, ends_at: starts_at + 30.minutes, room_id: params[:room_id])
  end

  def create
    @appointment = Appointment.new(appointment_params)

    if @appointment.save
      redirect_to appointments_path(calendar_return_params), notice: "Appointment created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @appointment.update(appointment_params)
      redirect_to appointments_path(calendar_return_params), notice: "Appointment updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @appointment.destroy
    redirect_to appointments_path(calendar_return_params), notice: "Appointment deleted", status: :see_other
  end

    private

  def set_appointment
    @appointment = Current.enterprise.appointments.find_by(id: params[:id])
    redirect_to appointments_path, alert: "Appointment not found" if @appointment.nil?
  end

  # Editing uses the appointment's store; otherwise the one picked in the selector
  def set_store
    @stores = Current.enterprise.stores.order(:name)
    @store = @appointment&.store || @stores.find_by(id: params[:store_id]) || @stores.first
    redirect_to root_path, alert: "Create a store first" if @store.nil?
  end

  def set_form_options
    @rooms = @store.rooms.order(:name)
    @customers = Current.enterprise.customers.includes(:pets).order(:first_name)
    @employees = Current.enterprise.employees
  end

  # Where to send the user after saving or deleting: same view, the appointment's day
  def calendar_return_params
    { view: params[:view].presence_in(VIEWS) || "week",
      date: (@appointment&.starts_at || Time.current).to_date,
      store_id: @store.id }
  end

  def calendar_days
    case @view
    when "week"  then @date.all_week.to_a
    when "month" then (@date.beginning_of_month.beginning_of_week..@date.end_of_month.end_of_week).to_a
    else [ @date ]
    end
  end

  def requested_date
    Date.parse(params[:date].to_s)
  rescue Date::Error
    Date.current
  end

  def requested_start
    Time.zone.parse(params[:starts_at].to_s) || Time.current.beginning_of_hour + 1.hour
  rescue ArgumentError
    Time.current.beginning_of_hour + 1.hour
  end

  def appointment_params
    params.expect(appointment: [ :title, :description, :starts_at, :ends_at,
                                 :room_id, :employee_id, :customer_id, :pet_id ])
  end
end
