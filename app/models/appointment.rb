class Appointment < ApplicationRecord
  belongs_to :customer, optional: true
  belongs_to :pet, optional: true
  belongs_to :employee, default: -> { Current.employee }
  belongs_to :store
  belongs_to :room
  belongs_to :enterprise, default: -> { Current.enterprise }
  has_one :invoice, dependent: :restrict_with_error

  before_validation :fill_in_from_associations

  validates :title, :starts_at, :ends_at, presence: true
  validate :ends_after_starts
  validate :room_is_free
  validate :room_in_enterprise
  validate :pet_belongs_to_customer
  validate :enterprise_matches_customer

  # Appointments that overlap the period from..to, even partly
  scope :overlapping, ->(from, to) { where("starts_at < ? AND ends_at > ?", to, from) }

    private

  def fill_in_from_associations
    self.store = room&.store          # the store always comes from the room
    self.customer ||= pet&.customer   # picking a pet also sets its owner
  end

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?
    errors.add(:ends_at, "must be after the start time") if ends_at <= starts_at
  end

  def room_is_free
    return if room.nil? || starts_at.blank? || ends_at.blank?
    clash = room.appointments.where.not(id: id).overlapping(starts_at, ends_at)
    errors.add(:room, "is already booked at that time") if clash.exists?
  end

  def room_in_enterprise
    return if room.nil? || enterprise.nil?
    errors.add(:room, "is not valid") if room.store.enterprise_id != enterprise_id
  end

  def pet_belongs_to_customer
    return if pet.nil? || customer.nil?
    errors.add(:pet, "doesn't belong to this customer") if pet.customer_id != customer_id
  end

  def enterprise_matches_customer
    return if customer.nil? || enterprise.nil?
    errors.add(:enterprise, "must match the customer's enterprise") if customer.enterprise_id != enterprise_id
  end
end
