class CreateSteps < ActiveRecord::Migration[7.1]
  def change
    create_table :steps do |t|
      t.string :city_name
      t.integer :step_duration
      t.references :sloopy, null: false, foreign_key: true

      t.timestamps
    end
  end
end
