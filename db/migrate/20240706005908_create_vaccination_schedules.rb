class CreateVaccinationSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :vaccination_schedules do |t|
      t.references :personal, null: false, foreign_key: true
      t.references :vaccine, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true
      t.date :vaccination_date
      t.time :vaccination_time

      t.timestamps
    end
  end
end
