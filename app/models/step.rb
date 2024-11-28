class Step < ApplicationRecord
  belongs_to :sloopy

   has_many :activities, dependent: :destroy

   geocoded_by :city_stop
   after_validation :geocode, if: :will_save_change_to_city_stop?

  #  validates :city_name, :step_duration, presence: true
  #  validates :step_duration, numericality: { greater_than: 0 }
end
