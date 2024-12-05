class AddCopyToSloopies < ActiveRecord::Migration[7.1]
  def change
    add_column :sloopies, :copy, :boolean, default: false
  end
end
