class Sloopy < ApplicationRecord
  belongs_to :user
  has_many :steps, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :questions, dependent: :destroy


  validates :origin, :destination, :departure_date, :duration, presence: true
  validates :duration, numericality: { greater_than: 0 }
  validates :is_saved, inclusion: { in: [true, false] }

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

  def to_markers(index)
    route_coordinates = []
    markers = []

    # Départ
    if origin_latitude && origin_longitude
      route_coordinates << [origin_longitude, origin_latitude]
      markers << { lat: origin_latitude, lng: origin_longitude, type: "origin" }
    end

    # Étapes
    steps.each do |step|
      if step.latitude && step.longitude
        route_coordinates << [step.longitude, step.latitude]
        markers << { lat: step.latitude, lng: step.longitude, type: "step" }
      end
    end

    # Arrivée
    if destination_latitude && destination_longitude
      route_coordinates << [destination_longitude, destination_latitude]
      markers << { lat: destination_latitude, lng: destination_longitude, type: "destination" }
    end

    # Fermer la boucle
    route_coordinates << route_coordinates.first if route_coordinates.any?

    # Ajouter les coordonnées du tracé au premier marqueur
    markers.first[:route_coordinates] = route_coordinates if markers.any?
    markers.first[:route_id] = index if markers.any?
    markers
  end

end
