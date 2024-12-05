class SetDefaultForCopyOnSloopies < ActiveRecord::Migration[7.1]
  def change
    change_column_default :sloopies, :copy, from: nil, to: false
  end
end
