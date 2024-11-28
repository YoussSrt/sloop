class Sloopy < ApplicationRecord
  belongs_to :user

  # par qui il a ete liké et qui a liké
  has_many :steps, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates :origin, :destination, :departure_date, :duration, presence: true
  validates :duration, numericality: { greater_than: 0 }
  # validates :status, inclusion: { in: [true, false] }
end
