class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  around_action :switch_locale

  private

  # Runs every request in the signed-in employee's language (Spanish on the login pages)
  def switch_locale(&action)
    locale = resume_session&.employee&.locale.presence || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  # "2026-10-09" → Date; blank or invalid → nil (so a filter is simply skipped)
  def date_param(key)
    Date.parse(params[key].to_s)
  rescue Date::Error
    nil
  end
end
