class AddVaccineTypeToVaccines < ActiveRecord::Migration[7.0]
  def change
    add_column :vaccines, :vaccine_type, :string
  end
end
