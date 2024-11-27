class Preference < ApplicationRecord
    has_many :user_preferences, dependent: :destroy
    has_many :users, through: :user_preferences
    validates :category, :choice, presence: true

    PREFERENCES = {
  favorite_activities: [
    "Outdoor",
    "Sports",
    "Creative",
    "Cultural",
    "Relaxation",
    "Social",
    "Party"
  ],
  ideal_travel_pace: [
    "Very active",
    "Active",
    "Balanced",
    "Relaxed",
    "Flexible",
    "Lazy"
  ],
  exciting_experiences: [
    "Nature",
    "City exploration",
    "Local events",
    "Food & drinks",
    "Shopping",
    "Learning"
  ],
  traveling_with: [
    "Solo",
    "Couple",
    "Family",
    "Friends",
    "Group"
  ],
  preferred_vibe: [
    "Adventure",
    "Chill",
    "Luxury",
    "Off-the-beaten-path",
    "Minimal",
    "Social",
    "Lonely"
  ],
  main_travel_goal: [
    "Adventure",
    "Relaxation",
    "Discovering cultures",
    "Trying new foods",
    "Connecting with people"
  ]
}
end
