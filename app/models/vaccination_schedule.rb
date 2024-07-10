class VaccinationSchedule < ApplicationRecord
  belongs_to :personal
  belongs_to :vaccine
  belongs_to :room

  validates :vaccination_date, :vaccination_time, presence: true
end
