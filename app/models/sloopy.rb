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

  def serialize_sloopy
    {
      origin: origin,
      destination: destination,
      departure_date: departure_date,
      return_date: return_date,
      budget: budget,
      duration: duration,
      budget_estimated: budget_estimated,
      summary: summary,
      steps: steps.map { |step| step.serialize_step }
    }
  end

end
