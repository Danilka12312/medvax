class AddMandatoryToVaccines < ActiveRecord::Migration[7.0]
  def change
    add_column :vaccines, :mandatory, :boolean
  end
end
