# frozen_string_literal: true

class TopNavComponent < ViewComponent::Base
  def initialize
    @enterprise = Current.enterprise
    @employee = Current.employee
  end
end
