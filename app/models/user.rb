class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :sloopies, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :reviews, through: :sloopies
  has_many :user_preferences, dependent: :destroy
  has_many :preferences, through: :user_preferences
  # has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :destroy
  # has_many :chatrooms_as_first_user, class_name: 'Chatroom', foreign_key: 'first_user_id', dependent: :destroy
  # has_many :chatrooms_as_second_user, class_name: 'Chatroom', foreign_key: 'second_user_id', dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :nickname, presence: true, uniqueness: true

  def formatted_preferences # appeler cette méthode au prompt chatgpt #{user.formatted_preferences}
    preferences_by_category.map do |category, choices|
      "#{category.humanize}: #{choices.join(', ')}"
    end.join("; ")
  end

  def update_preferences(preferences_hash)
    user_preferences.destroy_all

    # Ajoute les nouvelles préférences
    preferences_hash.each do |category, choice|
      next unless choice.present?
      choice.shift
      choice.each do |choice|

        preference = Preference.find_or_create_by(choice: choice)
        user_preferences.create(user: self, preference: preference)
      end
    end
  end

  def preferences_by_category
    preferences.group_by(&:category).transform_values do |prefs|
      prefs.map(&:choice)
    end
  end

  def owns?(sloopy)
    self.sloopies.pluck(:id).include?(sloopy.id)
  end
end
