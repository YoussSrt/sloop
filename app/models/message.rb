class Message < ApplicationRecord
  belongs_to :chatroom
  belongs_to :sender, class_name: "User"

  validates :content, presence: true
  validates :sender, inclusion: { 
    in: ->(message) { [message.chatroom.first_user, message.chatroom.second_user] },
    message: "must be a participant of the chatroom"
  }

  after_create_commit -> { 
    [sender, receiver].each do |user|
      broadcast_append_to [chatroom, "messages", user],
                         target: "messages",
                         partial: "messages/message",
                         locals: { 
                           message: self, 
                           current_user: user
                         }
    end
  }

  def receiver
    chatroom.other_user(sender)
  end

  def sender?(user)
    sender == user
  end
end
