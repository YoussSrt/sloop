class Message < ApplicationRecord
  belongs_to :chatroom
  belongs_to :sender, class_name: "User"

  validates :content, presence: true
  validate :sender_must_be_participant

  after_create_commit -> { 
    [sender, receiver].each do |user|
      # Broadcast le message
      broadcast_append_to [chatroom, "messages", user],
                         target: "messages",
                         partial: "messages/message",
                         locals: { 
                           message: self, 
                           current_user: user
                         }
      
      # Broadcast la mise à jour de la sidebar
      broadcast_replace_to "user_#{user.id}_sidebar",
                         target: "chat_sidebar",
                         partial: "shared/sidebar",
                         assigns: { chatroom: chatroom },
                         locals: {
                           chatrooms: Chatroom.where("first_user_id = :id OR second_user_id = :id", id: user.id)
                                     .left_joins(:messages)
                                     .group("chatrooms.id")
                                     .select("chatrooms.*, COALESCE(MAX(messages.created_at), chatrooms.created_at) as last_message_time")
                                     .order("last_message_time DESC"),
                           users: User.where.not(id: user.id),
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

  private

  def sender_must_be_participant
    unless chatroom.participants.include?(sender)
      errors.add(:sender, "must be a participant of the chatroom")
    end
  end
end
