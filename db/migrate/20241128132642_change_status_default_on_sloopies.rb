class ChangeStatusDefaultOnSloopies < ActiveRecord::Migration[7.1]
  def change
    change_column_default :sloopies, :status, from: nil, to: false
  end
end
