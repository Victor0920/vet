class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  around_action :switch_locale
  helper_method :admin?

  private

  # Views use this to hide admin-only buttons; require_admin is what actually blocks the request
  def admin?
    Current.employee&.admin?
  end

  # include AdminOnly to protect a whole controller, or
  # before_action :require_admin, only: ... for single actions
  def require_admin
    redirect_to root_path, alert: t("flash.not_authorized") unless admin?
  end

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
