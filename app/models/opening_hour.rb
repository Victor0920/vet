# One period a store is open on one day of the week (a day can have several: 09:00–14:00 and 17:00–20:00).
# Used for automatic bookings; the calendar's visible hours are separate (Enterprise#calendar_opens_at)
class OpeningHour < ApplicationRecord
  WEEKDAYS = [ 1, 2, 3, 4, 5, 6, 0 ].freeze # Date#wday numbers, listed Monday first

  belongs_to :store

  validates :weekday, inclusion: { in: WEEKDAYS }
  validates :opens_at, :closes_at, format: { with: Enterprise::CALENDAR_TIME }
  validate :closes_after_opening
  validate :no_overlap

  private

  def closes_after_opening
    return if errors.any?

    errors.add(:closes_at, :after_opening) if closes_at <= opens_at
  end

  # Two periods of the same day may touch (14:00–17:00 then 17:00–20:00) but not overlap
  def no_overlap
    return if errors.any?

    clash = OpeningHour.where(store_id: store_id, weekday: weekday).where.not(id: id)
                       .where("opens_at < ? AND closes_at > ?", closes_at, opens_at)
    errors.add(:base, :overlaps, day: I18n.t("date.day_names")[weekday]) if clash.exists?
  end
end
