# Draws an invoice as a PDF with Prawn. Used by InvoicesController#show (format.pdf).
# InvoicePdf.new(invoice).render # => the PDF as a binary string
class InvoicePdf
  include Prawn::View

  # PRIMARY stays as the fallback colour
  PRIMARY = "0F766E"
  TEXT = "18181B"
  MUTED = "52525B"
  SUBTLE = "A1A1AA"
  BORDER = "E4E4E7"
  SURFACE = "F4F4F5"
  WHITE = "FFFFFF"

  # The right class for the invoice's company: InvoicePdf.for(invoice).render
  def self.for(invoice)
    { "modern" => InvoicePdf::Modern, "compact" => InvoicePdf::Compact }
      .fetch(invoice.enterprise.invoice_layout, InvoicePdf).new(invoice)
  end

  def initialize(invoice)
    @invoice = invoice
    font_size base_font_size

    header
    move_down 20
    side_by_side(:billed_to, :store_details, :staff_details)
    move_down 20
    lines_table
    total
    footer
  end

  # Prawn::View draws on whatever this returns
  def document
    @document ||= Prawn::Document.new(page_size: "A4", margin: 43) # 43pt ≈ 1.5cm
  end

  private

  # ---------- what each layout changes (see InvoicePdf::Modern, ::Compact) ----------

  def accent = Enterprise::INVOICE_COLORS.fetch(enterprise.invoice_color, PRIMARY)
  def base_font_size = 10
  def issuer_name_color = accent
  def header_rule_width = 2
  def table_padding = [ 7, 8 ]
  def total_color = TEXT

  def style_header_row(row)
    row.background_color = SURFACE
    row.font_style = :bold
    row.size = 7
    row.text_color = MUTED
  end

  # ---------- sections ----------

  def header
    side_by_side(:issuer, :heading)
    rule(accent, header_rule_width)
  end

  def footer
    move_down 30
    rule(BORDER, 0.75)
    move_down 6
    # The company's own note replaces the default closing line; without one, the default uses the trading name
    if enterprise.invoice_footer.present?
      text enterprise.invoice_footer, size: 8, color: MUTED
    else
      text t(:footer, name: brand_name), size: 8, color: SUBTLE
    end
    number_pages "<page>/<total>", at: [ 0, -12 ], width: bounds.width, align: :right, size: 8, color: SUBTLE
  end

  def issuer
    logo
    text brand_name, size: 16, style: :bold, color: issuer_name_color
    # The legal name is required on Spanish invoices; shown when it differs from the trading name
    muted enterprise.legal_name if enterprise.legal_name.present? && enterprise.legal_name != brand_name
    muted "#{t(:tax_id)}: #{enterprise.cif}" if enterprise.cif.present?
    muted enterprise.address if enterprise.address.present?
  end


  def logo
    attachment = [ @invoice.store.logo, enterprise.logo ].find(&:attached?)
    return unless attachment

    # Prawn only reads PNG and JPG, but logos may be WebP: ask for a PNG copy
    png = attachment.variant(resize_to_limit: [ 480, 180 ], format: :png).processed.download
    image StringIO.new(png), fit: [ 160, 60 ]
    move_down 8
  rescue ActiveStorage::FileNotFoundError, Prawn::Errors::UnsupportedImageType
     # A missing or unreadable logo shouldn't stop the invoice from rendering
   end

  def heading
    text t(:title).upcase, size: 22, style: :bold, align: :right
    text number, style: :bold, align: :right
    muted date, align: :right
  end

  def billed_to
    label t(:billed_to)
    customer = @invoice.customer
    if customer
      text [ customer.first_name, customer.first_surname, customer.second_surname ].compact_blank.join(" ").presence || customer.full_name,
           style: :bold
      muted [ customer.document_type, customer.document_number ].compact_blank.join(" ") if customer.document_number.present?
      muted customer.address if customer.address.present?
      location = [ customer.post_code, customer.province ].compact_blank.join(", ")
      muted location if location.present?
    else
      muted I18n.t("invoices.no_customer")
    end
  end

  def store_details
    label Invoice.human_attribute_name(:store)
    text @invoice.store.name.to_s, style: :bold
    location = [ @invoice.store.address, @invoice.store.post_code ].compact_blank.join(", ")
    muted location if location.present?
  end

  def staff_details
    label Invoice.human_attribute_name(:employee)
    text @invoice.employee.display_name
    if @invoice.appointment
      move_down 8
      label Invoice.human_attribute_name(:appointment)
      text @invoice.appointment.title.presence || I18n.t("shared.untitled")
      muted I18n.l(@invoice.appointment.starts_at, format: :short_datetime)
    end
  end

  def lines_table
    if @invoice.invoice_products.empty?
      muted I18n.t("invoices.show.no_lines"), align: :center
      return
    end

    rows = [ [ t(:description), column(:quantity), column(:unit_price), column(:subtotal) ] ]
    @invoice.invoice_products.each do |line|
      name = line.catalog_item ? (line.catalog_item.name.presence || I18n.t("shared.unnamed")) : line.description
      rows << [ name.to_s, line.quantity.to_s, money(line.price), money(line.subtotal) ]
    end

    # header: true repeats the first row at the top of every page
    table(rows, header: true, width: bounds.width, column_widths: { 1 => 60, 2 => 85, 3 => 85 }) do |grid|
      grid.cells.borders = [ :bottom ]
      grid.cells.border_color = BORDER
      grid.cells.padding = table_padding
      grid.columns(1..3).align = :right
      style_header_row(grid.row(0))
    end
  end

  def total
    move_down 14
    text "#{column(:total).upcase}    #{money(@invoice.total)}", size: 14, style: :bold, align: :right, color: total_color
  end

  # ---------- small drawing helpers ----------

  # Draws each section in its own column, all starting at the same height,
  # then moves the cursor below the tallest one
  def side_by_side(*sections)
    top = cursor
    width = bounds.width / sections.size
    bottoms = sections.each_with_index.map do |section, index|
      bounding_box([ index * width, top ], width: width - 12) { send(section) }
      cursor
    end
    move_cursor_to bottoms.min
  end

  def label(content)
    text content.upcase, size: 7, style: :bold, color: SUBTLE, character_spacing: 0.5
    move_down 3
  end

  def muted(content, **options)
    text content.to_s, size: 9, color: MUTED, **options
  end

  def rule(color, width)
    stroke_color color
    line_width width
    stroke_horizontal_rule
    stroke_color TEXT
    line_width 1
  end

  # ---------- values ----------

  def enterprise = @invoice.enterprise
  def issuer_name = enterprise.legal_name.presence || enterprise.name.to_s
  def brand_name = enterprise.name.presence || enterprise.legal_name.to_s
  def number = @invoice.display_number
  def date = @invoice.date ? I18n.l(@invoice.date.to_date, format: :display) : "—"

  def money(amount)
    amount ? ActiveSupport::NumberHelper.number_to_currency(amount, unit: "€", format: "%n %u") : "—"
  end

  def t(key, **options) = I18n.t(key, scope: "invoices.pdf", **options)
  def column(key) = I18n.t(key, scope: "invoices.columns")
end
