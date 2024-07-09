class Personal < ApplicationRecord
	validates :fio, presence: true
  	validates :date_of_birthday, presence: true
  	validates :gender, presence: true
  	validates :email, presence: true, uniqueness: true
  	validates :phone_number, presence: true
  	validates :departament, presence: true

  	has_many :vaccinations
  	has_many :vaccines, through: :vaccinations

  	def expiring_vaccinations(start_date, end_date)
    vaccinations.joins(:vaccine).where("vaccination_date + vaccines.expiry_date * 1 BETWEEN ? AND ?", start_date, end_date)
  end

  def missing_mandatory_vaccinations
    Vaccine.where(mandatory: true).where.not(id: vaccinations.pluck(:vaccine_id))
  end
end
