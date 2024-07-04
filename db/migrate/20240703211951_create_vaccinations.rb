# db/migrate/xxxxxx_create_vaccinations.rb
class CreateVaccinations < ActiveRecord::Migration[7.0]
  def change
    create_table :vaccinations do |t|
      t.references :personal, null: false, foreign_key: true
      t.references :vaccine, null: false, foreign_key: true
      t.date :vaccination_date

      t.timestamps
    end
  end
end
