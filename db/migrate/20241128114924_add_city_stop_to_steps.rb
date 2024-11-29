class AddCityStopToSteps < ActiveRecord::Migration[7.1]
  def change
    add_column :steps, :city_stop, :string
  end
end
