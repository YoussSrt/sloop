class AddCoordinatesToSteps < ActiveRecord::Migration[7.1]
  def change
    add_column :steps, :latitude, :float
    add_column :steps, :longitude, :float
  end
end
