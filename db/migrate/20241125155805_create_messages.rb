class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.text :content
      t.boolean :status
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :chatroom, null: false, foreign_key: true

      t.timestamps
    end
  end
end
