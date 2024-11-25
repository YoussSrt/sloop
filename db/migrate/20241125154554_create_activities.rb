class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities do |t|
      t.string :name
      t.references :step, null: false, foreign_key: true

      t.timestamps
    end
  end
end
