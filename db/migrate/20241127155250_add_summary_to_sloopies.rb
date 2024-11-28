class AddSummaryToSloopies < ActiveRecord::Migration[7.1]
  def change
    add_column :sloopies, :summary, :string
  end
end
