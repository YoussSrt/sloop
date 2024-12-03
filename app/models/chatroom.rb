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

  def self.between_users(user1, user2)
    where("(first_user_id = ? AND second_user_id = ?) OR (first_user_id = ? AND second_user_id = ?)",
          user1.id, user2.id, user2.id, user1.id)
  end

  # validates :first_user_id, uniqueness: { scope: :second_user_id, message: "le chatroom existe déjà entre ces utilisateurs" }
end
