class Room < ApplicationRecord
  has_many :vaccination_schedules, dependent: :destroy

  validates :name, :doctor, presence: true
end
