# The developer's private area. It doesn't inherit ApplicationController (the employee login): the
# developer isn't an employee of each company. HTTP Basic auth instead, with the username and password
# from bin/rails credentials:edit → developer: { username: …, password: … }. Not set → nobody gets in
module Developer
  class BaseController < ActionController::Base
    layout "developer"
    before_action :authenticate_developer

    private

    def authenticate_developer
      username = Rails.application.credentials.dig(:developer, :username).to_s
      password = Rails.application.credentials.dig(:developer, :password).to_s
      return head :forbidden if username.blank? || password.blank?

      # secure_compare takes the same time whatever the input, so timing can't reveal the password.
      # & (not &&) so both comparisons always run
      authenticate_or_request_with_http_basic("Developer") do |given_username, given_password|
        ActiveSupport::SecurityUtils.secure_compare(given_username, username) &
          ActiveSupport::SecurityUtils.secure_compare(given_password, password)
      end
    end
  end
end
