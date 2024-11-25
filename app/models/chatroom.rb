class Chatroom < ApplicationRecord
  belongs_to :first_user, class_name: 'User'
  belongs_to :second_user, class_name: 'User'
  has_many :messages, dependent: :destroy

  # validates :first_user_id, uniqueness: { scope: :second_user_id, message: "le chatroom existe déjà entre ces utilisateurs" }
end
