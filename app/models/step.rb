class Step < ApplicationRecord
  belongs_to :sloopy

   has_many :activities, dependent: :destroy

   geocoded_by :city_stop
   after_validation :geocode, if: :will_save_change_to_city_stop?

   # Méthode pour valider que le pays est en Europe après géocodage
   after_validation :validate_european_location, if: :city_stop_changed?

   EUROPEAN_COUNTRIES = [
    "AL", "AD", "AT", "BY", "BE", "BA", "BG", "HR", "CY", "CZ", "DK", "EE",
    "FI", "FR", "DE", "GR", "HU", "IS", "IE", "IT", "XK", "LV", "LI", "LT",
    "LU", "MT", "MD", "MC", "ME", "NL", "MK", "NO", "PL", "PT", "RO", "RU",
    "SM", "RS", "SK", "SI", "ES", "SE", "CH", "UA", "GB", "VA"
  ]

  #  validates :city_name, :step_duration, presence: true
  #  validates :step_duration, numericality: { greater_than: 0 }

  def serialize_step
    {
      "city" => city,
      "transport" => transport,
      "cost" => cost,
      "duration" => duration,
      "latitude" => latitude,
      "longitude" => longitude,
      "city_stop" => city_stop,
      "stays" => stays,
      "activities" => activities.map { |activity| activity.serialize_activity }
    }
  end


  private

  # Méthode pour valider que le pays est en Europe après géocodage
  def validate_european_location
    # Vérifie si le géocodage a retourné un résultat
    if latitude && longitude
      if !EUROPEAN_COUNTRIES.include?(country)

        results = Geocoder.search(city_stop)

        # Rechercher le premier résultat qui correspond à un pays européen
        european_result = results.find do |result|
          result.country_code && EUROPEAN_COUNTRIES.include?(result.country_code)
        end

        # Si aucun résultat valide n'a été trouvé, on cherche un autre résultat
        if european_result.nil? && results.size > 1
          # Recherche d'un autre résultat jusqu'à ce que l'on trouve un pays européen
          european_result = results.detect do |result|
            result.country_code && EUROPEAN_COUNTRIES.include?(result.country_code)
          end
        end

        # Si aucun résultat valide n'a été trouvé, on génère une erreur et met à jour la colonne city_stop
        if !european_result.nil?
          # Si un résultat européen a été trouvé, on met à jour les attributs géographiques
          self.latitude = european_result.latitude
          self.longitude = european_result.longitude
        end
      end
    end

  end
end
