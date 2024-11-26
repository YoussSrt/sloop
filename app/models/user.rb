class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

    has_many :sloopies, dependent: :destroy
    has_many :favorites, dependent: :destroy
    has_many :reviews, through: :sloopies
    # has_many :user_preferences, dependent: :destroy
    has_many :preferences, through: :user_preferences
    # has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :destroy
    # has_many :chatrooms_as_first_user, class_name: 'Chatroom', foreign_key: 'first_user_id', dependent: :destroy
    # has_many :chatrooms_as_second_user, class_name: 'Chatroom', foreign_key: 'second_user_id', dependent: :destroy

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :nickname, presence: true, uniqueness: true
end
