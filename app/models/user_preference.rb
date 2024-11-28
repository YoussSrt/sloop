class UserPreference < ApplicationRecord
  belongs_to :user
  belongs_to :preference

  # validates :user_id, uniqueness: { scope: :preference_id, message: "a déjà cette préférence" }

  # def set_preferences(user)   (va chercher les préférences de l'utilisateur qui existe déjà, quand l'user pourra mettre à jour ses préférences)
  #   user_preferences = UserPreference.includes(:preference).where(user: user)
    
  #   user_preferences.each_with_object({}) do |user_preference, result|
  #     category = user_preference.preference.category
  #     choice = user_preference.preference.choice

  #     result[category] ||= []
  #     result[category] << choice
  #   end 
  # end
end
