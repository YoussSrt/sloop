class Step < ApplicationRecord
  belongs_to :sloopy

   has_many :activities, dependent: :destroy

  #  validates :city_name, :step_duration, presence: true
  #  validates :step_duration, numericality: { greater_than: 0 }
end
