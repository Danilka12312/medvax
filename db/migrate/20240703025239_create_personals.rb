class CreatePersonals < ActiveRecord::Migration[7.0]
  def change
    create_table :personals do |t|
      t.string :fio
      t.string :date_of_birthday
      t.string :gender
      t.string :email
      t.string :phone_number
      t.string :departament

      t.timestamps
    end
  end
end
