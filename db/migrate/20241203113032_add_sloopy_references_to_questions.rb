class AddSloopyReferencesToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_reference :questions, :sloopy, null: false, foreign_key: true
  end
end
