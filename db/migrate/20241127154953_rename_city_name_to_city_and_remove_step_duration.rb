class RenameCityNameToCityAndRemoveStepDuration < ActiveRecord::Migration[7.1]
  def change
    rename_column :steps, :city_name, :city

    remove_column :steps, :step_duration, :integer
  end
end
