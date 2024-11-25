class Preference < ApplicationRecord
    # has_many :user_preferences, dependent: :destroy
    has_many :users, through: :user_preferences

    validates :category, :choice, presence: true
end
