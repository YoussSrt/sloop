class AddCountryToSteps < ActiveRecord::Migration[7.1]
  def change
    add_column :steps, :country, :string
  end
end
