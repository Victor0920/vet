require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    employee = Employee.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", employee.email_address)
  end
end
