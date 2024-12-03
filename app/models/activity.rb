class Activity < ApplicationRecord
  belongs_to :step

    # validates :name, presence: true
    def serialize_activity
      {
        name: name,
        address: address
      }
    end
end
