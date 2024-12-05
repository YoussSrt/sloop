class AddRegionToSteps < ActiveRecord::Migration[7.1]
  def change
    add_column :steps, :region, :string
  end
end
