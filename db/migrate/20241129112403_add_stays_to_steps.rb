class AddStaysToSteps < ActiveRecord::Migration[7.1]
  def change
    add_column :steps, :stays, :integer
  end
end
