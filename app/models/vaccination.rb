class Vaccination < ApplicationRecord
  belongs_to :personal
  belongs_to :vaccine

  validates :vaccination_date, presence: true

  def expiry_date
    vaccination_date + vaccine.expiry_date.days
  end

  scope :expiring_this_month, -> {
    end_of_month = Time.current.end_of_month
    start_of_month = Time.current.beginning_of_month
    where("(vaccination_date + (vaccines.expiry_date * 24 * 60 * 60)) BETWEEN ? AND ?", start_of_month, end_of_month)
      .joins(:vaccine)
  }
end
