class Vaccine < ApplicationRecord
	has_many :vaccinations
 	has_many :personals, through: :vaccinations
end
