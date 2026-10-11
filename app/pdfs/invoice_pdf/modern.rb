# A band in the highlight colour across the top with white text, coloured table header,
# and the total in a coloured box
class InvoicePdf::Modern < InvoicePdf
  BAND_HEIGHT = 90

  private

  def header
    logo # above the band, if there is one
    top = cursor
    fill_color accent
    fill_rounded_rectangle [ 0, top ], bounds.width, BAND_HEIGHT, 6

    # text_box has no color: option: it draws in the current fill colour, so switch it to white
    fill_color WHITE
    half = bounds.width / 2
    details = [ (enterprise.legal_name if enterprise.legal_name.present? && enterprise.legal_name != brand_name),
                ("#{t(:tax_id)}: #{enterprise.cif}" if enterprise.cif.present?), enterprise.address ].compact_blank.join("\n")
    text_box brand_name, at: [ 16, top - 16 ], width: half - 24, height: 20,
             size: 16, style: :bold, overflow: :shrink_to_fit
    text_box details, at: [ 16, top - 42 ], width: half - 24, height: 36, size: 9, overflow: :shrink_to_fit
    text_box t(:title).upcase, at: [ half, top - 14 ], width: half - 16, height: 26,
             size: 22, style: :bold, align: :right
    text_box "#{number}\n#{date}", at: [ half, top - 46 ], width: half - 16, height: 30, align: :right
    fill_color TEXT # back to normal for the rest of the page

    move_cursor_to top - BAND_HEIGHT
  end

  def style_header_row(row)
    super
    row.background_color = accent
    row.text_color = WHITE
  end

  def total
    move_down 14
    start_new_page if cursor < 50 # keep the box from being cut at the bottom of a page
    width = 220
    top = cursor
    fill_color accent
    fill_rounded_rectangle [ bounds.width - width, top ], width, 36, 6

    fill_color WHITE
    text_box column(:total).upcase, at: [ bounds.width - width + 12, top - 13 ], width: 80, height: 12,
             size: 8, style: :bold
    text_box money(@invoice.total), at: [ bounds.width - width + 12, top - 10 ], width: width - 24, height: 18,
             size: 14, style: :bold, align: :right
    fill_color TEXT

    move_cursor_to top - 36
  end
end
