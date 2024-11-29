class AddCoordinatesToSloopies < ActiveRecord::Migration[7.1]
  def change
    add_column :sloopies, :origin_latitude, :float
    add_column :sloopies, :origin_longitude, :float
    add_column :sloopies, :destination_latitude, :float
    add_column :sloopies, :destination_longitude, :float
  end
end
