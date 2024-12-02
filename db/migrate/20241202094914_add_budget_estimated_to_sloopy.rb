class AddBudgetEstimatedToSloopy < ActiveRecord::Migration[7.1]
  def change
    add_column :sloopies, :budget_estimated, :integer
  end
end
