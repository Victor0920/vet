class EmployeesController < ApplicationController
  before_action :set_employee, only: %i[ show edit update ]

  def index
    @customers = Current.enterprise.employees.all
  end

  def new
    @employee = Employee.new
  end

  def show
    @appointments = @employee.appointments.where("starts_at >= ?", Time.current)
      .order(:starts_at)
      .includes(:customer, { pet: :customer }, :room)
  end

  def edit
  end

  def create
    @employee = Current.enterprise.employee.new(employee_params)

    if @employee.save
      redirect_to employee_path(@employee), notice: "Employee created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @employee.update(employee_params)
      redirect_to edit_employee_path(@employee), notice: "Employee updated"
    else
      redirect_to edit_customer_path(@customer), alert: @customer.errors.full_messages.to_sentence
    end
  end

  private

  def set_employee
    @employee = Current.employee
    redirect_to employee_url, alert: "Employee not found" if @employee.nil?
  end

  # Strong parameters: only these fields can be changed from a form
  def employee_params
    params.expect(employee: [ :first_name, :last_name, :email_address, :phone, :role, :active, :photo ])
  end
end
