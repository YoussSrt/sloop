class Chatroom < ApplicationRecord
  belongs_to :first_user, class_name: "User"
  belongs_to :second_user, class_name: "User"
  has_many :messages, dependent: :destroy

  def participants
    [first_user, second_user]
  end

  def other_user(current_user)
    current_user == first_user ? second_user : first_user
  end

  # validates :first_user_id, uniqueness: { scope: :second_user_id, message: "le chatroom existe déjà entre ces utilisateurs" }
end
