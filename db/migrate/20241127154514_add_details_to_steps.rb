class AddDetailsToSteps < ActiveRecord::Migration[7.1]
  def change
    add_column :steps, :transport, :string
    add_column :steps, :cost, :integer
    add_column :steps, :duration, :integer
  end
end
