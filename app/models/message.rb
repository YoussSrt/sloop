class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :chatroom

  validates :content, presence: true
  # validates :status, inclusion: { in: [true, false] }
end
