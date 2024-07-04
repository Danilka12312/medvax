class CreateVaccines < ActiveRecord::Migration[7.0]
  def change
    create_table :vaccines do |t|
      t.string :name
      t.string :manufacturer
      t.text :storage_conditions
      t.text :description
      t.integer :expiry_date

      t.timestamps
    end
  end
end
