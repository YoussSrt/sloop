class Review < ApplicationRecord
  belongs_to :sloopy

  validates :content, :rating, presence: true
  validates :rating, inclusion: { in: 1..5, message: "between 1 and 5" }
end
