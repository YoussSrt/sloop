class Favorite < ApplicationRecord
  belongs_to :sloopy
  belongs_to :user

  validates :user_id, uniqueness: { scope: :sloopy_id, message: "a déjà enregistré ce voyage comme favori" }
end
