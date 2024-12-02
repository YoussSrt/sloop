class AddIsSavedToSloopies < ActiveRecord::Migration[7.1]
  def change
    add_column :sloopies, :is_saved, :boolean, default: false, null: false
  end
end
