class UserPreference < ApplicationRecord
  belongs_to :user
  belongs_to :preference

  # validates :user_id, uniqueness: { scope: :preference_id, message: "a déjà cette préférence" }
end