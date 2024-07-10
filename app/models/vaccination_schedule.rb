class VaccinationSchedule < ApplicationRecord
  belongs_to :personal
  belongs_to :vaccine
  belongs_to :room

  validates :vaccination_date, :vaccination_time, presence: true
  validate :no_weekly_conflicts
  validate :no_recent_vaccine_conflicts

  private

  def no_weekly_conflicts
    start_of_week = vaccination_date.beginning_of_week
    end_of_week = vaccination_date.end_of_week

    if VaccinationSchedule.exists?(personal_id: personal_id, vaccination_date: start_of_week..end_of_week)
      errors.add(:base, 'Сотрудник уже записан на вакцинацию на этой неделе.')
    end
  end

  def no_recent_vaccine_conflicts
    start_date = vaccination_date - 30.days

    if VaccinationSchedule.exists?(personal_id: personal_id, vaccine_id: vaccine_id, vaccination_date: start_date..vaccination_date)
      errors.add(:base, 'У сотрудника уже есть эта вакцина в последние 30 дней.')
    end
  end
end
