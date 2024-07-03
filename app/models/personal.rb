class Personal < ApplicationRecord
	validates :fio, presence: true
  	validates :date_of_birthday, presence: true
  	validates :gender, presence: true
  	validates :email, presence: true, uniqueness: true
  	validates :phone_number, presence: true
  	validates :departament, presence: true
end
