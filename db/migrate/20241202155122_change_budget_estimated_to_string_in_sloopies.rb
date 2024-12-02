class ChangeBudgetEstimatedToStringInSloopies < ActiveRecord::Migration[7.1]
  def change
    change_column :sloopies, :budget_estimated, :string
  end
end
