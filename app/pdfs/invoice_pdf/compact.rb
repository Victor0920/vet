# Mostly black and white: colour only on a thin line and the total. Smaller text and tighter rows,
# so more lines fit on a page and it uses less ink
class InvoicePdf::Compact < InvoicePdf
  private

  def base_font_size = 9
  def issuer_name_color = TEXT
  def header_rule_width = 0.75
  def table_padding = [ 4, 6 ]
  def total_color = accent

  def style_header_row(row)
    super
    row.background_color = nil
    row.text_color = TEXT
    row.borders = [ :bottom ]
    row.border_color = accent
  end
end
