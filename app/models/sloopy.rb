class Sloopy < ApplicationRecord
  belongs_to :user
  has_many :steps, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :questions, dependent: :destroy


  validates :origin, :destination, :departure_date, :duration, presence: true
  validates :duration, numericality: { greater_than: 0 }

  # geocoded_by :origin, latitude: :origin_latitude, longitude: :origin_longitude

  # reverse_geocoded_by :destination_latitude, :destination_longitude, address: :destination


end
