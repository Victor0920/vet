# Draws an invoice as a PDF with Prawn. Used by InvoicesController#show (format.pdf).
# InvoicePdf.new(invoice).render # => the PDF as a binary string
class InvoicePdf
  include Prawn::View # lets this class call text, table, move_down… directly

  PRIMARY = "0F766E"
  TEXT = "18181B"
  MUTED = "52525B"
  SUBTLE = "A1A1AA"
  BORDER = "E4E4E7"
  SURFACE = "F4F4F5"

  def initialize(invoice)
    @invoice = invoice
    font_size 10

    side_by_side(:issuer, :heading)
    rule(PRIMARY, 2)
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

  # ---------- sections ----------

  def issuer
    text issuer_name, size: 16, style: :bold, color: PRIMARY
    muted "#{t(:tax_id)}: #{enterprise.cif}" if enterprise.cif.present?
    muted enterprise.address if enterprise.address.present?
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
      grid.cells.padding = [ 7, 8 ]
      grid.columns(1..3).align = :right
      grid.row(0).background_color = SURFACE
      grid.row(0).font_style = :bold
      grid.row(0).size = 7
      grid.row(0).text_color = MUTED
    end
  end

  def total
    move_down 14
    text "#{column(:total).upcase}    #{money(@invoice.total)}", size: 14, style: :bold, align: :right
  end

  def footer
    move_down 30
    rule(BORDER, 0.75)
    move_down 6
    text t(:footer, name: issuer_name), size: 8, color: SUBTLE
    # Page numbers in the bottom margin of every page
    number_pages "<page>/<total>", at: [ 0, -12 ], width: bounds.width, align: :right, size: 8, color: SUBTLE
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
  def number = @invoice.display_number
  def date = @invoice.date ? I18n.l(@invoice.date.to_date, format: :display) : "—"

  def money(amount)
    amount ? ActiveSupport::NumberHelper.number_to_currency(amount, unit: "€", format: "%n %u") : "—"
  end

  def t(key, **options) = I18n.t(key, scope: "invoices.pdf", **options)
  def column(key) = I18n.t(key, scope: "invoices.columns")
end
