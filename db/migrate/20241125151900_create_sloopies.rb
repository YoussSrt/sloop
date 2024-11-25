class CreateSloopies < ActiveRecord::Migration[7.1]
  def change
    create_table :sloopies do |t|
      t.string :origin
      t.string :destination
      t.date :departure_date
      t.date :return_date
      t.integer :budget
      t.integer :duration
      t.boolean :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
