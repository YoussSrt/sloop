class ChangeColumnTypeStatus < ActiveRecord::Migration[7.1]
  def change
    change_column :sloopies, :status, :string, default: "f"
  end
end
