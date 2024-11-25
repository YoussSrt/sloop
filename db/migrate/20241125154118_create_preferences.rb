class CreatePreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :preferences do |t|
      t.string :category
      t.string :choice

      t.timestamps
    end
  end
end
