# A colour picked from a fixed palette. Each name has matching CSS
# (.badge--<name> and .color-swatch--<name>), so only these are allowed.
module Colorable
  extend ActiveSupport::Concern

  COLORS = %w[ red orange amber green teal blue indigo purple pink gray ].freeze

  included do
    # The "No colour" radio sends "", which is stored as nil
    normalizes :color, with: ->(color) { color.presence }
    validates :color, inclusion: { in: COLORS }, allow_nil: true
  end
end
