class EmployeesController < ApplicationController
  include AdminOnly
  before_action :set_employee, only: %i[ show edit update ]

  def index
    @employees = Current.enterprise.employees.order(:first_name, :last_name)
  end

  def new
    @employee = Current.enterprise.employees.new
  end

  def show
    @appointments = @employee.appointments.upcoming.includes(:customer, { pet: :customer }, :room)
  end

  def edit
  end

  def create
    @employee = Current.enterprise.employees.new(employee_params)

    if @employee.save
      redirect_to employee_path(@employee), notice: t("flash.employees.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @employee.update(employee_params)
      key = @employee.saved_change_to_active? ? (@employee.active? ? "reactivated" : "deactivated") : "updated"
      # url_from: only follows return_to if it points to this site (e.g. back to the list after "Deactivate")
      redirect_to url_from(params[:return_to]) || employee_path(@employee), notice: t("flash.employees.#{key}")
    else
      render :edit, status: :unprocessable_entity
    end
  end

    private

  def set_employee
    @employee = Current.enterprise.employees.find_by(id: params[:id])
    redirect_to employees_url, alert: t("flash.employees.not_found") if @employee.nil?
  end

  # Strong parameters: only these fields can be changed from a form
  def employee_params
    fields = [ :first_name, :last_name, :username, :password, :password_confirmation,
               :email_address, :phone, :role, :active, :photo, :locale ]
    # Admins can't change their own role or deactivate themselves, so there's always an admin left
    fields -= [ :role, :active ] if @employee == Current.employee
    params.expect(employee: fields)
  end
end
