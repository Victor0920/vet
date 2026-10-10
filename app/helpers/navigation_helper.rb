module NavigationHelper
  # What kind of page a return_to path points at, for the back link's label.
  # The first match wins, so more specific patterns go first (/products/categories before /products).
  RETURN_TO_LABELS = {
    %r{\A/appointments}           => "calendar",
    %r{\A/customers/\d+/pets/\d+} => "pet",
    %r{\A/customers/\d+}          => "customer",
    %r{\A/customers}              => "customers",
    %r{\A/invoices/\d+}           => "invoice",
    %r{\A/invoices}               => "invoices",
    %r{\A/products/categories}    => "product_categories",
    %r{\A/products/\d+}           => "product",
    %r{\A/products}               => "products",
    %r{\A/services/categories}    => "service_categories",
    %r{\A/services/\d+}           => "service",
    %r{\A/services}               => "services",
    %r{\A/settings}               => "settings"
  }.freeze

  # The ?return_to= this page was opened with, but only if it's a path on this site.
  # Without this check, ?return_to=https://evil.example would send people off-site (an "open redirect").
  def return_to_path
    path = params[:return_to].to_s
    path if path.start_with?("/") && !path.start_with?("//")
  end

  # This page's URL, but only if it was itself opened with a return_to.
  # For links to child pages, so the trail continues (Settings > Categories > Category)
  # without adding ?return_to= to every link in the app. A nil param is left out of the URL.
  def carried_location
    request.fullpath if return_to_path
  end

  def back_link_path(fallback_path)
    return_to_path || fallback_path
  end

  # The normal label, unless return_to points somewhere other than the page's usual parent.
  # (Pet opened from its customer page keeps showing the owner's name.)
  def back_link_label(fallback_path, fallback_label)
    path = return_to_path&.split("?")&.first
    return fallback_label if path.nil? || path == fallback_path

    key = RETURN_TO_LABELS.find { |pattern, _| pattern.match?(path) }&.last
    key ? t("navigation.back_to.#{key}") : t("navigation.back")
  end
end
